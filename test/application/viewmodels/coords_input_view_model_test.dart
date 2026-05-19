import 'package:coordinator_input/coordinator_input.dart';
import 'package:coordinator_input/src/domain/entities/location_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoordsInputViewModel', () {
    test('starts from initial coordinate and exposes geographic text', () {
      final viewModel = CoordsInputViewModel(
        initialCoordinate: const EditorCoordinate(
          latitude: -19.5356,
          longitude: -40.6306,
        ),
      );

      expect(
        viewModel.coordinate,
        const EditorCoordinate(latitude: -19.5356, longitude: -40.6306),
      );
      expect(viewModel.firstValue, '-19.535600');
      expect(viewModel.secondValue, '-40.630600');
    });

    test('starts from initial UTM coordinate when mode is UTM', () {
      final viewModel = CoordsInputViewModel(
        mode: CoordinateInputMode.utm,
        initialUtmCoordinate: const UtmCoordinate(
          easting: 326230.15,
          northing: 7838581.22,
          zoneNumber: 24,
          zoneLetter: 'K',
          northernHemisphere: false,
        ),
      );

      expect(
        viewModel.utmCoordinate,
        const UtmCoordinate(
          easting: 326230.15,
          northing: 7838581.22,
          zoneNumber: 24,
          zoneLetter: 'K',
          northernHemisphere: false,
        ),
      );
      expect(viewModel.coordinate, isNotNull);
      expect(viewModel.firstValue, '326230.150');
      expect(viewModel.secondValue, '7838581.220');
    });

    test('updates coordinate from valid geographic text', () {
      final viewModel = CoordsInputViewModel();

      final coordinate = viewModel.updateFromText(
        firstText: '-19.5356',
        secondText: '-40.6306',
      );

      expect(
        coordinate,
        const EditorCoordinate(latitude: -19.5356, longitude: -40.6306),
      );
      expect(viewModel.coordinate, coordinate);
      expect(viewModel.utmCoordinate, isNotNull);
    });

    test('ignores invalid geographic values', () {
      final viewModel = CoordsInputViewModel(
        initialCoordinate: const EditorCoordinate(latitude: 10, longitude: 20),
      );

      final coordinate = viewModel.updateFromText(
        firstText: '91',
        secondText: '20',
      );

      expect(coordinate, const EditorCoordinate(latitude: 10, longitude: 20));
      expect(
        viewModel.coordinate,
        const EditorCoordinate(latitude: 10, longitude: 20),
      );
    });

    test('updates coordinate from UTM text when mode changes', () {
      final viewModel = CoordsInputViewModel(
        initialCoordinate: const EditorCoordinate(
          latitude: -19.5356,
          longitude: -40.6306,
        ),
      );
      final originalUtm = viewModel.utmCoordinate!;

      viewModel.setMode(CoordinateInputMode.utm);
      final coordinate = viewModel.updateFromText(
        firstText: (originalUtm.easting + 10).toStringAsFixed(2),
        secondText: (originalUtm.northing + 10).toStringAsFixed(2),
      );

      expect(coordinate, isNotNull);
      expect(viewModel.coordinate, isNotNull);
      expect(
        viewModel.utmCoordinate!.easting,
        closeTo(originalUtm.easting + 10, 0.01),
      );
      expect(
        viewModel.utmCoordinate!.northing,
        closeTo(originalUtm.northing + 10, 0.01),
      );
    });

    test('loads current location and reports accuracy status', () async {
      final viewModel = CoordsInputViewModel(
        locationService: _FakeLocationService.success(
          const EditorCoordinate(latitude: 1.23, longitude: 4.56),
          accuracyInMeters: 8.4,
        ),
      );

      final coordinate = await viewModel.fillWithCurrentLocation();

      expect(
        coordinate,
        const EditorCoordinate(latitude: 1.23, longitude: 4.56),
      );
      expect(
        viewModel.coordinate,
        const EditorCoordinate(latitude: 1.23, longitude: 4.56),
      );
      expect(viewModel.statusMessage, 'Precisao estimada: 8.4 m');
      expect(viewModel.isLoadingLocation, isFalse);
    });

    test('keeps last accuracy after manual coordinate update', () async {
      final viewModel = CoordsInputViewModel(
        locationService: _FakeLocationService.success(
          const EditorCoordinate(latitude: 1.23, longitude: 4.56),
          accuracyInMeters: 8.4,
        ),
      );

      await viewModel.fillWithCurrentLocation();
      viewModel.updateFromText(firstText: '2.000000', secondText: '3.000000');

      expect(
        viewModel.coordinate,
        const EditorCoordinate(latitude: 2, longitude: 3),
      );
      expect(viewModel.statusMessage, 'Precisao estimada: 8.4 m');
    });

    test('keeps coordinate unchanged when location service fails', () async {
      final viewModel = CoordsInputViewModel(
        initialCoordinate: const EditorCoordinate(latitude: 1, longitude: 2),
        locationService: _FakeLocationService.failure('Erro controlado'),
      );

      final coordinate = await viewModel.fillWithCurrentLocation();

      expect(coordinate, const EditorCoordinate(latitude: 1, longitude: 2));
      expect(
        viewModel.coordinate,
        const EditorCoordinate(latitude: 1, longitude: 2),
      );
      expect(viewModel.statusMessage, 'Erro controlado');
    });

    test(
      'shows error and preserves last accuracy on location failure',
      () async {
        final viewModel = CoordsInputViewModel(
          locationService: _SequencedFakeLocationService([
            LocationResult.success(
              coordinate: const EditorCoordinate(
                latitude: 1.23,
                longitude: 4.56,
              ),
              accuracyInMeters: 8.4,
            ),
            const LocationResult.failure('Erro controlado'),
          ]),
        );

        await viewModel.fillWithCurrentLocation();
        await viewModel.fillWithCurrentLocation();

        expect(
          viewModel.statusMessage,
          'Erro controlado\nPrecisao estimada: 8.4 m',
        );
      },
    );
  });
}

class _FakeLocationService implements LocationService {
  const _FakeLocationService._(this._result);

  factory _FakeLocationService.success(
    EditorCoordinate coordinate, {
    double? accuracyInMeters,
  }) {
    return _FakeLocationService._(
      LocationResult.success(
        coordinate: coordinate,
        accuracyInMeters: accuracyInMeters,
      ),
    );
  }

  factory _FakeLocationService.failure(String message) {
    return _FakeLocationService._(LocationResult.failure(message));
  }

  final LocationResult _result;

  @override
  Future<LocationResult> getCurrentCoordinate() async => _result;
}

class _SequencedFakeLocationService implements LocationService {
  _SequencedFakeLocationService(this._results);

  final List<LocationResult> _results;
  int _index = 0;

  @override
  Future<LocationResult> getCurrentCoordinate() async {
    final result = _results[_index];
    if (_index < _results.length - 1) {
      _index += 1;
    }
    return result;
  }
}
