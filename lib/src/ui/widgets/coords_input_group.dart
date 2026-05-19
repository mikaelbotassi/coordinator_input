import 'package:coordinator_input/coordinator_input.dart';
import 'package:coordinator_input/src/ui/widgets/core/input.dart';
import 'package:flutter/material.dart';

/// Pair of connected text inputs used to edit the current coordinate values.
class CoordsInputGroup extends StatelessWidget {
  const CoordsInputGroup({
    super.key,
    required this.viewModel,
    required this.firstController,
    required this.secondController,
    required this.enabled,
    required this.onFirstChanged,
    required this.onSecondChanged,
  });

  /// View model that provides labels and formatted values.
  final CoordsInputViewModel viewModel;

  /// Controller bound to the first field.
  final TextEditingController firstController;

  /// Controller bound to the second field.
  final TextEditingController secondController;

  /// Whether the fields are currently editable.
  final bool enabled;

  /// Called when the first field changes.
  final ValueChanged<String> onFirstChanged;

  /// Called when the second field changes.
  final ValueChanged<String> onSecondChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Input(
            enabled: enabled,
            controller: firstController,
            prefixText: viewModel.mode == CoordinateInputMode.geographic
                ? 'LAT'
                : 'X',
            onChanged: onFirstChanged,
            label: viewModel.mode == CoordinateInputMode.geographic
                ? 'Latitude'
                : 'UTM X',
          ),
        ),
        Expanded(
          child: Input(
            controller: secondController,
            connectedInput: true,
            enabled: enabled,
            onChanged: onSecondChanged,
            prefixText: viewModel.mode == CoordinateInputMode.geographic
                ? 'LON'
                : 'Y',
            label: viewModel.mode == CoordinateInputMode.geographic
                ? 'Longitude'
                : 'UTM Y',
          ),
        ),
      ],
    );
  }
}
