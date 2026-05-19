import 'package:coordinator_input/coordinator_input.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coordinator Input Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B6E4F),
        ),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  EditorCoordinate? _coordinate = const EditorCoordinate(
    latitude: -19.5356,
    longitude: -40.6306,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinator Input Example'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Coordinate editor',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'This example uses the public package API and listens to coordinate updates from the widget.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          CoordsInput(
            initialCoordinate: _coordinate,
            onChanged: (coordinate) {
              setState(() {
                _coordinate = coordinate;
              });
            },
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected value',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _coordinate == null
                        ? 'No coordinate selected.'
                        : 'Latitude: ${_coordinate!.latitude.toStringAsFixed(6)}\nLongitude: ${_coordinate!.longitude.toStringAsFixed(6)}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
