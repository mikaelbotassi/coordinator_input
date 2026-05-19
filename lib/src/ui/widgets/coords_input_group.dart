import 'package:coordinator_input/coordinator_input.dart';
import 'package:coordinator_input/src/ui/widgets/core/input.dart';
import 'package:flutter/material.dart';

class CoordsInputGroup extends StatelessWidget {
  const CoordsInputGroup({
    super.key,
    required this.viewModel,
    required this.firstController,
    required this.secondController,
    required this.isSyncing,
    required this.enabled,

  });

  final CoordsInputViewModel viewModel;
  final TextEditingController firstController;
  final TextEditingController secondController;
  final bool isSyncing;
  final bool enabled;

  void _handleFirstChanged(String value) {
    if (isSyncing) {
      return;
    }
    viewModel.updateFromText(
      firstText: value,
      secondText: secondController.text,
    );
  }

  void _handleSecondChanged(String value) {
    if (isSyncing) {
      return;
    }
    viewModel.updateFromText(
      firstText: firstController.text,
      secondText: value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Input(
            enabled: enabled,
            controller: firstController,
            prefixText: viewModel.mode == CoordinateInputMode.geographic
                ? 'LAT' : 'X',
            onChanged: _handleFirstChanged,
            label: viewModel.mode == CoordinateInputMode.geographic
                ? 'Latitude' : 'UTM X',
          ),
        ),
        Expanded(
          child: Input(
            controller: secondController,
            connectedInput: true,
            enabled: enabled,
            onChanged: _handleSecondChanged,
            prefixText: viewModel.mode == CoordinateInputMode.geographic
                ? 'LON' : 'Y',
            label: viewModel.mode == CoordinateInputMode.geographic
                ? 'Longitude' : 'UTM Y',
          ),
        ),
      ],
    );
  }
}
