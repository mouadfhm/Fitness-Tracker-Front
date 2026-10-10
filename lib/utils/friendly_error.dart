import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
String friendlyError(Object error, {String fallback = 'Please try again.'}) {
  debugPrint('friendlyError: $error');
  if (error is UserFacingException) return error.message;
  if (error is http.ClientException || error is TimeoutException) {
    return "Can't reach the server. Check your internet connection and try again.";
  }
  final text = error.toString();
  if (text.contains('Session expired') || text.contains('No authentication token')) {
    return 'Your session has ended. Please log in again.';
  }
  if (text.contains('SocketException') ||
      text.contains('Failed host lookup') ||
      text.contains('Connection refused') ||
      text.contains('Network is unreachable')) {
    return "Can't reach the server. Check your internet connection and try again.";
  }
  return fallback;
}
