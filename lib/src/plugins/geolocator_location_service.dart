import 'package:coordinator_input/coordinator_input.dart';
import 'package:coordinator_input/src/domain/entities/location_result.dart';
import 'package:geolocator/geolocator.dart';

/// [LocationService] implementation backed by the `geolocator` plugin.
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<LocationResult> getCurrentCoordinate() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult.failure(
        'Ative o servico de localizacao para continuar.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const LocationResult.failure('Permissao de localizacao negada.');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );

      return LocationResult.success(
        coordinate: EditorCoordinate(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
        accuracyInMeters: position.accuracy,
      );
    } catch (_) {
      return const LocationResult.failure(
        'Nao foi possivel obter a localizacao atual.',
      );
    }
  }
}
