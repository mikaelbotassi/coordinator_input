import 'package:flutter/material.dart';

/// Package-styled primary action button.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    this.icon,
    this.enabled = true,
    this.onPressed,
    this.text,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    super.key,
  });

  /// Optional icon shown before the text.
  final IconData? icon;

  /// Action executed when the button is tapped.
  final VoidCallback? onPressed;

  /// Whether the button is enabled.
  final bool enabled;

  /// Optional button label.
  final String? text;

  /// Internal button padding.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final (colors, textTheme) = (
      Theme.of(context).colorScheme,
      Theme.of(context).textTheme,
    );
    final iconSize = text != null ? 16.0 : 24.0;
    return InkWell(
      onTap: enabled ? onPressed : null,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: colors.primaryContainer.withAlpha(enabled ? 1000 : 100),
          border: Border.all(
            color: colors.primary.withAlpha(enabled ? 1000 : 100),
          ),
        ),
        child: Row(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: colors.onPrimaryContainer.withAlpha(
                  enabled ? 1000 : 100,
                ),
                size: iconSize,
              ),
            if (text != null)
              Text(
                text!,
                style: textTheme.bodyMedium?.apply(
                  color: colors.onPrimaryContainer.withAlpha(
                    enabled ? 1000 : 100,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
