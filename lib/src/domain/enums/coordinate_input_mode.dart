/// Supported coordinate editing modes exposed by [CoordsInput].
enum CoordinateInputMode {
  /// Latitude and longitude in decimal degrees.
  geographic,

  /// UTM easting and northing values with zone metadata.
  utm,
}
