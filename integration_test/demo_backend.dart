import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'demo_data.dart';

/// A stand-in for the Laravel API that answers the app's requests with the
/// demo account in demo_data.dart, so the screenshots never touch the real
/// server or a real account.
///
/// It listens on a fixed port on the simulator's loopback, which is the Mac's
/// own loopback, so the workflow can also use it to hear when a screen is
/// ready: it polls `GET /__pending` for the name of the screenshot to take
/// and answers with `POST /__done` once the PNG is saved.
class DemoBackend {
  DemoBackend._(this._server, this._data, this._dayShift, this._language);

  static const port = 8787;

  final HttpServer _server;
  final Map<String, dynamic> _data;
  final int _dayShift;

  /// For requests without Accept-Language: main() adds it through
  /// http.runWithClient, which the test doesn't go through.
  final String _language;

  String? _pending;
  Completer<void>? _shotTaken;

  String get baseUrl => 'http://127.0.0.1:$port/api';

  static Future<DemoBackend> start({String language = 'en'}) async {
    final captured = DateTime.parse(demoDataCapturedOn);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final shift = today.difference(captured).inDays;
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    final backend = DemoBackend._(
      server,
      jsonDecode(demoDataJson) as Map<String, dynamic>,
      shift,
      language,
    );
    server.listen(backend._handle);
    return backend;
  }

  Future<void> close() => _server.close(force: true);

  /// Asks the workflow for a screenshot of what is on screen now and waits
  /// until it is saved. Without a workflow polling (a local run), it gives
  /// up after [timeout] so the test still finishes.
  Future<void> screenshot(
    String name, {
    Duration timeout = const Duration(seconds: 90),
  }) async {
    _pending = name;
    _shotTaken = Completer<void>();
    try {
      await _shotTaken!.future.timeout(timeout);
    } on TimeoutException {
      // ignore: avoid_print
      print('No screenshot taken for $name (nothing polled /__pending).');
    } finally {
      _pending = null;
    }
  }

  Future<void> _handle(HttpRequest request) async {
    final path = request.uri.path;
    final body = await utf8.decodeStream(request);
    if (path == '/__pending') {
      return _send(request, 200, _pending ?? '', raw: true);
    }
    if (path == '/__done') {
      _shotTaken?.complete();
      return _send(request, 200, 'ok', raw: true);
    }

    final lang =
        (request.headers.value('accept-language') ?? _language).startsWith('fr')
            ? 'fr'
            : 'en';
    final data = _data[lang] as Map<String, dynamic>;
    final route = '${request.method} ${path.replaceFirst('/api', '')}';
    final customWorkout = RegExp(
      r'^GET /v2/workouts/custom-workouts/(\d+)$',
    ).firstMatch(route);

    Object? response;
    if (customWorkout != null) {
      final id = int.parse(customWorkout.group(1)!);
      response = (data['custom'] as List).firstWhere(
        (w) => w['id'] == id,
        orElse: () => null,
      );
    } else {
      response = switch (route) {
        'GET /profile' => data['profile'],
        'GET /goals/search' => data['goal'],
        'GET /meals/search' => data['meals'],
        'GET /meals/macros' => data['macros'],
        'POST /workouts/calories-burned' => _burned(data, body),
        'GET /workouts/search' => data['workouts_v1'],
        'GET /workouts/exercises' => data['activities'],
        'GET /foods/search' => data['foods'],
        'GET /v2/workouts/exercises/search' => data['gym'],
        'GET /v2/workouts/custom-workouts' => data['custom'],
        'GET /v2/workouts/weekly-cycle-plans' => _weeklyPlan(data),
        'GET /v2/workouts/weekly-cycle-plans/saved' => data['saved'],
        'GET /achievements' => data['achievements'],
        'GET /user/achievements' => data['user_achievements'],
        'GET /progress' => data['progress'],
        'GET /notification-preferences' => data['notif'],
        'POST /save-device-token' => {'message': 'ok'},
        _ => null,
      };
    }
    if (response == null) {
      // ignore: avoid_print
      print('DemoBackend: no demo data for $route');
      return _send(request, 404, {'message': 'Not in the demo data.'});
    }
    // The weekly plan is built around today already.
    return _send(
      request,
      200,
      response,
      shiftDates: route != 'GET /v2/workouts/weekly-cycle-plans',
    );
  }

  Object _burned(Map<String, dynamic> data, String body) {
    final date =
        (jsonDecode(body.isEmpty ? '{}' : body) as Map)['workout_date'];
    return date == _ymd(DateTime.now()) ? data['burned'] : 0;
  }

  /// The four workouts on a weekly cycle that always has one today, laid out
  /// the way WeeklyCyclePlanController@index returns it: a list of weeks, each
  /// with all seven days.
  Map<String, dynamic> _weeklyPlan(Map<String, dynamic> data) {
    final workouts = (data['custom'] as List).cast<Map<String, dynamic>>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Days after today that get each workout, in order.
    const offsets = [0, 1, 3, 5];
    final byDate = <String, Map<String, dynamic>>{};
    var id = 1;
    for (var week = -1; week <= 2; week++) {
      for (var i = 0; i < offsets.length; i++) {
        final day = DateTime(
          today.year,
          today.month,
          today.day + week * 7 + offsets[i],
        );
        final w = workouts[i % workouts.length];
        byDate[_ymd(day)] = {
          'id': id++,
          'user_id': 1,
          'workout_id': w['id'],
          'scheduled_at': '${_ymd(day)} 00:00:00',
          'workout': {
            'id': w['id'],
            'user_id': 1,
            'name': w['name'],
            'description': w['description'],
          },
        };
      }
    }
    const keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final thisMonday = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday - 1),
    );
    final weeks = [
      for (var week = -1; week <= 2; week++)
        () {
          final monday = DateTime(
            thisMonday.year,
            thisMonday.month,
            thisMonday.day + week * 7,
          );
          return {
            'week_start': _ymd(monday),
            'week_end': _ymd(
              DateTime(monday.year, monday.month, monday.day + 6),
            ),
            'days': {
              for (var d = 0; d < 7; d++)
                keys[d]: () {
                  final date = _ymd(
                    DateTime(monday.year, monday.month, monday.day + d),
                  );
                  return {
                    'date': date,
                    'workouts': [if (byDate[date] != null) byDate[date]],
                  };
                }(),
            },
          };
        }(),
    ];
    return {'weeks': weeks};
  }

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static final _date = RegExp(r'\b(\d{4})-(\d{2})-(\d{2})');

  /// Moves every date in the demo data forward to line up with today.
  String _shiftDates(String json) => json.replaceAllMapped(_date, (m) {
    final d = DateTime(
      int.parse(m[1]!),
      int.parse(m[2]!),
      int.parse(m[3]!) + _dayShift,
    );
    return _ymd(d);
  });

  Future<void> _send(
    HttpRequest request,
    int status,
    Object body, {
    bool raw = false,
    bool shiftDates = true,
  }) async {
    request.response.statusCode = status;
    request.response.headers.contentType =
        raw ? ContentType.text : ContentType.json;
    final text = raw ? body as String : jsonEncode(body);
    request.response.write(shiftDates && !raw ? _shiftDates(text) : text);
    await request.response.close();
  }
}
