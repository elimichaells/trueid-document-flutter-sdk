import 'package:flutter/services.dart';
import 'models.dart';

/// Main entry point for the TrueID Document SDK.
///
/// Call `TrueIdSdk.initialize()` (from the `trueid_sdk` package) once before
/// using [verifyDocument] — both SDKs share the same secret/publishable key
/// setup.
///
/// ```dart
/// final result = await TrueIdDocumentSdk.verifyDocument();
/// if (result != null && result.isSuccess) {
///   // success
/// }
/// ```
class TrueIdDocumentSdk {
  static const MethodChannel _channel = MethodChannel('com.trueid.sdk.document/flutter');

  TrueIdDocumentSdk._();

  /// Launch the standard document-verification flow (document capture ->
  /// additional info -> selfie+liveness -> submit).
  ///
  /// Returns a [DocumentVerificationResult] on completion, or `null` if the
  /// user cancelled. Throws [TrueIdDocumentException] on error.
  static Future<DocumentVerificationResult?> verifyDocument({
    DocumentVerificationConfig config = const DocumentVerificationConfig(),
  }) async {
    try {
      final map = await _channel.invokeMethod<Map<Object?, Object?>>('verifyDocument', {
        'documentType': config.documentType.wireValue,
        'useOrganizationCaptureSettings': config.useOrganizationCaptureSettings,
        'collectAdditionalInfo': config.collectAdditionalInfo,
        'requireSelfie': config.requireSelfie,
        'showGuidelines': config.showGuidelines,
        'showReviewForDebug': config.showReviewForDebug,
        'referenceId': config.referenceId,
        'captureMode': config.captureMode,
      });

      if (map == null) return null;
      return DocumentVerificationResult.fromMap(map);
    } on PlatformException catch (e) {
      throw TrueIdDocumentException(e.code, e.message);
    }
  }
}
