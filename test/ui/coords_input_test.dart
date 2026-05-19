import 'package:coordinator_input/coordinator_input.dart';
import 'package:coordinator_input/src/domain/entities/location_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders initial coordinate and notifies changes', (
    tester,
  ) async {
    EditorCoordinate? changedCoordinate;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoordsInput(
            initialCoordinate: const EditorCoordinate(
              latitude: -19.5356,
              longitude: -40.6306,
            ),
            locationService: _FakeLocationService.success(
              const EditorCoordinate(latitude: 1.23, longitude: 4.56),
            ),
            onChanged: (coordinate) {
              changedCoordinate = coordinate;
            },
          ),
        ),
      ),
    );

    expect(find.widgetWithText(TextField, 'Latitude'), findsOneWidget);
    final editableTexts = tester
        .widgetList<EditableText>(find.byType(EditableText))
        .toList();

    expect(editableTexts[0].controller.text, '-19.535600');
    expect(editableTexts[1].controller.text, '-40.630600');

    await tester.enterText(find.byType(TextField).first, '-20.000000');
    await tester.pump();

    expect(
      changedCoordinate,
      const EditorCoordinate(latitude: -20, longitude: -40.6306),
    );

    await tester.tap(find.text('UTM X / Y'));
    await tester.pump();

    expect(find.textContaining('Zona UTM'), findsOneWidget);
  });

  testWidgets('returns UTM value when current mode is UTM', (tester) async {
    Object? changedCoordinate;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoordsInput(
            initialCoordinate: const EditorCoordinate(
              latitude: -19.5356,
              longitude: -40.6306,
            ),
            onValueChanged: (coordinate) {
              changedCoordinate = coordinate;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('UTM X / Y'));
    await tester.pump();

    expect(changedCoordinate, isA<UtmCoordinate>());

    await tester.enterText(find.byType(TextField).first, '326240.150');
    await tester.pump();

    expect(changedCoordinate, isA<UtmCoordinate>());
    expect(
      changedCoordinate,
      isA<UtmCoordinate>().having(
        (value) => value.easting,
        'easting',
        326240.15,
      ),
    );
  });

  testWidgets('renders initial UTM values when mode is UTM', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoordsInput(
            mode: CoordinateInputMode.utm,
            initialUtmCoordinate: const UtmCoordinate(
              easting: 326230.15,
              northing: 7838581.22,
              zoneNumber: 24,
              zoneLetter: 'K',
              northernHemisphere: false,
            ),
          ),
        ),
      ),
    );

    expect(find.widgetWithText(TextField, 'UTM X'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'UTM Y'), findsOneWidget);

    final editableTexts = tester
        .widgetList<EditableText>(find.byType(EditableText))
        .toList();
    expect(editableTexts[0].controller.text, '326230.150');
    expect(editableTexts[1].controller.text, '7838581.220');
    expect(find.text('Zona UTM 24K'), findsOneWidget);
  });

  testWidgets('keeps partially typed coordinate text untouched while editing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoordsInput(
            initialCoordinate: const EditorCoordinate(
              latitude: -19.5356,
              longitude: -40.6306,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, '1.');
    await tester.pump();

    final editableTexts = tester
        .widgetList<EditableText>(find.byType(EditableText))
        .toList();
    expect(editableTexts[0].controller.text, '1.');
  });

  testWidgets(
    'keeps showing last accuracy after manual edits and parent updates',
    (tester) async {
      Object? parentCoordinate;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: CoordsInput(
                  initialCoordinate: parentCoordinate is EditorCoordinate
                      ? parentCoordinate as EditorCoordinate
                      : null,
                  initialUtmCoordinate: parentCoordinate is UtmCoordinate
                      ? parentCoordinate as UtmCoordinate
                      : null,
                  locationService: _FakeLocationService.success(
                    const EditorCoordinate(latitude: 1.23, longitude: 4.56),
                    accuracyInMeters: 8.4,
                  ),
                  onChanged: (coordinate) {
                    setState(() {
                      parentCoordinate = coordinate;
                    });
                  },
                  onValueChanged: (coordinate) {
                    setState(() {
                      parentCoordinate = coordinate;
                    });
                  },
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Local atual'));
      await tester.pumpAndSettle();

      expect(find.text('Precisao estimada: 8.4 m'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '2.000000');
      await tester.pumpAndSettle();

      expect(find.text('Precisao estimada: 8.4 m'), findsOneWidget);
    },
  );
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

  final LocationResult _result;

  @override
  Future<LocationResult> getCurrentCoordinate() async => _result;
}
