import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum StorySaveOutcome { saved, denied, noSpace }

enum StoryShareOutcome { shared, dismissed, unavailable }

/// Where a finished story can go. The image never leaves the device except
/// through the share sheet the user picks a target in.
abstract class StoryExportActions {
  Future<StorySaveOutcome> saveToGallery(Uint8List png);

  Future<StoryShareOutcome> share(Uint8List png, {Rect? origin});

  /// Deletes any temporary file made for sharing.
  Future<void> dispose();
}

class DeviceStoryExportActions implements StoryExportActions {
  DeviceStoryExportActions({Future<Directory> Function()? tempDir})
    : _tempDir = tempDir ?? getTemporaryDirectory;

  final Future<Directory> Function() _tempDir;
  File? _shared;
  Uint8List? _sharedBytes;

  static const _folder = 'workout_story';

  static String fileName() => 'workout_story_${DateTime.now().millisecondsSinceEpoch}';

  @override
  Future<StorySaveOutcome> saveToGallery(Uint8List png) async {
    // Android 10+ saves without asking; older Android and iOS ask for
    // add-only access.
    if (!await Gal.hasAccess() && !await Gal.requestAccess()) {
      return StorySaveOutcome.denied;
    }
    try {
      await Gal.putImageBytes(png, name: fileName());
      return StorySaveOutcome.saved;
    } on GalException catch (e) {
      if (e.type == GalExceptionType.accessDenied) return StorySaveOutcome.denied;
      if (e.type == GalExceptionType.notEnoughSpace) return StorySaveOutcome.noSpace;
      rethrow;
    }
  }

  @override
  Future<StoryShareOutcome> share(Uint8List png, {Rect? origin}) async {
    final file = await _fileFor(png);
    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'image/png')], sharePositionOrigin: origin),
    );
    return switch (result.status) {
      ShareResultStatus.success => StoryShareOutcome.shared,
      ShareResultStatus.dismissed => StoryShareOutcome.dismissed,
      ShareResultStatus.unavailable => StoryShareOutcome.unavailable,
    };
  }

  /// One temporary PNG per image, reused if the user shares it again.
  Future<File> _fileFor(Uint8List png) async {
    if (_shared != null && identical(_sharedBytes, png) && await _shared!.exists()) {
      return _shared!;
    }
    await _deleteShared();
    final dir = Directory('${(await _tempDir()).path}/$_folder');
    if (await dir.exists()) {
      // Files left by an earlier run that ended before it cleaned up.
      await for (final f in dir.list()) {
        if (f is File) await _tryDelete(f);
      }
    } else {
      await dir.create(recursive: true);
    }
    final file = File('${dir.path}/${fileName()}.png');
    await file.writeAsBytes(png, flush: true);
    _shared = file;
    _sharedBytes = png;
    return file;
  }

  Future<void> _deleteShared() async {
    final f = _shared;
    _shared = null;
    _sharedBytes = null;
    if (f != null) await _tryDelete(f);
  }

  static Future<void> _tryDelete(File f) async {
    try {
      if (await f.exists()) await f.delete();
    } on FileSystemException {
      // In use by the share target; the next run or the OS removes it.
    }
  }

  @override
  Future<void> dispose() => _deleteShared();
}
