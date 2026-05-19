import 'package:coordinator_input/src/domain/entities/editor_coordinate.dart';
import 'package:coordinator_input/src/domain/entities/utm_coordinate.dart';
import 'package:coordinator_input/src/domain/enums/coordinate_input_mode.dart';
import 'package:coordinator_input/src/plugins/geolocator_location_service.dart';
import 'package:coordinator_input/src/plugins/location_service.dart';
import 'package:coordinator_input/src/ui/viewmodels/coords_input_viewmodel.dart';
import 'package:coordinator_input/src/ui/widgets/input.dart';
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
                  Expanded(
                    child: SegmentedButton<CoordinateInputMode>(
                      segments: const [
                        ButtonSegment(
                          value: CoordinateInputMode.geographic,
                          label: Text('Lat / Long'),
                          icon: Icon(Icons.public),
                        ),
                        ButtonSegment(
                          value: CoordinateInputMode.utm,
                          label: Text('UTM X / Y'),
                          icon: Icon(Icons.grid_on),
                        ),
                      ],
                      selected: {_viewModel.mode},
                      onSelectionChanged: (selection) =>
                          _viewModel.setMode(selection.first),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed:
                        !_viewModel.canLoadCurrentLocation ||
                            _viewModel.isLoadingLocation
                        ? null
                        : _viewModel.fillWithCurrentLocation,
                    icon: _viewModel.isLoadingLocation
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.my_location),
                    label: const Text('Local atual'),
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
                spacing: 12,
                children: [
                  Expanded(
                    child: Input(
                      controller: _firstController,
                      onChanged: _handleFirstChanged,
                      decoration: InputDecoration(
                        labelText:
                            _viewModel.mode == CoordinateInputMode.geographic
                            ? 'Latitude'
                            : 'UTM X',
                        hintText:
                            _viewModel.mode == CoordinateInputMode.geographic
                            ? '-19.535600'
                            : '326230.15',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Input(
                      controller: _secondController,
                      onChanged: _handleSecondChanged,
                      decoration: InputDecoration(
                        labelText:
                            _viewModel.mode == CoordinateInputMode.geographic
                            ? 'Longitude'
                            : 'UTM Y',
                        hintText:
                            _viewModel.mode == CoordinateInputMode.geographic
                            ? '-40.630600'
                            : '7838581.22',
                        border: const OutlineInputBorder(),
                      ),
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
