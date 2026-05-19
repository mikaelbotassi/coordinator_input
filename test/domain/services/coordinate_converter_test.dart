import 'package:coordinator_input/coordinator_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoordinateConverter', () {
    const converter = CoordinateConverter();

    test('converts geographic coordinate to UTM and back', () {
      const original = EditorCoordinate(
        latitude: -19.5356,
        longitude: -40.6306,
      );

      final utm = converter.toUtm(original);
      final restored = converter.fromUtm(
        easting: utm.easting,
        northing: utm.northing,
        zoneNumber: utm.zoneNumber,
        northernHemisphere: utm.northernHemisphere,
      );

      expect(restored.latitude, closeTo(original.latitude, 0.0001));
      expect(restored.longitude, closeTo(original.longitude, 0.0001));
    });

    test('detects southern hemisphere zone metadata', () {
      const original = EditorCoordinate(
        latitude: -23.55052,
        longitude: -46.633308,
      );

      final utm = converter.toUtm(original);

      expect(utm.zoneNumber, 23);
      expect(utm.zoneLetter, 'K');
      expect(utm.northernHemisphere, isFalse);
    });
  });
}
