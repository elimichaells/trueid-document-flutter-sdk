package com.trueid.sdk.documentflutter

import android.app.Activity
import androidx.activity.ComponentActivity
import com.trueid.sdk.document.DocumentType
import com.trueid.sdk.document.DocumentVerificationCallback
import com.trueid.sdk.document.DocumentVerificationConfig
import com.trueid.sdk.document.DocumentVerificationError
import com.trueid.sdk.document.DocumentVerificationResult
import com.trueid.sdk.document.TrueIDDocumentVerification
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class TrueIdDocumentSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: Result? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.trueid.sdk.document/flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "verifyDocument" -> handleVerifyDocument(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleVerifyDocument(call: MethodCall, result: Result) {
        val currentActivity = activity
        if (currentActivity !is ComponentActivity) {
            result.error("INCOMPATIBLE_ACTIVITY", "Activity must be a ComponentActivity", null)
            return
        }

        if (pendingResult != null) {
            result.error("ALREADY_ACTIVE", "A document verification is already in progress", null)
            return
        }

        pendingResult = result

        val config = DocumentVerificationConfig(
            documentType = DocumentType.fromWire(call.argument<String>("documentType")),
            useOrganizationCaptureSettings =
                call.argument<Boolean>("useOrganizationCaptureSettings") ?: true,
            collectAdditionalInfo = call.argument<Boolean>("collectAdditionalInfo") ?: true,
            requireSelfie = call.argument<Boolean>("requireSelfie") ?: true,
            showGuidelines = call.argument<Boolean>("showGuidelines") ?: true,
            showReviewForDebug = call.argument<Boolean>("showReviewForDebug") ?: false,
            referenceId = call.argument<String>("referenceId"),
            selfieCaptureConfig = com.trueid.sdk.selfie.SelfieCaptureConfig(
                captureMode = when (call.argument<String>("captureMode")) {
                    "manual" -> com.trueid.sdk.selfie.CaptureMode.MANUAL
                    else -> com.trueid.sdk.selfie.CaptureMode.AUTO
                },
                resultFormat = com.trueid.sdk.selfie.ResultFormat.BASE64,
                requireLiveness = true,
            ),
        )

        val callback = object : DocumentVerificationCallback {
            override fun onCompleted(verificationResult: DocumentVerificationResult) {
                val map = hashMapOf<String, Any?>(
                    "verified" to verificationResult.verified,
                    "scanRecordId" to verificationResult.scanRecordId,
                    "documentType" to verificationResult.documentType.wireValue,
                    "documentNumber" to verificationResult.documentNumber,
                    "fullName" to verificationResult.fullName,
                    "nationality" to verificationResult.nationality,
                    "dateOfBirth" to verificationResult.dateOfBirth,
                    "expiryDate" to verificationResult.expiryDate,
                    "gender" to verificationResult.gender,
                    "isExpired" to verificationResult.isExpired,
                    "confidence" to verificationResult.confidence,
                    "phoneNumber" to verificationResult.phoneNumber,
                    "email" to verificationResult.email,
                    "documentFrontUrl" to verificationResult.documentFrontUrl,
                    "documentBackUrl" to verificationResult.documentBackUrl,
                    "selfieUrl" to verificationResult.selfieUrl,
                    "reviewStatus" to verificationResult.reviewStatus,
                    "referenceId" to verificationResult.referenceId,
                    "errorMessage" to verificationResult.errorMessage,
                    "errorCode" to verificationResult.errorCode,
                )
                pendingResult?.success(map)
                pendingResult = null
            }

            override fun onCancelled() {
                pendingResult?.success(null)
                pendingResult = null
            }

            override fun onError(error: DocumentVerificationError) {
                val code = when (error) {
                    is DocumentVerificationError.SdkNotInitialized -> "SDK_NOT_INITIALIZED"
                    is DocumentVerificationError.CameraUnavailable -> "CAMERA_UNAVAILABLE"
                    is DocumentVerificationError.NetworkError -> "NETWORK_ERROR"
                    is DocumentVerificationError.ApiError -> error.code ?: "API_ERROR"
                    is DocumentVerificationError.CaptureError -> "CAPTURE_ERROR"
                }
                pendingResult?.error(code, error.message, null)
                pendingResult = null
            }
        }

        TrueIDDocumentVerification.launch(currentActivity, config, callback)
    }
}
