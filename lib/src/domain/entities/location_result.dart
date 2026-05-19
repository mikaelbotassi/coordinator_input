import 'package:coordinator_input/coordinator_input.dart';

/// Result returned by a [LocationService] implementation.
class LocationResult {
  /// Creates a successful location lookup result.
  const LocationResult.success({
    required this.coordinate,
    this.accuracyInMeters,
  }) : message = null,
       isSuccess = true;

  /// Creates a failed location lookup result with a user-facing [message].
  const LocationResult.failure(this.message)
    : coordinate = null,
      accuracyInMeters = null,
      isSuccess = false;

  /// Geographic coordinate returned by the lookup.
  final EditorCoordinate? coordinate;

  /// Horizontal accuracy reported by the platform, in meters.
  final double? accuracyInMeters;

  /// Optional failure message when [isSuccess] is `false`.
  final String? message;

  /// Whether the lookup completed successfully.
  final bool isSuccess;
}
