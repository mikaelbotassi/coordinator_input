import 'dart:math' as math;

import 'package:coordinator_input/src/domain/entities/editor_coordinate.dart';
import 'package:coordinator_input/src/domain/entities/utm_coordinate.dart';

/// Converts between geographic and UTM coordinate representations.
class CoordinateConverter {
  const CoordinateConverter();

  static const double _equatorialRadius = 6378137.0;
  static const double _eccentricitySquared = 0.00669438;
  static const double _scaleFactor = 0.9996;

  /// Converts a geographic [coordinate] into its UTM representation.
  UtmCoordinate toUtm(EditorCoordinate coordinate) {
    final latitude = coordinate.latitude;
    final longitude = coordinate.longitude;
    final zoneNumber = ((longitude + 180) / 6).floor() + 1;
    final zoneLetter = _latitudeToZoneLetter(latitude);
    final longitudeOrigin = (zoneNumber - 1) * 6 - 180 + 3;
    final latitudeRad = _degreesToRadians(latitude);
    final longitudeRad = _degreesToRadians(longitude);
    final longitudeOriginRad = _degreesToRadians(longitudeOrigin.toDouble());
    final eccPrimeSquared = _eccentricitySquared / (1 - _eccentricitySquared);

    final sinLatitude = math.sin(latitudeRad);
    final cosLatitude = math.cos(latitudeRad);
    final tanLatitude = math.tan(latitudeRad);

    final n =
        _equatorialRadius /
        math.sqrt(1 - _eccentricitySquared * sinLatitude * sinLatitude);
    final t = tanLatitude * tanLatitude;
    final c = eccPrimeSquared * cosLatitude * cosLatitude;
    final a = cosLatitude * (longitudeRad - longitudeOriginRad);

    final m =
        _equatorialRadius *
        ((1 -
                    _eccentricitySquared / 4 -
                    3 * _eccentricitySquared * _eccentricitySquared / 64 -
                    5 * _pow(_eccentricitySquared, 3) / 256) *
                latitudeRad -
            (3 * _eccentricitySquared / 8 +
                    3 * _eccentricitySquared * _eccentricitySquared / 32 +
                    45 * _pow(_eccentricitySquared, 3) / 1024) *
                math.sin(2 * latitudeRad) +
            (15 * _eccentricitySquared * _eccentricitySquared / 256 +
                    45 * _pow(_eccentricitySquared, 3) / 1024) *
                math.sin(4 * latitudeRad) -
            (35 * _pow(_eccentricitySquared, 3) / 3072) *
                math.sin(6 * latitudeRad));

    final easting =
        _scaleFactor *
            n *
            (a +
                (1 - t + c) * _pow(a, 3) / 6 +
                (5 - 18 * t + t * t + 72 * c - 58 * eccPrimeSquared) *
                    _pow(a, 5) /
                    120) +
        500000.0;

    var northing =
        _scaleFactor *
        (m +
            n *
                tanLatitude *
                (a * a / 2 +
                    (5 - t + 9 * c + 4 * c * c) * _pow(a, 4) / 24 +
                    (61 - 58 * t + t * t + 600 * c - 330 * eccPrimeSquared) *
                        _pow(a, 6) /
                        720));

    final northernHemisphere = latitude >= 0;
    if (!northernHemisphere) {
      northing += 10000000.0;
    }

    return UtmCoordinate(
      easting: easting,
      northing: northing,
      zoneNumber: zoneNumber,
      zoneLetter: zoneLetter,
      northernHemisphere: northernHemisphere,
    );
  }

  /// Converts an UTM coordinate back into geographic latitude/longitude.
  EditorCoordinate fromUtm({
    required double easting,
    required double northing,
    required int zoneNumber,
    required bool northernHemisphere,
  }) {
    var adjustedNorthing = northing;
    if (!northernHemisphere) {
      adjustedNorthing -= 10000000.0;
    }

    final x = easting - 500000.0;
    final y = adjustedNorthing;
    final longitudeOrigin = (zoneNumber - 1) * 6 - 180 + 3;
    final eccPrimeSquared = _eccentricitySquared / (1 - _eccentricitySquared);
    final m = y / _scaleFactor;
    final mu =
        m /
        (_equatorialRadius *
            (1 -
                _eccentricitySquared / 4 -
                3 * _eccentricitySquared * _eccentricitySquared / 64 -
                5 * _pow(_eccentricitySquared, 3) / 256));

    final e1 =
        (1 - math.sqrt(1 - _eccentricitySquared)) /
        (1 + math.sqrt(1 - _eccentricitySquared));

    final phi1Rad =
        mu +
        (3 * e1 / 2 - 27 * _pow(e1, 3) / 32) * math.sin(2 * mu) +
        (21 * e1 * e1 / 16 - 55 * _pow(e1, 4) / 32) * math.sin(4 * mu) +
        (151 * _pow(e1, 3) / 96) * math.sin(6 * mu) +
        (1097 * _pow(e1, 4) / 512) * math.sin(8 * mu);

    final sinPhi1 = math.sin(phi1Rad);
    final cosPhi1 = math.cos(phi1Rad);
    final tanPhi1 = math.tan(phi1Rad);

    final n1 =
        _equatorialRadius /
        math.sqrt(1 - _eccentricitySquared * sinPhi1 * sinPhi1);
    final t1 = tanPhi1 * tanPhi1;
    final c1 = eccPrimeSquared * cosPhi1 * cosPhi1;
    final r1 =
        _equatorialRadius *
        (1 - _eccentricitySquared) /
        _pow(1 - _eccentricitySquared * sinPhi1 * sinPhi1, 1.5);
    final d = x / (n1 * _scaleFactor);

    final latitude =
        phi1Rad -
        (n1 * tanPhi1 / r1) *
            (d * d / 2 -
                (5 + 3 * t1 + 10 * c1 - 4 * c1 * c1 - 9 * eccPrimeSquared) *
                    _pow(d, 4) /
                    24 +
                (61 +
                        90 * t1 +
                        298 * c1 +
                        45 * t1 * t1 -
                        252 * eccPrimeSquared -
                        3 * c1 * c1) *
                    _pow(d, 6) /
                    720);

    final longitude =
        _degreesToRadians(longitudeOrigin.toDouble()) +
        (d -
                (1 + 2 * t1 + c1) * _pow(d, 3) / 6 +
                (5 -
                        2 * c1 +
                        28 * t1 -
                        3 * c1 * c1 +
                        8 * eccPrimeSquared +
                        24 * t1 * t1) *
                    _pow(d, 5) /
                    120) /
            cosPhi1;

    return EditorCoordinate(
      latitude: _radiansToDegrees(latitude),
      longitude: _radiansToDegrees(longitude),
    );
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180;

  double _pow(double base, num exponent) => math.pow(base, exponent).toDouble();

  double _radiansToDegrees(double radians) => radians * 180 / math.pi;

  String _latitudeToZoneLetter(double latitude) {
    if (latitude >= 84) {
      return 'X';
    }
    if (latitude < -80) {
      return 'C';
    }

    const letters = 'CDEFGHJKLMNPQRSTUVWX';
    final index = ((latitude + 80) / 8).floor().clamp(0, letters.length - 1);
    return letters[index];
  }
}
