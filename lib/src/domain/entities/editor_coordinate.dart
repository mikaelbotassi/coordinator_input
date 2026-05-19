/// Geographic coordinate expressed as latitude and longitude in decimal degrees.
class EditorCoordinate {
  const EditorCoordinate({required this.latitude, required this.longitude});

  /// Latitude in decimal degrees.
  final double latitude;

  /// Longitude in decimal degrees.
  final double longitude;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is EditorCoordinate &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() =>
      'EditorCoordinate(latitude: $latitude, longitude: $longitude)';
}
