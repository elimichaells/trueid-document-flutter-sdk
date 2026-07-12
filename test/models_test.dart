import 'package:flutter_test/flutter_test.dart';
import 'package:trueid_document_sdk/trueid_document_sdk.dart';

void main() {
  group('DocumentType', () {
    test('fromWire round-trips every wire value', () {
      for (final type in DocumentType.values) {
        expect(DocumentType.fromWire(type.wireValue), type);
      }
    });

    test('fromWire falls back to auto for unknown values', () {
      expect(DocumentType.fromWire('something_unexpected'), DocumentType.auto);
      expect(DocumentType.fromWire(null), DocumentType.auto);
    });
  });

  group('DocumentVerificationResult', () {
    test('isSuccess requires verified and no error', () {
      final result = DocumentVerificationResult.fromMap({
        'verified': true,
        'documentType': 'ghana_card',
      });
      expect(result.isSuccess, true);
      expect(result.isPendingReview, false);
    });

    test('isPendingReview is true whenever reviewStatus is set', () {
      final result = DocumentVerificationResult.fromMap({
        'verified': true,
        'documentType': 'ghana_card',
        'reviewStatus': 'PENDING_REVIEW',
      });
      expect(result.isPendingReview, true);
    });

    test('fromMap parses extracted fields and defaults', () {
      final result = DocumentVerificationResult.fromMap({
        'verified': true,
        'documentType': 'ghana_passport',
        'fullName': 'Jane Doe',
        'confidence': 0.97,
      });

      expect(result.documentType, DocumentType.ghanaPassport);
      expect(result.fullName, 'Jane Doe');
      expect(result.confidence, 0.97);
      expect(result.isExpired, false);
    });
  });
}
