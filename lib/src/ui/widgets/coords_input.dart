import 'package:coordinator_input/src/domain/entities/editor_coordinate.dart';
import 'package:coordinator_input/src/domain/entities/utm_coordinate.dart';
import 'package:coordinator_input/src/domain/enums/coordinate_input_mode.dart';
import 'package:coordinator_input/src/plugins/geolocator_location_service.dart';
import 'package:coordinator_input/src/plugins/location_service.dart';
import 'package:coordinator_input/src/ui/viewmodels/coords_input_viewmodel.dart';
import 'package:coordinator_input/src/ui/widgets/input.dart';
import 'package:coordinator_input/src/ui/widgets/primary_button.dart';
import 'package:coordinator_input/src/ui/widgets/toggle_button/toggle_button_group.dart';
import 'package:flutter/material.dart';

class CoordsInput extends StatefulWidget {
  const CoordsInput({
    this.initialCoordinate,
    this.initialUtmCoordinate,
    this.onChanged,
    this.locationService,
    this.mode,
    super.key,
  });

  final EditorCoordinate? initialCoordinate;
  final UtmCoordinate? initialUtmCoordinate;
  final ValueChanged<EditorCoordinate?>? onChanged;
  final LocationService? locationService;
  final CoordinateInputMode? mode;

  @override
  State<CoordsInput> createState() => _CoordsInputState();
}

class _CoordsInputState extends State<CoordsInput> {
  late final TextEditingController _firstController;
  late final TextEditingController _secondController;
  late final CoordsInputViewModel _viewModel;
  bool _isSyncing = false;
  bool _suppressOnChanged = false;
  EditorCoordinate? _lastReportedCoordinate;

  @override
  void initState() {
    super.initState();
    _firstController = TextEditingController();
    _secondController = TextEditingController();
    _viewModel = CoordsInputViewModel(
      initialCoordinate: widget.initialCoordinate,
      initialUtmCoordinate: widget.initialUtmCoordinate,
      locationService:
          widget.locationService ?? const GeolocatorLocationService(),
      mode: widget.mode,
    )..addListener(_handleViewModelChanged);
    _lastReportedCoordinate = _viewModel.coordinate;
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant CoordsInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode && widget.mode != null) {
      _viewModel.setMode(widget.mode!);
    }
    if (oldWidget.initialCoordinate != widget.initialCoordinate ||
        oldWidget.initialUtmCoordinate != widget.initialUtmCoordinate ||
        oldWidget.mode != widget.mode) {
      _suppressOnChanged = true;
      _viewModel.setInitialValue(
        coordinate: widget.initialCoordinate,
        utmCoordinate: widget.initialUtmCoordinate,
      );
      _lastReportedCoordinate = _viewModel.coordinate;
      _suppressOnChanged = false;
    }
  }

  @override
  void dispose() {
    _viewModel
      ..removeListener(_handleViewModelChanged)
      ..dispose();
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  void _handleViewModelChanged() {
    if (!mounted) {
      return;
    }
    _syncControllers();
    if (_suppressOnChanged ||
        _lastReportedCoordinate == _viewModel.coordinate) {
      return;
    }
    _lastReportedCoordinate = _viewModel.coordinate;
    widget.onChanged?.call(_viewModel.coordinate);
  }

  void _syncControllers() {
    _isSyncing = true;
    _firstController.value = _firstController.value.copyWith(
      text: _viewModel.firstValue,
      selection: TextSelection.collapsed(offset: _viewModel.firstValue.length),
      composing: TextRange.empty,
    );
    _secondController.value = _secondController.value.copyWith(
      text: _viewModel.secondValue,
      selection: TextSelection.collapsed(offset: _viewModel.secondValue.length),
      composing: TextRange.empty,
    );
    _isSyncing = false;
  }

  void _handleFirstChanged(String value) {
    if (_isSyncing) {
      return;
    }
    _viewModel.updateFromText(
      firstText: value,
      secondText: _secondController.text,
    );
  }

  void _handleSecondChanged(String value) {
    if (_isSyncing) {
      return;
    }
    _viewModel.updateFromText(
      firstText: _firstController.text,
      secondText: value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Row(
                spacing: 12,
                children: [
                  Expanded(child: ToggleButtonGroup(
                    onChanged: (selection){
                      _viewModel.setMode(selection);
                    },
                    initialValue: _viewModel.mode,
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
                    onPressed: !_viewModel.canLoadCurrentLocation ||
                      _viewModel.isLoadingLocation
                      ? null : _viewModel.fillWithCurrentLocation,
                    enabled: !_viewModel.isLoadingLocation,
                    text: 'Local atual',
                  ),
                ],
              ),
              if (_viewModel.mode == CoordinateInputMode.utm)
                Text(
                  _viewModel.utmCoordinate == null
                      ? 'Zona UTM sera definida quando houver coordenada.'
                      : 'Zona UTM ${_viewModel.utmCoordinate!.zoneNumber}${_viewModel.utmCoordinate!.zoneLetter}',
                  style: theme.textTheme.labelMedium,
                ),
              Row(
                children: [
                  Expanded(
                    child: Input(
                      controller: _firstController,
                      prefixText: _viewModel.mode == CoordinateInputMode.geographic
                          ? 'LAT' : 'X',
                      onChanged: _handleFirstChanged,
                      label: _viewModel.mode == CoordinateInputMode.geographic
                          ? 'Latitude' : 'UTM X',
                    ),
                  ),
                  Expanded(
                    child: Input(
                      controller: _secondController,
                      connectedInput: true,
                      onChanged: _handleSecondChanged,
                      prefixText: _viewModel.mode == CoordinateInputMode.geographic
                          ? 'LON' : 'Y',
                      label: _viewModel.mode == CoordinateInputMode.geographic
                          ? 'Longitude' : 'UTM Y',
                    ),
                  ),
                ],
              ),
              if (_viewModel.statusMessage != null)
                Text(
                  _viewModel.statusMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
