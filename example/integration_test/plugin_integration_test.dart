import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:trueid_document_sdk_example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders API-key setup guidance', (tester) async {
    await tester.pumpWidget(const TrueIdDocumentExample(configured: false));

    expect(find.text('TrueID Document Verification'), findsOneWidget);
    expect(find.textContaining('--dart-define'), findsOneWidget);
    expect(find.text('Verify document'), findsOneWidget);
  });
}
