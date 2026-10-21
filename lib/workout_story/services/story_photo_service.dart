import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

enum StoryPhotoSource { gallery, camera }

enum StoryPhotoError { galleryDenied, cameraDenied, unreadable }

class StoryPhotoException implements Exception {
  const StoryPhotoException(this.error, [this.cause]);

  final StoryPhotoError error;
  final Object? cause;

  @override
  String toString() => 'StoryPhotoException($error, $cause)';
}

/// Picks a photo on the device. Returns null when the user cancels; throws
/// [StoryPhotoException] when access is denied. Photos stay on the device.
abstract class StoryPhotoPicker {
  Future<String?> pick(StoryPhotoSource source);

  /// Removes the app's own copy of a picked photo once the editor is done
  /// with it. Only files in the app's temporary folder are touched.
  Future<void> discard(Iterable<String> paths);
}

class DeviceStoryPhotoPicker implements StoryPhotoPicker {
  DeviceStoryPhotoPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Big enough to zoom in on a 1080×1920 story; larger photos are scaled
  /// down by the picker before they reach the app.
  static const double maxSide = 3240;

  @override
  Future<String?> pick(StoryPhotoSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source == StoryPhotoSource.camera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: maxSide,
        maxHeight: maxSide,
        // Only the pixels are needed; skips the iOS full-library permission.
        requestFullMetadata: false,
      );
      return file?.path;
    } on PlatformException catch (e) {
      if (e.code.contains('access_denied')) {
        throw StoryPhotoException(
          source == StoryPhotoSource.camera
              ? StoryPhotoError.cameraDenied
              : StoryPhotoError.galleryDenied,
          e,
        );
      }
      throw StoryPhotoException(StoryPhotoError.unreadable, e);
    }
  }

  @override
  Future<void> discard(Iterable<String> paths) async {
    final tmp = (await getTemporaryDirectory()).path;
    for (final path in paths) {
      // image_picker hands back copies in the app's cache or tmp folder;
      // anything else is not ours to delete.
      if (!path.startsWith(tmp)) continue;
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } on FileSystemException {
        // Already gone or in use; the OS clears the cache folder anyway.
      }
    }
  }
}

/// Decodes [bytes] into an image no larger than [maxSide] on its long side,
/// so a 48-megapixel photo isn't held in memory at full size. The aspect
/// ratio is kept exactly. Throws [StoryPhotoException] if the bytes aren't
/// an image Flutter can read.
Future<ui.Image> decodeStoryPhoto(Uint8List bytes, {int maxSide = 2560}) async {
  try {
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final codec = await ui.instantiateImageCodecWithSize(
      buffer,
      getTargetSize: (w, h) {
        final scale = math.min(1.0, maxSide / math.max(w, h));
        // Width only: the decoder derives the height, so nothing is stretched.
        return scale < 1
            ? ui.TargetImageSize(width: math.max(1, (w * scale).round()))
            : const ui.TargetImageSize();
      },
    );
    try {
      final frame = await codec.getNextFrame();
      return frame.image;
    } finally {
      codec.dispose();
    }
  } on StoryPhotoException {
    rethrow;
  } catch (e) {
    throw StoryPhotoException(StoryPhotoError.unreadable, e);
  }
}

Future<ui.Image> decodeStoryPhotoFile(String path) async {
  final Uint8List bytes;
  try {
    bytes = await File(path).readAsBytes();
  } on FileSystemException catch (e) {
    throw StoryPhotoException(StoryPhotoError.unreadable, e);
  }
  return decodeStoryPhoto(bytes);
}

/// The app logo for the story's brand layer, decoded once and kept for the
/// app's lifetime (it is small). Null if the asset can't be read, in which
/// case the brand falls back to a dot.
Future<ui.Image?> loadStoryLogo() => _logo ??= _decodeLogo();

Future<ui.Image?>? _logo;

Future<ui.Image?> _decodeLogo() async {
  try {
    final data = await rootBundle.load('lib/assets/fitnessTrackerLogo.png');
    return await decodeStoryPhoto(data.buffer.asUint8List(), maxSide: 384);
  } catch (_) {
    _logo = null;
    return null;
  }
}
