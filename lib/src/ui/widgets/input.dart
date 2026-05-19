import 'package:coordinator_input/coordinator_input.dart';
import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  const Input({
    super.key,
    this.onChanged,
    this.decoration,
    required this.controller,
    this.viewModel,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final CoordsInputViewModel? viewModel;
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      onChanged: onChanged,
      decoration:
          decoration ??
          InputDecoration(
            labelText: viewModel?.mode == CoordinateInputMode.geographic
                ? 'Longitude'
                : 'UTM Y',
            hintText: viewModel?.mode == CoordinateInputMode.geographic
                ? '-40.630600'
                : '7838581.22',
            border: const OutlineInputBorder(),
          ),
    );
  }
}
