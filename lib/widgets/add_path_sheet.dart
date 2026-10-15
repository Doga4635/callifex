import 'package:flutter/material.dart';

class AddPathRequest {
  const AddPathRequest({
    required this.track,
    required this.level,
    required this.duration,
  });

  final String track;
  final String level;
  final String duration;
}

Future<AddPathRequest?> showAddPathSheet(
  BuildContext context, {
  required List<String> tracks,
  required List<String> levels,
  required List<String> durations,
}) {
  return showModalBottomSheet<AddPathRequest>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _AddPathSheet(
      tracks: tracks,
      levels: levels,
      durations: durations,
    ),
  );
}

class _AddPathSheet extends StatefulWidget {
  const _AddPathSheet({
    required this.tracks,
    required this.levels,
    required this.durations,
  });

  final List<String> tracks;
  final List<String> levels;
  final List<String> durations;

  @override
  State<_AddPathSheet> createState() => _AddPathSheetState();
}

class _AddPathSheetState extends State<_AddPathSheet> {
  String? _track;
  String? _level;
  String? _duration;

  @override
  void initState() {
    super.initState();
    _track = widget.tracks.firstOrNull;
    _level = widget.levels.firstOrNull;
    _duration = widget.durations.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          8,
          22,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Öğrenme yolu ekle',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hedeflerine uygun alan, zorluk ve süreyi seç.',
              style: TextStyle(color: Color(0xFF70716C)),
            ),
            const SizedBox(height: 20),
            _buildDropdown(
              label: 'Sektör',
              value: _track,
              options: widget.tracks,
              onChanged: (value) => setState(() => _track = value),
            ),
            const SizedBox(height: 14),
            _buildDropdown(
              label: 'Zorluk',
              value: _level,
              options: widget.levels,
              onChanged: (value) => setState(() => _level = value),
            ),
            const SizedBox(height: 14),
            _buildDropdown(
              label: 'Ayırabileceğin toplam süre',
              value: _duration,
              options: widget.durations,
              onChanged: (value) => setState(() => _duration = value),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _canSubmit
                  ? () => Navigator.of(context).pop(
                        AddPathRequest(
                          track: _track!,
                          level: _level!,
                          duration: _duration!,
                        ),
                      )
                  : null,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Bu yolu ekle'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canSubmit =>
      _track != null && _level != null && _duration != null;

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(growable: false),
      onChanged: options.isEmpty ? null : onChanged,
    );
  }
}
