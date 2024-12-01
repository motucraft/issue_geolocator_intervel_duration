import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StreamSubscription<Position>? _positionStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Issue intervalDuration ')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _determinePosition,
              child: const Text('Determine Position'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startTracking,
              child: const Text('Start Tracking'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _stopTracking,
              child: const Text('Stop Tracking'),
            ),
          ],
        ),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _startTracking() {
    final androidSettings = AndroidSettings(
      intervalDuration: Duration(seconds: 10),
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: androidSettings).listen(
      (position) {
        log('${DateTime.now()} Position: ${position.latitude}, ${position.longitude}');
      },
      onError: (error) {
        log('Error: $error');
      },
    );

    log('Tracking started');
  }

  void _stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    log('Tracking stopped');
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}
