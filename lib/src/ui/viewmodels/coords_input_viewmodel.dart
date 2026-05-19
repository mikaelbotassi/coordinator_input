import 'package:coordinator_input/src/domain/entities/editor_coordinate.dart';
import 'package:coordinator_input/src/domain/entities/utm_coordinate.dart';
import 'package:coordinator_input/src/domain/enums/coordinate_input_mode.dart';
import 'package:coordinator_input/src/plugins/coordinate_converter.dart';
import 'package:coordinator_input/src/plugins/location_service.dart';
import 'package:flutter/foundation.dart';

/// View model that drives [CoordsInput] text values, mode and status messages.
class CoordsInputViewModel extends ChangeNotifier {
  /// Creates a new view model with optional initial geographic or UTM values.
  CoordsInputViewModel({
    EditorCoordinate? initialCoordinate,
    UtmCoordinate? initialUtmCoordinate,
    CoordinateConverter? converter,
    LocationService? locationService,
    CoordinateInputMode? mode,
  }) : _converter = converter ?? const CoordinateConverter(),
       _locationService = locationService,
       _mode = mode ?? CoordinateInputMode.geographic {
    _setInitialCoordinate(
      initialCoordinate: initialCoordinate,
      initialUtmCoordinate: initialUtmCoordinate,
    );
  }

  final CoordinateConverter _converter;
  final LocationService? _locationService;

  CoordinateInputMode _mode;
  EditorCoordinate? _coordinate;
  UtmCoordinate? _utmCoordinate;
  String? _errorMessage;
  double? _lastAccuracyInMeters;
  bool _isLoadingLocation = false;

  /// Current editing mode.
  CoordinateInputMode get mode => _mode;

  /// Current geographic coordinate, regardless of the active mode.
  EditorCoordinate? get coordinate => _coordinate;

  /// Current UTM coordinate, if available.
  UtmCoordinate? get utmCoordinate => _utmCoordinate;

  /// Current value represented by the active [mode].
  Object? get currentValue =>
      _mode == CoordinateInputMode.utm ? _utmCoordinate : _coordinate;

  /// User-facing status text combining location errors and last known accuracy.
  String? get statusMessage {
    final messages = <String>[
      ?_errorMessage,
      if (_lastAccuracyInMeters != null)
        'Precisao estimada: ${_lastAccuracyInMeters!.toStringAsFixed(1)} m',
    ];
    if (messages.isEmpty) {
      return null;
    }
    return messages.join('\n');
  }

  /// Whether the view model is retrieving the current device location.
  bool get isLoadingLocation => _isLoadingLocation;

  /// Whether a [LocationService] is available for current-location lookup.
  bool get canLoadCurrentLocation => _locationService != null;

  /// First input value formatted for the active [mode].
  String get firstValue {
    if (_coordinate == null ||
        (_mode == CoordinateInputMode.utm && _utmCoordinate == null)) {
      return '';
    }
    if (_mode == CoordinateInputMode.geographic) {
      return formatDecimal(_coordinate!.latitude);
    }
    return formatDecimal(_utmCoordinate!.easting, fractionDigits: 3);
  }

  /// Second input value formatted for the active [mode].
  String get secondValue {
    if (_coordinate == null ||
        (_mode == CoordinateInputMode.utm && _utmCoordinate == null)) {
      return '';
    }
    if (_mode == CoordinateInputMode.geographic) {
      return formatDecimal(_coordinate!.longitude);
    }
    return formatDecimal(_utmCoordinate!.northing, fractionDigits: 3);
  }

  /// Changes the active editing [mode].
  void setMode(CoordinateInputMode mode) {
    if (_mode == mode) {
      return;
    }
    _mode = mode;
    notifyListeners();
  }

  /// Sets the initial value based on the active [mode].
  void setInitialValue({
    EditorCoordinate? coordinate,
    UtmCoordinate? utmCoordinate,
    bool notifyListeners = true,
  }) {
    if (_mode == CoordinateInputMode.utm && utmCoordinate != null) {
      _coordinate = _converter.fromUtm(
        easting: utmCoordinate.easting,
        northing: utmCoordinate.northing,
        zoneNumber: utmCoordinate.zoneNumber,
        northernHemisphere: utmCoordinate.northernHemisphere,
      );
      _utmCoordinate = utmCoordinate;
      _errorMessage = null;
      if (notifyListeners) {
        this.notifyListeners();
      }
      return;
    }

    if (coordinate != null) {
      setCoordinate(coordinate, notifyListeners: notifyListeners);
      return;
    }

    if (utmCoordinate != null) {
      _coordinate = _converter.fromUtm(
        easting: utmCoordinate.easting,
        northing: utmCoordinate.northing,
        zoneNumber: utmCoordinate.zoneNumber,
        northernHemisphere: utmCoordinate.northernHemisphere,
      );
      _utmCoordinate = utmCoordinate;
      _errorMessage = null;
      if (notifyListeners) {
        this.notifyListeners();
      }
      return;
    }

    setCoordinate(null, notifyListeners: notifyListeners);
  }

  /// Replaces the current geographic [coordinate] and recalculates UTM.
  void setCoordinate(
    EditorCoordinate? coordinate, {
    bool notifyListeners = true,
  }) {
    _coordinate = coordinate;
    _utmCoordinate = coordinate == null ? null : _converter.toUtm(coordinate);
    _errorMessage = null;
    if (notifyListeners) {
      this.notifyListeners();
    }
  }

  /// Updates the current value from the raw text entered in the two fields.
  EditorCoordinate? updateFromText({
    required String firstText,
    required String secondText,
  }) {
    final first = _parseValue(firstText);
    final second = _parseValue(secondText);

    if ((first == null || second == null) &&
        firstText.isEmpty &&
        secondText.isEmpty) {
      setCoordinate(null);
      return null;
    }

    if (first == null || second == null) {
      return _coordinate;
    }

    if (_mode == CoordinateInputMode.geographic) {
      if (!_isGeographicValueValid(first: first, second: second)) {
        return _coordinate;
      }
      final nextCoordinate = EditorCoordinate(
        latitude: first,
        longitude: second,
      );
      setCoordinate(nextCoordinate);
      return nextCoordinate;
    }

    final currentUtm = _utmCoordinate;
    if (currentUtm == null || first <= 0 || second <= 0) {
      return _coordinate;
    }

    final nextCoordinate = _converter.fromUtm(
      easting: first,
      northing: second,
      zoneNumber: currentUtm.zoneNumber,
      northernHemisphere: currentUtm.northernHemisphere,
    );

    _coordinate = nextCoordinate;
    _utmCoordinate = currentUtm.copyWith(easting: first, northing: second);
    _errorMessage = null;
    notifyListeners();
    return nextCoordinate;
  }

  /// Loads the device current location and updates the state accordingly.
  Future<EditorCoordinate?> fillWithCurrentLocation() async {
    final locationService = _locationService;
    if (locationService == null || _isLoadingLocation) {
      return _coordinate;
    }

    _isLoadingLocation = true;
    _errorMessage = null;
    notifyListeners();

    final result = await locationService.getCurrentCoordinate();
    _isLoadingLocation = false;

    if (!result.isSuccess || result.coordinate == null) {
      _errorMessage = result.message;
      notifyListeners();
      return _coordinate;
    }

    _coordinate = result.coordinate;
    _utmCoordinate = _converter.toUtm(result.coordinate!);
    _errorMessage = null;
    _lastAccuracyInMeters = result.accuracyInMeters;
    notifyListeners();
    return _coordinate;
  }

  double? _parseValue(String value) {
    return double.tryParse(value.replaceAll(',', '.'));
  }

  bool _isGeographicValueValid({
    required double first,
    required double second,
  }) {
    return first >= -90 && first <= 90 && second >= -180 && second <= 180;
  }

  void _setInitialCoordinate({
    EditorCoordinate? initialCoordinate,
    UtmCoordinate? initialUtmCoordinate,
  }) {
    setInitialValue(
      coordinate: initialCoordinate,
      utmCoordinate: initialUtmCoordinate,
      notifyListeners: false,
    );
  }
}

/// Formats numeric values for field display.
String formatDecimal(double value, {int fractionDigits = 6}) {
  return value.toStringAsFixed(fractionDigits);
}
