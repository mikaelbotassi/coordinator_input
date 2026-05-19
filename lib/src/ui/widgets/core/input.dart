import 'package:flutter/material.dart';

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

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final InputDecoration? decoration;
  final bool connectedInput;
  final String prefixText;
  final bool enabled;
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
          end: borderSide, bottom: borderSide, top: borderSide
        ),
        borderRadius: BorderRadius.only(
          bottomRight: connectedInput ? radius : Radius.zero,
          topRight: connectedInput ? radius : Radius.zero,
          bottomLeft: connectedInput ? Radius.zero : radius,
          topLeft: connectedInput ? Radius.zero : radius,
        )
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
                    color: colors.outline
                  )),
              ),
              border: InputBorder.none,
            ),
      ),
    );
  }
}
