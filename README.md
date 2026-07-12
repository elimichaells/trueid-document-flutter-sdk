# TrueID Document SDK for Flutter

Standard document verification as a fully native Android flow: your customer
scans the front and back of their ID card (or a passport data page), fills in
contact details, takes a selfie with guided liveness, reviews the extracted
details, and the verification is saved to your TrueID organization — all in
one Dart call.

This is the native equivalent of the TrueID hosted widget's "standard" mode,
with the same design language, driven by the same organization dashboard
settings (allowed document types, brand colors, review mode, additional-info
fields).

For Ghana Card **PIN + selfie (NIA)** verification, use
[`trueid_nia_sdk`](https://pub.dev/packages/trueid_nia_sdk); for the hosted
browser flow, use [`trueid_hosted_sdk`](https://pub.dev/packages/trueid_hosted_sdk).
Every TrueID product package shares one `TrueIdSdk.initialize()` call from
[`trueid_core`](https://pub.dev/packages/trueid_core).

## Features

- **Document capture** — front + back of ID cards, or the data page of a
  passport, with live quality guidance (lighting, glare, blur, document
  presence), MRZ-aware auto-capture, and confirm/retake previews cropped to
  the guide frame
- **Organization-driven configuration** — allowed document types, default
  type, brand colors, and additional-info fields come from your dashboard on
  app.trueid.info; change them there without shipping an app update
- **Additional information step** — phone/email collection per your settings
- **Selfie with guided liveness** — head-turn challenge + countdown, shared
  engine from `trueid_core`
- **Review of extracted details** — server-side OCR/MRZ extraction shown to
  the user before anything is saved
- **Review-mode aware result** — instant "Verification Complete" or
  "Pending Review" based on your organization's review mode
  (`result.reviewStatus`)
- **Fast Track** — returning users verify by email OTP and reuse a previous
  verification (with their photo on file) without rescanning

## Platform Support

| Platform | Supported |
|----------|-----------|
| Android  | Yes       |
| iOS      | No (planned) |

## Installation

```yaml
dependencies:
  trueid_core: ^1.0.0
  trueid_document_sdk: ^1.0.0
```

### Android Setup

Add the TrueID Maven repository to your `android/settings.gradle.kts`:

```kotlin
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://app.trueid.info/sdk/android") }
    }
}
```

On-prem institutions: replace `app.trueid.info` with your TrueID server origin.

Set `minSdkVersion` to at least **24**, and make your `MainActivity` extend
`FlutterFragmentActivity` (the camera screens need an androidx
`ComponentActivity` host):

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

## Quick Start

```dart
import 'package:trueid_core/trueid_core.dart';
import 'package:trueid_document_sdk/trueid_document_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TrueIdSdk.initialize(
    secretKey: 'sk_your_secret_key',
    publishableKey: 'pk_your_publishable_key',
  );
  runApp(MyApp());
}

Future<void> verifyDocument() async {
  try {
    final result = await TrueIdDocumentSdk.verifyDocument();

    if (result == null) {
      print('User cancelled');
      return;
    }

    if (result.isPendingReview) {
      // Saved, awaiting your organization's manual review
      print('Pending review: ${result.scanRecordId}');
    } else if (result.isSuccess) {
      print('Verified: ${result.fullName} (${result.documentNumber})');
    }
  } on TrueIdDocumentException catch (e) {
    print('Error: ${e.code} - ${e.message}');
  }
}
```

Both API keys live at app.trueid.info → Settings → API. The document flow
uses your **secret key** for OCR extraction and your **publishable key** for
saving the verification — pass both to `initialize()`.

## API Reference

### TrueIdDocumentSdk

| Method | Description |
|--------|-------------|
| `verifyDocument({config})` | Launch the full document-verification flow. Returns `DocumentVerificationResult?` (`null` if cancelled). |

### DocumentVerificationConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `documentType` | `DocumentType` | `auto` | Preselect a document type (skips the picker) |
| `useOrganizationCaptureSettings` | `bool` | `true` | Pull allowed types, fields, and colors from your dashboard |
| `collectAdditionalInfo` | `bool` | `true` | Show the contact-details step |
| `requireSelfie` | `bool` | `true` | Run the trailing selfie + liveness step |
| `showGuidelines` | `bool` | `true` | Show the photo-instructions screen |
| `referenceId` | `String?` | `null` | Your correlation id, echoed on the scan record |
| `captureMode` | `String` | `'auto'` | `'auto'` or `'manual'` capture |

### DocumentVerificationResult

| Field | Type | Description |
|-------|------|-------------|
| `verified` | `bool` | Approved instantly (false while pending review) |
| `isPendingReview` | `bool` | Saved, awaiting the organization's manual review |
| `reviewStatus` | `String?` | `PENDING_REVIEW` / `EXPIRED_PENDING_REVERIFY` / null |
| `scanRecordId` | `String?` | Record id — fetch the full record server-side |
| `documentType` | `DocumentType` | The verified document's type |
| `documentNumber`, `fullName`, `nationality`, `dateOfBirth`, `expiryDate`, `gender` | `String?` | Extracted document fields |
| `phoneNumber`, `email` | `String?` | Collected contact details |
| `errorMessage`, `errorCode` | `String?` | Failure details, when applicable |

### DocumentType

`auto`, `ghanaCard`, `ghanaPassport`, `internationalPassport`, `nationalId`,
`drivingLicense`, `residencePermit`, `visa` — which of these your customers
can pick is controlled from your dashboard.

## License

Proprietary. Use of this SDK requires an active TrueID organization account —
see https://app.trueid.info.
