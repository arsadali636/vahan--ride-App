import 'package:flutter/material.dart';

import '../../../../design_system/components/app_text_field.dart';
import '../../../../design_system/components/outline_button.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/spacing/app_spacing.dart';

/// Chips editor for a list of free-text tags (clinical interests).
///
/// New values are added through the trailing text field; existing tags are
/// removed by tapping the chip's close icon.
class ClinicalInterestsEditor extends StatefulWidget {
  final List<String> initial;
  final ValueChanged<List<String>> onChanged;

  const ClinicalInterestsEditor({
    super.key,
    this.initial = const [],
    required this.onChanged,
  });

  @override
  State<ClinicalInterestsEditor> createState() =>
      _ClinicalInterestsEditorState();
}

class _ClinicalInterestsEditorState extends State<ClinicalInterestsEditor> {
  late final List<String> _interests;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _interests = List.of(widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final value = _controller.text.trim();
    if (value.isEmpty || _interests.contains(value)) {
      _controller.clear();
      return;
    }
    setState(() {
      _interests.add(value);
      _controller.clear();
    });
    widget.onChanged(_interests);
  }

  void _remove(String value) {
    setState(() => _interests.remove(value));
    widget.onChanged(_interests);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_interests.isNotEmpty) ...[
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final interest in _interests)
                InputChip(
                  label: Text(interest),
                  onDeleted: () => _remove(interest),
                  deleteIconColor: AppColors.textSecondary,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Add an interest',
                hint: 'e.g. Cardiology',
                controller: _controller,
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlineButton(label: 'Add', icon: Icons.add, onPressed: _add),
          ],
        ),
      ],
    );
  }
}
