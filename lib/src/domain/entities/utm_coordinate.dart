/// UTM coordinate with projected values and zone metadata.
class UtmCoordinate {
  const UtmCoordinate({
    required this.easting,
    required this.northing,
    required this.zoneNumber,
    required this.zoneLetter,
    required this.northernHemisphere,
  });

  /// Easting value in meters.
  final double easting;

  /// Northing value in meters.
  final double northing;

  /// UTM zone number.
  final int zoneNumber;

  /// UTM latitude band letter.
  final String zoneLetter;

  /// Whether the coordinate belongs to the northern hemisphere.
  final bool northernHemisphere;

  /// Returns a new instance with the provided field overrides.
  UtmCoordinate copyWith({
    double? easting,
    double? northing,
    int? zoneNumber,
    String? zoneLetter,
    bool? northernHemisphere,
  }) {
    return UtmCoordinate(
      easting: easting ?? this.easting,
      northing: northing ?? this.northing,
      zoneNumber: zoneNumber ?? this.zoneNumber,
      zoneLetter: zoneLetter ?? this.zoneLetter,
      northernHemisphere: northernHemisphere ?? this.northernHemisphere,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is UtmCoordinate &&
        other.easting == easting &&
        other.northing == northing &&
        other.zoneNumber == zoneNumber &&
        other.zoneLetter == zoneLetter &&
        other.northernHemisphere == northernHemisphere;
  }

  @override
  int get hashCode => Object.hash(
    easting,
    northing,
    zoneNumber,
    zoneLetter,
    northernHemisphere,
  );
}
