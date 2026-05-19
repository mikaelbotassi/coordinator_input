import 'package:coordinator_input/src/domain/entities/editor_coordinate.dart';
import 'package:coordinator_input/src/domain/entities/utm_coordinate.dart';
import 'package:coordinator_input/src/domain/enums/coordinate_input_mode.dart';
import 'package:coordinator_input/src/plugins/geolocator_location_service.dart';
import 'package:coordinator_input/src/plugins/location_service.dart';
import 'package:coordinator_input/src/ui/viewmodels/coords_input_viewmodel.dart';
import 'package:coordinator_input/src/ui/widgets/coordinator_input_bottombar.dart';
import 'package:coordinator_input/src/ui/widgets/coords_input_group.dart';
import 'package:coordinator_input/src/ui/widgets/coords_input_topbar.dart';
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
              CoordsInputTopbar(viewModel: _viewModel),
              CoordsInputGroup(
                viewModel: _viewModel,
                firstController: _firstController,
                secondController: _secondController,
                isSyncing: _isSyncing,
                enabled: !_viewModel.isLoadingLocation,
              ),
              if(_viewModel.mode == CoordinateInputMode.utm || _viewModel.statusMessage != null)
                CoordinatorInputBottombar(viewModel: _viewModel)
            ],
          ),
        );
      },
    );
  }
}
