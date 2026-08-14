import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class WorkoutFileIO {
  static Future<bool> saveJsonFile({
    required String suggestedFileName,
    required String contents,
  }) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save workout program',
      fileName: suggestedFileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: Uint8List.fromList(utf8.encode(contents)),
    );
    return path != null;
  }

  static Future<String?> pickJsonFileContents() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import workout program',
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes != null) {
      return utf8.decode(bytes);
    }

    final path = file.path;
    if (path == null) return null;
    return File(path).readAsString();
  }
}
