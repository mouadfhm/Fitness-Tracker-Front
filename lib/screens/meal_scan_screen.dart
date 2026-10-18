import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/food.dart';
import '../providers/food_provider.dart';
import '../services/api_service.dart';
import '../services/meal_detector.dart';
import '../utils/app_theme.dart';
import '../utils/food_search.dart';
import '../utils/friendly_error.dart';
import '../utils/labels.dart';

/// Point the camera at a plate: each food it recognises gets a label over the
/// preview with its estimated portion, and the meal builds up underneath.
/// Tap a label or a row to fix the portion or swap the food, add anything the
/// camera missed, then log it all to a meal in one go.
///
/// Scanning runs on its own and pauses once the foods stop changing, so a
/// still plate doesn't keep sending frames.
class MealScanScreen extends StatefulWidget {
  /// Finds the foods in each frame. Defaults to the backend's scanner.
  final MealDetector? detector;

  /// Shown instead of the live camera (screenshots, or a device with no
  /// camera).
  final ImageProvider? stillImage;

  /// Foods offered for "change" and "add". Defaults to the food list.
  final List<Food>? foods;

  const MealScanScreen({super.key, this.detector, this.stillImage, this.foods});

  @override
  State<MealScanScreen> createState() => _MealScanScreenState();
}

/// One food in the meal being built.
class _MealItem {
  final int key;
  Food food;
  double grams;

  /// Where it is in the frame (0..1), or null for foods added by hand.
  Rect? box;
  double confidence;

  /// Once the person sets the portion or the food, new frames stop changing
  /// it.
  bool edited = false;

  /// Frames in a row that no longer showed it.
  int missed = 0;

  _MealItem({
    required this.key,
    required this.food,
    required this.grams,
    this.box,
    this.confidence = 1,
  });

  bool get isUnsure => !edited && confidence < FoodDetection.unsureBelow;
  double get kcal => food.calories * grams / 100;
  double get protein => food.protein * grams / 100;
  double get carbs => food.carbs * grams / 100;
  double get fats => food.fats * grams / 100;
}

class _MealScanScreenState extends State<MealScanScreen>
    with SingleTickerProviderStateMixin {
  static const _scanEvery = Duration(milliseconds: 1500);

  /// Scans in a row with no new food before scanning pauses itself.
  static const _stableScansToPause = 3;

  /// Frames per run at most, so a camera pointed at no food (or at a plate
  /// that keeps changing) stops sending frames; each one is a paid call.
  static const _maxScansPerRun = 20;

  /// Failed frames in a row before scanning gives up and says so.
  static const _failuresToPause = 3;

  /// Colours for the items, readable as white text's background and as a
  /// thin outline on any photo.
  static const _palette = [
    Color(0xFF26A69A),
    Color(0xFFFF7043),
    Color(0xFF5C6BC0),
    Color(0xFFFFB300),
    Color(0xFFEC407A),
    Color(0xFF66BB6A),
    Color(0xFF29B6F6),
    Color(0xFFAB47BC),
  ];

  late final MealDetector _detector = widget.detector ?? ApiMealDetector();
  CameraController? _camera;
  String? _cameraError;
  Size? _frameSize;

  final List<_MealItem> _items = [];

  /// Boxes of foods the person removed, so the next frames don't add them back.
  final List<Rect> _dismissed = [];
  int _nextKey = 0;
  int _stableScans = 0;
  int _scansThisRun = 0;
  int _failures = 0;

  /// Why scanning stopped on its own, shown under the meal title.
  String Function(AppLocalizations)? _scanProblem;
  bool _scanning = true;
  bool _busy = false;
  bool _saving = false;
  Timer? _timer;
  String _mealTime = mealTimeForNow();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    if (widget.stillImage != null) {
      _resolveStillSize(widget.stillImage!);
    } else {
      _startCamera();
    }
    _timer = Timer.periodic(_scanEvery, (_) => _scanFrame());
    // First scan straight away rather than after one interval.
    WidgetsBinding.instance.addPostFrameCallback((_) => _scanFrame());
  }

  void _resolveStillSize(ImageProvider image) {
    image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((info, _) {
        if (!mounted) return;
        setState(() => _frameSize = Size(
              info.image.width.toDouble(),
              info.image.height.toDouble(),
            ));
      }),
    );
  }

  Future<void> _startCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw CameraException('none', 'No camera');
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      final preview = controller.value.previewSize!;
      setState(() {
        _camera = controller;
        // previewSize is in landscape; the screen is portrait.
        _frameSize = Size(
          math.min(preview.width, preview.height),
          math.max(preview.width, preview.height),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraError = friendlyError(e);
        _scanning = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    _camera?.dispose();
    super.dispose();
  }

  Future<void> _scanFrame() async {
    if (!_scanning || _busy || !mounted) return;
    final camera = _camera;
    if (widget.stillImage == null &&
        (camera == null || !camera.value.isInitialized)) {
      return;
    }
    _busy = true;
    _scansThisRun++;
    try {
      final bytes = camera != null
          ? await (await camera.takePicture()).readAsBytes()
          : Uint8List(0);
      final detections = await _detector.detect(bytes);
      if (!mounted || !_scanning) return;
      setState(() {
        _failures = 0;
        _merge(detections);
        if (_scanning && _scansThisRun >= _maxScansPerRun) _setScanning(false);
      });
    } on MealScanUnavailable {
      if (!mounted) return;
      setState(() {
        _scanProblem = (l10n) => l10n.mealScanUnavailable;
        _setScanning(false);
      });
    } catch (e) {
      debugPrint('Meal scan frame failed: $e');
      if (!mounted) return;
      if (++_failures >= _failuresToPause) {
        setState(() {
          _scanProblem = (l10n) => l10n.mealScanFailed;
          _setScanning(false);
        });
      }
    } finally {
      _busy = false;
    }
  }

  /// Folds one frame's detections into the meal: known foods move and settle
  /// their portions, new foods are added, foods gone for a few frames go
  /// unless the person already touched them.
  void _merge(List<FoodDetection> detections) {
    var added = false;
    final seen = <_MealItem>{};
    for (final d in detections) {
      if (_dismissed.any((r) => _overlap(r, d.box) > 0.5)) continue;
      _MealItem? match;
      var best = 0.3;
      for (final item in _items) {
        if (item.box == null || seen.contains(item)) continue;
        final score =
            _overlap(item.box!, d.box) + (_sameFood(item.food, d.food) ? 0.5 : 0);
        if (score > best) {
          best = score;
          match = item;
        }
      }
      if (match == null) {
        _items.add(_MealItem(
          key: _nextKey++,
          food: d.food,
          grams: d.grams,
          box: d.box,
          confidence: d.confidence,
        ));
        added = true;
        continue;
      }
      seen.add(match);
      match.missed = 0;
      match.box = Rect.lerp(match.box, d.box, 0.5);
      if (!match.edited) {
        match.food = d.food;
        // Smooth the estimate so the number doesn't jump every frame.
        match.grams = (match.grams * 0.6 + d.grams * 0.4).roundToDouble();
        match.confidence = d.confidence;
      }
    }
    for (final item in _items) {
      if (item.box != null && !seen.contains(item)) item.missed++;
    }
    _items.removeWhere((i) => !i.edited && i.box != null && i.missed >= 3);

    _stableScans = added ? 0 : _stableScans + 1;
    if (_stableScans >= _stableScansToPause && _items.isNotEmpty) {
      _setScanning(false);
    }
  }

  /// Foods missing from the foods table all have id 0, so compare those by
  /// name.
  bool _sameFood(Food a, Food b) =>
      a.id > 0 ? a.id == b.id : b.id <= 0 && a.name == b.name;

  /// Intersection over union of two boxes.
  double _overlap(Rect a, Rect b) {
    final i = a.intersect(b);
    if (i.width <= 0 || i.height <= 0) return 0;
    final inter = i.width * i.height;
    return inter / (a.width * a.height + b.width * b.height - inter);
  }

  void _setScanning(bool on) {
    _scanning = on;
    _stableScans = 0;
    if (on) {
      _scansThisRun = 0;
      _failures = 0;
      _scanProblem = null;
    }
    final camera = _camera;
    if (camera != null && camera.value.isInitialized) {
      on ? camera.resumePreview() : camera.pausePreview();
    }
  }

  Color _colorOf(_MealItem item) => _palette[item.key % _palette.length];

  List<Food> get _foods =>
      widget.foods ?? Provider.of<FoodProvider>(context, listen: false).foods;

  Future<void> _editItem(_MealItem item) async {
    final result = await showModalBottomSheet<_EditResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PortionSheet(
        food: item.food,
        grams: item.grams,
        color: _colorOf(item),
        pickFood: () => _pickFood(),
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      if (result.remove) {
        _items.remove(item);
        if (item.box != null) _dismissed.add(item.box!);
        return;
      }
      item
        ..food = result.food
        ..grams = result.grams
        ..edited = true;
    });
  }

  Future<Food?> _pickFood() => showModalBottomSheet<Food>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _FoodPickerSheet(foods: _foods),
      );

  Future<void> _addItem() async {
    final food = await _pickFood();
    if (!mounted || food == null) return;
    final item = _MealItem(key: _nextKey++, food: food, grams: 100)..edited = true;
    setState(() => _items.add(item));
    // Straight to the portion, which is the next thing anyone changes.
    await _editItem(item);
  }

  Future<void> _logMeal() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _saving = true;
      _setScanning(false);
    });
    final api = ApiService();
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var count = 0;
    var kcal = 0.0;
    try {
      // One at a time, dropping each from the list once logged, so a retry
      // after a failure doesn't log the first foods twice.
      while (_items.isNotEmpty) {
        final item = _items.first;
        final foodId = item.food.id > 0 ? item.food.id : await _saveNewFood(api, item.food);
        await api.storeMeal(
          item.food.name,
          item.grams.roundToDouble(),
          _mealTime,
          date,
          foodId: foodId,
        );
        count++;
        kcal += item.kcal;
        if (mounted) setState(() => _items.remove(item));
      }
      if (!mounted) return;
      Navigator.pop(
        context,
        l10n.mealScanLogged(count, mealTimeLabel(_mealTime), kcal.round()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mealScanLogFailed(friendlyError(e)))),
      );
    }
  }

  /// A food the foods table didn't have is added as the user's own food,
  /// with the scanner's estimate per 100 g, so the meal can point at it.
  /// When one by that name already exists, the meal is logged by name.
  Future<int?> _saveNewFood(ApiService api, Food food) async {
    try {
      final saved = await api.addFood(food.name, food.calories, food.protein, food.carbs, food.fats);
      final id = (saved['food'] as Map?)?['id'];
      return id is int ? id : int.tryParse('$id');
    } catch (e) {
      debugPrint('Saving scanned food failed, logging it by name: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // The panel starts at this share of the screen; the preview fills the rest
    // so labels are never hidden under it.
    const panelShare = 0.42;
    final previewHeight =
        media.size.height * (1 - panelShare) + AppTheme.cardRadius;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox(
            height: previewHeight,
            width: double.infinity,
            child: _buildPreview(),
          ),
          Positioned(
            top: media.padding.top + 8,
            left: 12,
            right: 12,
            child: _buildTopBar(),
          ),
          DraggableScrollableSheet(
            initialChildSize: panelShare,
            minChildSize: panelShare,
            maxChildSize: 0.9,
            snap: true,
            builder: (context, controller) => _buildPanel(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final l10n = AppLocalizations.of(context)!;
    if (_cameraError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.mealScanNoCamera,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    final frame = _frameSize;
    if (frame == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    final camera = _camera;
    final Widget picture = camera != null
        ? CameraPreview(camera)
        : Image(image: widget.stillImage!, fit: BoxFit.fill);

    return LayoutBuilder(
      builder: (context, constraints) {
        final view = constraints.biggest;
        // Cover the area like a camera app, and map each item's 0..1 box
        // through the same scale and crop.
        final scale =
            math.max(view.width / frame.width, view.height / frame.height);
        final shown = Size(frame.width * scale, frame.height * scale);
        final offset = Offset(
          (view.width - shown.width) / 2,
          (view.height - shown.height) / 2,
        );
        Rect toView(Rect box) => Rect.fromLTWH(
              offset.dx + box.left * shown.width,
              offset.dy + box.top * shown.height,
              box.width * shown.width,
              box.height * shown.height,
            );

        final boxed = _items.where((i) => i.box != null).toList();
        return ClipRect(
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                top: offset.dy,
                width: shown.width,
                height: shown.height,
                child: picture,
              ),
              // Darken slightly so labels read on bright food.
              Positioned.fill(
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.12)),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _BoxPainter([
                    for (final item in boxed)
                      (toView(item.box!), _colorOf(item), item.isUnsure),
                  ]),
                ),
              ),
              for (final item in boxed)
                _buildLabel(item, toView(item.box!), view),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(_MealItem item, Rect box, Size view) {
    const width = 150.0;
    const height = 36.0;
    // Centre on the food, kept inside the visible area and clear of the top
    // bar.
    final left = (box.center.dx - width / 2).clamp(8.0, view.width - width - 8);
    final top = (box.center.dy - height / 2)
        .clamp(MediaQuery.of(context).padding.top + 64, view.height - height - 28);
    final color = _colorOf(item);
    return AnimatedPositioned(
      key: ValueKey(item.key),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      left: left,
      top: top,
      width: width,
      height: height,
      child: Center(
        child: GestureDetector(
          onTap: () => _editItem(item),
          child: Container(
            padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(height / 2),
              border: Border.all(
                color: item.isUnsure ? const Color(0xFFFFC107) : color,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 5, backgroundColor: color),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${item.food.name}${item.isUnsure ? ' ?' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${item.grams.round()} g',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final l10n = AppLocalizations.of(context)!;
    final scanning = _scanning && _cameraError == null;
    Widget round(IconData icon, String tooltip, VoidCallback onTap) => Material(
          color: Colors.black.withValues(alpha: 0.45),
          shape: const CircleBorder(),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            tooltip: tooltip,
            onPressed: onTap,
          ),
        );

    return Row(
      children: [
        round(Icons.close, l10n.cancel, () => Navigator.pop(context)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: scanning
                    ? Tween(begin: 0.3, end: 1.0).animate(_pulse)
                    : const AlwaysStoppedAnimation(1),
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor:
                      scanning ? const Color(0xFFFF5252) : Colors.white54,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                scanning ? l10n.mealScanScanning : l10n.mealScanPaused,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (_cameraError == null)
          round(
            _scanning ? Icons.pause : Icons.center_focus_strong,
            _scanning ? l10n.mealScanPause : l10n.mealScanRescan,
            () => setState(() => _setScanning(!_scanning)),
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildPanel(ScrollController controller) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final kcal = _items.fold<double>(0, (s, i) => s + i.kcal);
    final protein = _items.fold<double>(0, (s, i) => s + i.protein);
    final carbs = _items.fold<double>(0, (s, i) => s + i.carbs);
    final fats = _items.fold<double>(0, (s, i) => s + i.fats);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppTheme.cardRadius + 8)),
      ),
      child: ListView(
        controller: controller,
        padding: EdgeInsets.fromLTRB(
          16,
          10,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.mealScanTitle, style: theme.textTheme.titleMedium),
                    Text(
                      _scanProblem?.call(l10n) ??
                          (_items.isEmpty
                              ? l10n.mealScanLooking
                              : l10n.mealScanItemCount(_items.length)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _scanProblem != null ? scheme.error : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                l10n.mealScanKcal(kcal.round()),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _macroBadge(l10n.homeMacroProtein, protein, Colors.red.shade400),
              const SizedBox(width: 8),
              _macroBadge(l10n.homeMacroCarbs, carbs, Colors.amber.shade700),
              const SizedBox(width: 8),
              _macroBadge(l10n.homeMacroFat, fats, Colors.blue.shade400),
            ],
          ),
          const SizedBox(height: 12),
          if (_items.isNotEmpty)
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final (i, item) in _items.indexed) ...[
                    if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildRow(item),
                  ],
                ],
              ),
            ),
          if (_items.any((i) => i.isUnsure)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.help_outline, size: 16, color: Color(0xFFFFA000)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.mealScanUnsureHint,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
            label: Text(l10n.mealScanAddItem),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final time in mainMealTimes)
                ChoiceChip(
                  label: Text(mealTimeLabel(time)),
                  showCheckmark: false,
                  selected: _mealTime == time,
                  onSelected: (_) => setState(() => _mealTime = time),
                ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _items.isEmpty || _saving ? null : _logMeal,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _saving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.mealScanLogTo(mealTimeLabel(_mealTime))),
          ),
        ],
      ),
    );
  }

  Widget _macroBadge(String label, double grams, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '${grams.round()} g',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(_MealItem item) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: () => _editItem(item),
      leading: CircleAvatar(radius: 7, backgroundColor: _colorOf(item)),
      minLeadingWidth: 14,
      title: Text(item.food.name),
      subtitle: Text(
        item.isUnsure
            ? l10n.mealScanRowUnsure(item.grams.round())
            : l10n.mealScanRow(item.grams.round(), item.kcal.round()),
        style: item.isUnsure ? const TextStyle(color: Color(0xFFE69500)) : null,
      ),
      trailing: Icon(Icons.edit_outlined, size: 20, color: scheme.onSurfaceVariant),
    );
  }
}

/// Thin corner marks around each food, in its colour (amber when unsure).
class _BoxPainter extends CustomPainter {
  final List<(Rect, Color, bool)> boxes;

  _BoxPainter(this.boxes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final (rect, color, unsure) in boxes) {
      final r = rect.deflate(6);
      final arm = math.min(18.0, math.min(r.width, r.height) / 4);
      final paint = Paint()
        ..color = unsure ? const Color(0xFFFFC107) : color
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      for (final (corner, dx, dy) in [
        (r.topLeft, 1.0, 1.0),
        (r.topRight, -1.0, 1.0),
        (r.bottomLeft, 1.0, -1.0),
        (r.bottomRight, -1.0, -1.0),
      ]) {
        canvas.drawPath(
          Path()
            ..moveTo(corner.dx + dx * arm, corner.dy)
            ..lineTo(corner.dx, corner.dy)
            ..lineTo(corner.dx, corner.dy + dy * arm),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BoxPainter old) => true;
}

class _EditResult {
  final Food food;
  final double grams;
  final bool remove;

  _EditResult(this.food, this.grams, {this.remove = false});
}

/// Change one food's portion, swap it for another food, or remove it.
class _PortionSheet extends StatefulWidget {
  final Food food;
  final double grams;
  final Color color;
  final Future<Food?> Function() pickFood;

  const _PortionSheet({
    required this.food,
    required this.grams,
    required this.color,
    required this.pickFood,
  });

  @override
  State<_PortionSheet> createState() => _PortionSheetState();
}

class _PortionSheetState extends State<_PortionSheet> {
  /// The slider covers 0..500 g, or twice the starting portion for big ones,
  /// so a usual portion sits mid-track rather than squeezed at one end.
  late final double _max = math.max(500, (widget.grams * 2 / 50).ceil() * 50.0);
  late Food _food = widget.food;
  late double _grams = widget.grams;

  void _setGrams(double g) => setState(() => _grams = g.clamp(0, _max).roundToDouble());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final f = _grams / 100;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 7, backgroundColor: widget.color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_food.name, style: theme.textTheme.titleLarge),
              ),
              TextButton.icon(
                onPressed: () async {
                  final picked = await widget.pickFood();
                  if (picked != null && mounted) setState(() => _food = picked);
                },
                icon: const Icon(Icons.swap_horiz),
                label: Text(l10n.mealScanChangeFood),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.outlined(
                onPressed: () => _setGrams(_grams - 10),
                icon: const Icon(Icons.remove),
                tooltip: '-10 g',
              ),
              SizedBox(
                width: 140,
                child: Text(
                  '${_grams.round()} g',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton.outlined(
                onPressed: () => _setGrams(_grams + 10),
                icon: const Icon(Icons.add),
                tooltip: '+10 g',
              ),
            ],
          ),
          Slider(
            value: _grams,
            max: _max,
            divisions: (_max / 5).round(),
            onChanged: _setGrams,
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in const [50, 100, 150, 200])
                ChoiceChip(
                  label: Text('$g g'),
                  selected: _grams.round() == g,
                  onSelected: (_) => _setGrams(g.toDouble()),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: AppTheme.cardDecoration(context),
            child: Row(
              children: [
                _stat(l10n.homeMacroCalories, '${(_food.calories * f).round()}', scheme.primary),
                _stat(l10n.homeMacroProtein, '${(_food.protein * f).round()} g', Colors.red.shade400),
                _stat(l10n.homeMacroCarbs, '${(_food.carbs * f).round()} g', Colors.amber.shade700),
                _stat(l10n.homeMacroFat, '${(_food.fats * f).round()} g', Colors.blue.shade400),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context, _EditResult(_food, _grams, remove: true)),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.mealScanRemove),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.error,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _grams <= 0
                      ? null
                      : () => Navigator.pop(context, _EditResult(_food, _grams)),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: Text(l10n.mealScanDone),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Expanded(
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.bodySmall, maxLines: 1),
          ],
        ),
      );
}

/// Search the food list and pick one.
class _FoodPickerSheet extends StatefulWidget {
  final List<Food> foods;

  const _FoodPickerSheet({required this.foods});

  @override
  State<_FoodPickerSheet> createState() => _FoodPickerSheetState();
}

class _FoodPickerSheetState extends State<_FoodPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final results = searchFoods(widget.foods, _query, (f) => f.name).take(60).toList();
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                hintText: l10n.foodsSearchFoodsHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (q) => setState(() => _query = q),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: results.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, i) {
                final food = results[i];
                return ListTile(
                  title: Text(food.name),
                  subtitle: Text(l10n.foodsKcalPer100g(food.calories.round())),
                  trailing: Icon(Icons.add_circle_outline, color: scheme.primary),
                  onTap: () => Navigator.pop(context, food),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
