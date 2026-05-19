import 'package:flutter/material.dart';

/// Single visual option used inside the package toggle group widget.
class ToggleButton extends StatelessWidget {
  const ToggleButton({
    required this.onPressed,
    required this.active,
    this.showEndBorder = true,
    this.text,
    this.icon,
    super.key,
  });

  final bool active;
  final bool showEndBorder;
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (colors, textTheme) = (theme.colorScheme, theme.textTheme);
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? colors.primary : Colors.transparent,
          border: showEndBorder
              ? BorderDirectional(end: BorderSide(color: colors.primary))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: active ? colors.onPrimary : colors.primary,
                size: 16,
              ),
            if (text != null)
              Text(
                text!,
                style: textTheme.labelMedium?.apply(
                  color: active ? colors.onPrimary : colors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
