# coordinator_input

`coordinator_input` is a Flutter package that provides a coordinate editor with two synchronized modes:

- Geographic coordinates (`latitude` / `longitude`)
- UTM coordinates (`easting` / `northing`)

The package also supports reading the device's current location through `geolocator` and exposes a testable MVVM structure for custom integrations.

## Features

- Toggle between geographic and UTM input
- Keep both representations synchronized
- Start with an initial coordinate
- Receive geographic updates through `onChanged`
- Receive updates in the active mode through `onValueChanged`
- Fill the form with the current device location
- Test-friendly architecture with separated domain, viewmodel, and infrastructure layers

## Getting started

Add the dependency:

```yaml
dependencies:
  coordinator_input: ^1.0.0
```

If you want to use current location, configure the native permissions required by `geolocator` in Android and iOS.

## Usage

```dart
import 'package:coordinator_input/coordinator_input.dart';
import 'package:flutter/material.dart';

class CoordinateForm extends StatelessWidget {
  const CoordinateForm({super.key});

  @override
  Widget build(BuildContext context) {
    return CoordsInput(
      initialCoordinate: const EditorCoordinate(
        latitude: -19.5356,
        longitude: -40.6306,
      ),
      onChanged: (coordinate) {
        debugPrint('Geographic coordinate: $coordinate');
      },
      onValueChanged: (value) {
        debugPrint('Current mode value: $value');
      },
    );
  }
}
```

When `CoordsInput` is in geographic mode, `onValueChanged` emits an
`EditorCoordinate`. When it is in UTM mode, it emits a `UtmCoordinate`.

## Architecture

Public package entrypoint:

- `CoordsInput` for UI usage
- `EditorCoordinate` and `UtmCoordinate` for domain data
- `CoordinateConverter` for coordinate transformations
- `CoordsInputViewModel` and `LocationService` for customization and tests

## License

This package is available under the MIT license.

## Testing

Run:

```bash
flutter test
```
