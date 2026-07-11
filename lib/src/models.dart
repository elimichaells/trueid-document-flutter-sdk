/// Document types the standard verification flow can capture. Values mirror
/// the wire strings used by the organization's document-capture settings on
/// app.trueid.info.
enum DocumentType {
  auto('auto'),
  ghanaCard('ghana_card'),
  ghanaPassport('ghana_passport'),
  internationalPassport('international_passport'),
  nationalId('national_id'),
  drivingLicense('driving_license'),
  residencePermit('residence_permit'),
  visa('visa');

  const DocumentType(this.wireValue);

  final String wireValue;

  static DocumentType fromWire(String? value) => DocumentType.values.firstWhere(
        (type) => type.wireValue == value,
        orElse: () => DocumentType.auto,
      );
}

/// Configuration for [TrueIdDocumentSdk.verifyDocument].
class DocumentVerificationConfig {
  const DocumentVerificationConfig({
    this.documentType = DocumentType.auto,
    this.useOrganizationCaptureSettings = true,
    this.collectAdditionalInfo = true,
    this.requireSelfie = true,
    this.showGuidelines = true,
    this.showReviewForDebug = false,
    this.referenceId,
    this.captureMode = 'auto',
  });

  /// Preselected document type. Ignored if [useOrganizationCaptureSettings]
  /// resolves an org-configured default.
  final DocumentType documentType;

  /// Fetch the institution's allowed document types / additional-info
  /// fields / upload settings before the flow starts.
  final bool useOrganizationCaptureSettings;

  /// Show the additional-info step (phone + email) after document capture.
  final bool collectAdditionalInfo;

  /// Run the trailing selfie+liveness step — matches the hosted "standard"
  /// mode, which always includes it.
  final bool requireSelfie;

  /// Show the "Photo Instructions" screen before the camera.
  final bool showGuidelines;

  /// Developer-only diagnostics: show extracted OCR details before saving.
  /// End-user flows should leave this disabled.
  final bool showReviewForDebug;

  /// Your own correlation id, echoed back on the scan record.
  final String? referenceId;

  /// 'auto' or 'manual' — applies to both document and selfie capture.
  final String captureMode;
}

/// Result of a standard document verification.
class DocumentVerificationResult {
  const DocumentVerificationResult({
    required this.verified,
    this.scanRecordId,
    required this.documentType,
    this.documentNumber,
    this.fullName,
    this.nationality,
    this.dateOfBirth,
    this.expiryDate,
    this.gender,
    this.isExpired = false,
    this.confidence,
    this.phoneNumber,
    this.email,
    this.documentFrontUrl,
    this.documentBackUrl,
    this.selfieUrl,
    this.referenceId,
    this.errorMessage,
    this.errorCode,
    this.reviewStatus,
  });

  factory DocumentVerificationResult.fromMap(Map<Object?, Object?> map) {
    return DocumentVerificationResult(
      verified: map['verified'] as bool? ?? false,
      scanRecordId: map['scanRecordId'] as String?,
      documentType: DocumentType.fromWire(map['documentType'] as String?),
      documentNumber: map['documentNumber'] as String?,
      fullName: map['fullName'] as String?,
      nationality: map['nationality'] as String?,
      dateOfBirth: map['dateOfBirth'] as String?,
      expiryDate: map['expiryDate'] as String?,
      gender: map['gender'] as String?,
      isExpired: map['isExpired'] as bool? ?? false,
      confidence: (map['confidence'] as num?)?.toDouble(),
      phoneNumber: map['phoneNumber'] as String?,
      email: map['email'] as String?,
      documentFrontUrl: map['documentFrontUrl'] as String?,
      documentBackUrl: map['documentBackUrl'] as String?,
      selfieUrl: map['selfieUrl'] as String?,
      referenceId: map['referenceId'] as String?,
      errorMessage: map['errorMessage'] as String?,
      errorCode: map['errorCode'] as String?,
      reviewStatus: map['reviewStatus'] as String?,
    );
  }

  final bool verified;
  final String? scanRecordId;
  final DocumentType documentType;
  final String? documentNumber;
  final String? fullName;
  final String? nationality;
  final String? dateOfBirth;
  final String? expiryDate;
  final String? gender;
  final bool isExpired;
  final double? confidence;
  final String? phoneNumber;
  final String? email;
  final String? documentFrontUrl;
  final String? documentBackUrl;
  final String? selfieUrl;
  final String? referenceId;
  final String? errorMessage;
  final String? errorCode;

  /// `PENDING_REVIEW` / `EXPIRED_PENDING_REVERIFY` when the organization's
  /// review mode defers approval; null when approved instantly.
  final String? reviewStatus;

  bool get isSuccess => verified && errorMessage == null;

  /// The verification was saved but awaits the organization's manual review.
  bool get isPendingReview => reviewStatus != null;
}

/// Thrown when the native side reports an error (see `error.code`).
class TrueIdDocumentException implements Exception {
  const TrueIdDocumentException(this.code, this.message);

  final String code;
  final String? message;

  @override
  String toString() => 'TrueIdDocumentException($code, $message)';
}
