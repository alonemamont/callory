import 'package:flutter/material.dart';

/// A [ListTile] showing a field label and its current value; tapping opens
/// a modal bottom sheet listing every [options] entry with a description,
/// so the user can see what each choice means before picking it.
class OptionPickerTile<T> extends StatelessWidget {
  const OptionPickerTile({
    super.key,
    this.fieldKey,
    required this.fieldLabel,
    required this.currentValueLabel,
    required this.options,
    required this.optionLabel,
    required this.optionDescription,
    required this.onChanged,
  });

  final Key? fieldKey;
  final String fieldLabel;
  final String currentValueLabel;
  final List<T> options;
  final String Function(T) optionLabel;
  final String Function(T) optionDescription;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: fieldKey,
      title: Text('$fieldLabel: $currentValueLabel'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _openPicker(context),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<T>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final option in options)
              ListTile(
                title: Text(optionLabel(option)),
                subtitle: Text(optionDescription(option)),
                onTap: () => Navigator.pop(context, option),
              ),
          ],
        ),
      ),
    );
    if (selected != null) onChanged(selected);
  }
}
