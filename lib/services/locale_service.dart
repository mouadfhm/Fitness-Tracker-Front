import 'package:http/http.dart' as http;

/// Holds the current language code for code that has no `BuildContext`
/// (request headers, label helpers). `LocaleProvider` and `MaterialApp`'s
/// builder keep it in step with the language on screen.
class LocaleService {
  static String languageCode = 'en';
}

/// Adds `Accept-Language` to every request, so the backend returns food,
/// activity, exercise and achievement names in the app's language (its
/// `SetLocale` middleware reads this header).
///
/// `main` installs it with `http.runWithClient`, which covers every top-level
/// `http.get`/`post`/... call without touching each one.
class LocaleHeaderClient extends http.BaseClient {
  LocaleHeaderClient([http.Client? inner]) : _inner = inner ?? http.Client();

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.putIfAbsent('Accept-Language', () => LocaleService.languageCode);
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
