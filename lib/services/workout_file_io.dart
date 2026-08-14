import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class WorkoutFileIO {
  static Future<bool> saveJsonFile({
    required String suggestedFileName,
    required String contents,
  }) async {
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save workout program',
      fileName: suggestedFileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: (kIsWeb || isMobile) ? Uint8List.fromList(utf8.encode(contents)) : null,
    );
    if (path == null) return false;

    // On desktop platforms, FilePicker.platform.saveFile only returns the
    // chosen path without writing any data, so we must write the file
    // ourselves. On web and mobile, the bytes passed above are already
    // written by the plugin.
    if (!kIsWeb && !isMobile) {
      await File(path).writeAsString(contents);
    }
    return true;
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
