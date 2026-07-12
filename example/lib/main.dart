import 'package:flutter/material.dart';
import 'package:trueid_core/trueid_core.dart';
import 'package:trueid_document_sdk/trueid_document_sdk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const secretKey = String.fromEnvironment('TRUEID_SECRET_KEY');
  const publishableKey = String.fromEnvironment('TRUEID_PUBLISHABLE_KEY');
  final configured = secretKey.isNotEmpty || publishableKey.isNotEmpty;

  if (configured) {
    await TrueIdSdk.initialize(
      secretKey: secretKey.isEmpty ? null : secretKey,
      publishableKey: publishableKey.isEmpty ? null : publishableKey,
    );
  }

  runApp(TrueIdDocumentExample(configured: configured));
}

class TrueIdDocumentExample extends StatefulWidget {
  const TrueIdDocumentExample({required this.configured, super.key});

  final bool configured;

  @override
  State<TrueIdDocumentExample> createState() => _TrueIdDocumentExampleState();
}

class _TrueIdDocumentExampleState extends State<TrueIdDocumentExample> {
  bool _verifying = false;
  String? _status;

  Future<void> _verifyDocument() async {
    setState(() {
      _verifying = true;
      _status = null;
    });

    try {
      final result = await TrueIdDocumentSdk.verifyDocument();
      if (!mounted) return;
      setState(() {
        _status = result == null
            ? 'Verification cancelled.'
            : result.isSuccess
            ? 'Verification completed successfully.'
            : result.errorMessage ?? 'Verification was not successful.';
      });
    } on TrueIdDocumentException catch (error) {
      if (!mounted) return;
      setState(() => _status = 'Verification failed: ${error.message}');
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF155EEF)),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('TrueID Document Verification')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.badge_outlined, size: 64),
                  const SizedBox(height: 20),
                  Text(
                    widget.configured
                        ? 'Start a native document-verification flow.'
                        : 'Add a TrueID API key using --dart-define to run this example.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: widget.configured && !_verifying
                        ? _verifyDocument
                        : null,
                    icon: _verifying
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.document_scanner_outlined),
                    label: Text(_verifying ? 'Verifying…' : 'Verify document'),
                  ),
                  if (_status != null) ...[
                    const SizedBox(height: 20),
                    Text(_status!, textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
