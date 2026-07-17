import 'package:flutter/material.dart';

/// A numeric [TextField] that selects its entire value when it gains focus,
/// so typing immediately replaces the default (e.g. "0") instead of appending.
class NumberField extends StatefulWidget {
  const NumberField({
    super.key,
    this.fieldKey,
    required this.controller,
    required this.labelText,
    this.autofocus = false,
  });

  final Key? fieldKey;
  final TextEditingController controller;
  final String labelText;
  final bool autofocus;

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      widget.controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: widget.fieldKey,
      controller: widget.controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      decoration: InputDecoration(labelText: widget.labelText),
      keyboardType: TextInputType.number,
    );
  }
}
