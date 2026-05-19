import 'package:coordinator_input/coordinator_input.dart';
import 'package:flutter/material.dart';

/// Bottom status row with UTM zone information and status messages.
class CoordinatorInputBottombar extends StatelessWidget {
  const CoordinatorInputBottombar({super.key, required this.viewModel});

  /// View model that supplies the zone and status text.
  final CoordsInputViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (colors, textTheme) = (theme.colorScheme, theme.textTheme);
    return Row(
      children: [
        if (viewModel.mode == CoordinateInputMode.utm)
          Expanded(
            child: Text(
              viewModel.utmCoordinate == null
                  ? 'Zona UTM sera definida quando houver coordenada.'
                  : 'Zona UTM ${viewModel.utmCoordinate!.zoneNumber}${viewModel.utmCoordinate!.zoneLetter}',
              style: textTheme.labelMedium,
            ),
          ),
        if (viewModel.statusMessage != null)
          Expanded(
            child: Text(
              viewModel.statusMessage!,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.end,
            ),
          ),
      ],
    );
  }
}
