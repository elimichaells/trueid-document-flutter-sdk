## 1.0.1

* Updates the native Android dependency to `trueid-document-sdk:1.1.1` and
  `trueid_core` to `^1.0.1`:
  * Real OpenCV-based document boundary detection (shape + aspect-ratio
    aware) replacing the old texture-only heuristic, with MRZ presence used
    as a soft auto-capture signal rather than a hard requirement — documents
    with no MRZ line no longer stall capture.
  * Shutter sound, capture-progress ring, card-flip interstitial between
    front/back capture, and a selfie confirm/retake screen before submission.
  * Additional-information step now renders every field the organization has
    enabled on their dashboard (not just phone/email).
  * Fixes a capture-gate race that could trigger repeated auto-captures
    behind the confirm screen, and skips unused burst frames when active
    liveness already covers anti-spoofing (cuts ~5s off the selfie confirm
    delay).
  * Fixes a packaging issue where the native SDK silently required host apps
    to raise `compileSdk` to 36.
* No Dart-facing API changes.

## 1.0.0

* Initial release: standard document verification as a fully native Android
  flow — the native equivalent of the TrueID hosted widget's "standard" mode.
* Document type selection driven by the organization's dashboard settings
  (allowed document types, default type, brand colors, additional-info fields).
* Guided capture of the front and back of an ID card (or a passport data
  page), with live quality hints (lighting, glare, blur, document presence),
  MRZ-aware auto-capture, and confirm/retake previews cropped to the guide
  frame.
* Additional information step (phone/email, per organization settings).
* Trailing selfie with guided liveness (shared engine from `trueid_core`).
* Server-side OCR/MRZ extraction with an on-screen review of extracted
  details before anything is saved.
* Final screen honors the organization's review mode: instant
  "Verification Complete" or "Pending Review" (`result.reviewStatus`).
* Fast Track: returning users verify by email OTP, pick a previous
  verification (with their photo on file), and link it to the organization
  without rescanning.
