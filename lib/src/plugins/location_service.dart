import 'package:coordinator_input/src/domain/entities/location_result.dart';

/// Abstraction used by the widget to retrieve the device current location.
abstract class LocationService {
  /// Returns the current geographic coordinate, or a failure result.
  Future<LocationResult> getCurrentCoordinate();
}
