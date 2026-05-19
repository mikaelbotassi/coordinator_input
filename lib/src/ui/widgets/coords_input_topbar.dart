import 'package:coordinator_input/coordinator_input.dart';
import 'package:coordinator_input/src/ui/widgets/core/primary_button.dart';
import 'package:coordinator_input/src/ui/widgets/core/toggle_button/toggle_button_group.dart';
import 'package:flutter/material.dart';

class CoordsInputTopbar extends StatelessWidget {
  const CoordsInputTopbar({super.key, required this.viewModel});

  final CoordsInputViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Expanded(child: ToggleButtonGroup(
            onChanged: (selection){
              viewModel.setMode(selection);
            },
            initialValue: viewModel.mode,
            options: const [
              ToggleButtonOption(
                value: CoordinateInputMode.geographic,
                text: 'Lat / Long',
                icon: Icons.public,
              ),
              ToggleButtonOption(
                value: CoordinateInputMode.utm,
                text: 'UTM X / Y',
                icon: Icons.grid_on,
              ),
            ],
          )),
          PrimaryButton(
            icon: Icons.my_location,
            onPressed: !viewModel.canLoadCurrentLocation ||
                viewModel.isLoadingLocation
                ? null : viewModel.fillWithCurrentLocation,
            enabled: !viewModel.isLoadingLocation,
            text: 'Local atual',
          ),
        ],
      ),
    );
  }

}
