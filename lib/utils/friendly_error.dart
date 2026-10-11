import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'l10n.dart';

/// An error whose message is already written for the person using the app,
/// e.g. "Wrong email or password." Thrown by [ApiService] when the server
/// gives us something we can explain.
class UserFacingException implements Exception {
  final String message;
  const UserFacingException(this.message);

  @override
  String toString() => message;
}

/// Turns any error into one short, plain sentence that is safe to show.
///
/// The raw error is still printed in debug builds so developers keep the
/// details; users never see stack traces, HTTP bodies or exception class names.
String friendlyError(Object error, {String? fallback}) {
  debugPrint('friendlyError: $error');
  final l = appL10n;
  if (error is UserFacingException) return error.message;
  if (error is http.ClientException || error is TimeoutException) {
    return l.errorNoConnection;
  }
  final text = error.toString();
  if (text.contains('Session expired') || text.contains('No authentication token')) {
    return l.errorSessionEnded;
  }
  if (text.contains('SocketException') ||
      text.contains('Failed host lookup') ||
      text.contains('Connection refused') ||
      text.contains('Network is unreachable')) {
    return l.errorNoConnection;
  }
  return fallback ?? l.errorTryAgain;
}
