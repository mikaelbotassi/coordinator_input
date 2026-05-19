import 'package:flutter/material.dart';

/// Stylized text field used by the coordinate input widget.
class Input extends StatelessWidget {
  const Input({
    required this.controller,
    required this.label,
    required this.prefixText,
    this.connectedInput = false,
    this.enabled = true,
    this.onChanged,
    this.decoration,
    super.key,
  });

  /// Text controller associated with the field.
  final TextEditingController controller;

  /// Callback invoked when the field text changes.
  final ValueChanged<String>? onChanged;

  /// Optional custom decoration override.
  final InputDecoration? decoration;

  /// Whether this field is visually connected to a previous sibling input.
  final bool connectedInput;

  /// Short prefix label displayed inside the field.
  final String prefixText;

  /// Whether the field can be edited.
  final bool enabled;

  /// Placeholder text shown when the field is empty.
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (textTheme, colors) = (theme.textTheme, theme.colorScheme);
    final borderSide = BorderSide(color: colors.outline);
    final radius = Radius.circular(4);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: connectedInput ? BorderSide.none : borderSide,
          end: borderSide,
          bottom: borderSide,
          top: borderSide,
        ),
        borderRadius: BorderRadius.only(
          bottomRight: connectedInput ? radius : Radius.zero,
          topRight: connectedInput ? radius : Radius.zero,
          bottomLeft: connectedInput ? Radius.zero : radius,
          topLeft: connectedInput ? Radius.zero : radius,
        ),
      ),
      child: TextField(
        enabled: enabled,
        style: textTheme.bodyMedium,
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        onChanged: onChanged,
        decoration:
            decoration ??
            InputDecoration(
              fillColor: colors.surfaceContainerHigh,
              hintText: label,
              prefix: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  prefixText,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.outline,
                  ),
                ),
              ),
              border: InputBorder.none,
            ),
      ),
    );
  }
}
