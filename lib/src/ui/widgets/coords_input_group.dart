import 'package:coordinator_input/coordinator_input.dart';
import 'package:coordinator_input/src/ui/widgets/core/input.dart';
import 'package:flutter/material.dart';

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

  final CoordsInputViewModel viewModel;
  final TextEditingController firstController;
  final TextEditingController secondController;
  final bool enabled;
  final ValueChanged<String> onFirstChanged;
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
