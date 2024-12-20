import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
import 'dart:async';

void main() {
  runApp(SensorProbeApp());
}

class SensorProbeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor Probe App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SensorProbeHomePage(),
    );
  }
}

class SensorProbeHomePage extends StatefulWidget {
  @override
  _SensorProbeHomePageState createState() => _SensorProbeHomePageState();
}

class _SensorProbeHomePageState extends State<SensorProbeHomePage> {
  List<Map<String, dynamic>> _availableSensors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _probeSensors();
  }

  Future<void> _probeSensors() async {
    final List<Map<String, dynamic>> sensors = [];

    await _probeAccelerometer(sensors);
    await _probeGyroscope(sensors);
    await _probeMagnetometer(sensors);
    await _probeBarometer(sensors);
    await _probeDeviceInfo(sensors);

    setState(() {
      _availableSensors = sensors;
      _isLoading = false;
    });
  }

  Future<void> _probeAccelerometer(List<Map<String, dynamic>> sensors) async {
    try {
      final completer = Completer<void>();
      StreamSubscription? subscription;

      subscription = accelerometerEvents.listen((AccelerometerEvent event) {
        sensors.add({
          'type': 'Accelerometer',
          'available': true,
          'details': 'Detects device acceleration',
          'x': event.x.toStringAsFixed(2),
          'y': event.y.toStringAsFixed(2),
          'z': event.z.toStringAsFixed(2)
        });
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }, onError: (error) {
        sensors.add({
          'type': 'Accelerometer',
          'available': false,
          'details': 'Sensor detection failed'
        });
        if (!completer.isCompleted) {
          completer.complete();
        }
      }, cancelOnError: true);

      await completer.future.timeout(
        Duration(seconds: 2),
        onTimeout: () {
          subscription?.cancel();
          sensors.add({
            'type': 'Accelerometer',
            'available': false,
            'details': 'Sensor timeout'
          });
        },
      );
    } catch (e) {
      sensors.add({
        'type': 'Accelerometer',
        'available': false,
        'details': 'Probe exception occurred'
      });
    }
  }

  Future<void> _probeGyroscope(List<Map<String, dynamic>> sensors) async {
    try {
      final completer = Completer<void>();
      StreamSubscription? subscription;

      subscription = gyroscopeEvents.listen((GyroscopeEvent event) {
        sensors.add({
          'type': 'Gyroscope',
          'available': true,
          'details': 'Measures device rotation',
          'x': event.x.toStringAsFixed(2),
          'y': event.y.toStringAsFixed(2),
          'z': event.z.toStringAsFixed(2)
        });
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }, onError: (error) {
        sensors.add({
          'type': 'Gyroscope',
          'available': false,
          'details': 'Sensor detection failed'
        });
        if (!completer.isCompleted) {
          completer.complete();
        }
      }, cancelOnError: true);

      await completer.future.timeout(
        Duration(seconds: 2),
        onTimeout: () {
          subscription?.cancel();
          sensors.add({
            'type': 'Gyroscope',
            'available': false,
            'details': 'Sensor timeout'
          });
        },
      );
    } catch (e) {
      sensors.add({
        'type': 'Gyroscope',
        'available': false,
        'details': 'Probe exception occurred'
      });
    }
  }

  Future<void> _probeMagnetometer(List<Map<String, dynamic>> sensors) async {
    try {
      final completer = Completer<void>();
      StreamSubscription? subscription;

      subscription = magnetometerEvents.listen((MagnetometerEvent event) {
        sensors.add({
          'type': 'Magnetometer',
          'available': true,
          'details': 'Detects magnetic field',
          'x': event.x.toStringAsFixed(2),
          'y': event.y.toStringAsFixed(2),
          'z': event.z.toStringAsFixed(2)
        });
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }, onError: (error) {
        sensors.add({
          'type': 'Magnetometer',
          'available': false,
          'details': 'Sensor detection failed'
        });
        if (!completer.isCompleted) {
          completer.complete();
        }
      }, cancelOnError: true);

      await completer.future.timeout(
        Duration(seconds: 2),
        onTimeout: () {
          subscription?.cancel();
          sensors.add({
            'type': 'Magnetometer',
            'available': false,
            'details': 'Sensor timeout'
          });
        },
      );
    } catch (e) {
      sensors.add({
        'type': 'Magnetometer',
        'available': false,
        'details': 'Probe exception occurred'
      });
    }
  }

  Future<void> _probeBarometer(List<Map<String, dynamic>> sensors) async {
    try {
      // Placeholder for barometer probe due to limitations in sensors_plus
      sensors.add({
        'type': 'Barometer',
        'available': false,
        'details': 'Barometer sensor detection not directly supported',
        'pressure': 'N/A'
      });
    } catch (e) {
      sensors.add({
        'type': 'Barometer',
        'available': false,
        'details': 'Barometer probe exception occurred',
        'pressure': 'N/A'
      });
    }
  }

  Future<void> _probeDeviceInfo(List<Map<String, dynamic>> sensors) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        sensors.add({
          'type': 'Device Model',
          'name': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'osVersion': androidInfo.version.release,
        });
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        sensors.add({
          'type': 'Device Model',
          'name': iosInfo.model,
          'manufacturer': 'Apple',
          'osVersion': iosInfo.systemVersion,
        });
      }
    } catch (e) {
      sensors.add({
        'type': 'Device Model',
        'available': false,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Probe App'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _probeSensors,
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _availableSensors.length,
        itemBuilder: (context, index) {
          final sensor = _availableSensors[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                sensor['type'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: _buildSensorDetails(sensor),
              trailing: Icon(
                sensor['available'] ?? false
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                color: sensor['available'] ?? false
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSensorDetails(Map<String, dynamic> sensor) {
    switch (sensor['type']) {
      case 'Device Model':
        return Text(
          '${sensor['name'] ?? 'Unknown'} (${sensor['manufacturer'] ?? 'Unknown'})\n'
              'OS Version: ${sensor['osVersion'] ?? 'N/A'}',
        );
      case 'Accelerometer':
      case 'Gyroscope':
      case 'Magnetometer':
        return Text(
          sensor['available'] ?? false
              ? '${sensor['details'] ?? 'Sensor Available'}\n'
              'X: ${sensor['x'] ?? 'N/A'}, '
              'Y: ${sensor['y'] ?? 'N/A'}, '
              'Z: ${sensor['z'] ?? 'N/A'}'
              : 'Sensor Not Available',
        );
      case 'Barometer':
        return Text(
          sensor['available'] ?? false
              ? '${sensor['details'] ?? 'Sensor Available'}\n'
              'Pressure: ${sensor['pressure'] ?? 'N/A'}'
              : 'Barometer Sensor Not Available',
        );
      default:
        return Text('No additional details');
    }
  }
}