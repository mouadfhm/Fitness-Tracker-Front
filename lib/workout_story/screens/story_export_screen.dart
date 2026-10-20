import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/friendly_error.dart';
import '../services/story_export_actions.dart';
import '../story_theme.dart';

/// The final image, exactly as exported, with save and share. Pops with
/// `true` when the user is done, so the editor closes too.
class StoryExportScreen extends StatefulWidget {
  const StoryExportScreen({super.key, required this.png, required this.actions});

  final Uint8List png;
  final StoryExportActions actions;

  @override
  State<StoryExportScreen> createState() => _StoryExportScreenState();
}

class _StoryExportScreenState extends State<StoryExportScreen> {
  bool _saving = false;
  bool _sharing = false;
  bool _saved = false;
  final _shareKey = GlobalKey();

  @override
  void dispose() {
    widget.actions.dispose();
    super.dispose();
  }

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: error ? scheme.error : null),
      );
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      final outcome = await widget.actions.saveToGallery(widget.png);
      if (!mounted) return;
      switch (outcome) {
        case StorySaveOutcome.saved:
          setState(() => _saved = true);
          _snack(l10n.storySaved);
        case StorySaveOutcome.denied:
          _snack(l10n.storySaveDenied, error: true);
        case StorySaveOutcome.noSpace:
          _snack(l10n.storyNotEnoughSpace, error: true);
      }
    } catch (e) {
      _snack(l10n.storySaveFailed(friendlyError(e)), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _share() async {
    if (_sharing) return;
    final l10n = AppLocalizations.of(context)!;
    // iPad anchors the share sheet to the button.
    final box = _shareKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    setState(() => _sharing = true);
    try {
      final outcome = await widget.actions.share(widget.png, origin: origin);
      if (outcome == StoryShareOutcome.unavailable) {
        _snack(l10n.storyShareUnavailable, error: true);
      }
      // Dismissed: the user changed their mind; nothing to say.
    } catch (e) {
      _snack(l10n.storyShareFailed(friendlyError(e)), error: true);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(data: storyEditorTheme(), child: Builder(builder: _build));
  }

  Widget _build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Widget spinner() =>
        const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.storyExportTitle),
        actions: [
          TextButton(
            key: const ValueKey('story-done'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.storyDone),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Semantics(
                        image: true,
                        label: l10n.storyExportTitle,
                        child: Image.memory(
                          widget.png,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('story-save'),
                      onPressed: _saving ? null : _save,
                      icon:
                          _saving
                              ? spinner()
                              : Icon(_saved ? Icons.check : Icons.download_outlined),
                      label: Text(l10n.storySave, maxLines: 1, overflow: TextOverflow.ellipsis),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      key: _shareKey,
                      onPressed: _sharing ? null : _share,
                      icon: _sharing ? spinner() : const Icon(Icons.ios_share),
                      label: Text(l10n.storyShare, maxLines: 1, overflow: TextOverflow.ellipsis),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
