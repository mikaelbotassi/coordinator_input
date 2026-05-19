import 'package:coordinator_input/src/domain/entities/location_result.dart';

abstract class LocationService {
  Future<LocationResult> getCurrentCoordinate();
}

