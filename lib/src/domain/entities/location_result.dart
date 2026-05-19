import 'package:coordinator_input/coordinator_input.dart';

class LocationResult {
  const LocationResult.success({
    required this.coordinate,
    this.accuracyInMeters,
  })  : message = null,
        isSuccess = true;

  const LocationResult.failure(this.message)
      : coordinate = null,
        accuracyInMeters = null,
        isSuccess = false;

  final EditorCoordinate? coordinate;
  final double? accuracyInMeters;
  final String? message;
  final bool isSuccess;
}