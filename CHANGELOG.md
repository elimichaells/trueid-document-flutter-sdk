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
