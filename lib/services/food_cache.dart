import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// The last food list the server sent, one file per language, so the Foods
/// tab shows it at once instead of waiting for ~17k foods on a slow network.
/// The ETag goes next to it: the server answers 304 while the list is the
/// same. Cleared on logout, since favourites and own foods are per account.
class FoodCache {
  static Future<Directory> _dir() async =>
      Directory('${(await getApplicationSupportDirectory()).path}/food_cache');

  static Future<File> _body(String language) async =>
      File('${(await _dir()).path}/foods_$language.json');

  static Future<File> _etag(String language) async =>
      File('${(await _dir()).path}/foods_$language.etag');

  /// The saved list and its ETag, or null when there is none.
  static Future<({String body, String? etag})?> read(String language) async {
    if (kIsWeb) return null;
    try {
      final body = await _body(language);
      if (!await body.exists()) return null;
      final etag = await _etag(language);
      return (
        body: await body.readAsString(),
        etag: await etag.exists() ? await etag.readAsString() : null,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(String language, String body, String? etag) async {
    if (kIsWeb) return;
    try {
      await (await _dir()).create(recursive: true);
      // Written aside, then renamed, so a killed app never leaves half a list.
      final file = await _body(language);
      final temp = File('${file.path}.tmp');
      await temp.writeAsString(body, flush: true);
      await temp.rename(file.path);
      final etagFile = await _etag(language);
      if (etag != null) {
        await etagFile.writeAsString(etag);
      } else if (await etagFile.exists()) {
        await etagFile.delete();
      }
    } catch (_) {
      // Only a cache: the next start downloads the list again.
    }
  }

  static Future<void> clear() async {
    if (kIsWeb) return;
    try {
      final dir = await _dir();
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {}
  }
}
