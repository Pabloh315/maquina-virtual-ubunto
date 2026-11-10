import 'dart:convert';
import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final directory = Directory('docs/edt34/evidence');
  await directory.create(recursive: true);
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(name)) return false;
      await File('${directory.path}/$name.png').writeAsBytes(bytes);
      return bytes.isNotEmpty;
    },
    responseDataCallback: (data) async {
      // Las capturas se guardan como PNG; el registro JSON solo conserva metadatos.
      final report = Map<String, dynamic>.from(data ?? {});
      report.remove('screenshots');
      await File(
        '${directory.path}/android-integration.json',
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(report));
    },
  );
}
