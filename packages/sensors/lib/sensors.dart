import 'dart:async';
import 'package:flutter/services.dart';

const EventChannel _accelerometerEventChannel =
    EventChannel('plugins.flutter.io/sensors/accelerometer');

const EventChannel _userAccelerometerEventChannel =
    EventChannel('plugins.flutter.io/sensors/user_accel');

const EventChannel _gyroscopeEventChannel = EventChannel('plugins.flutter.io/sensors/gyroscope');

const EventChannel _altimeterEventChannel = EventChannel('plugins.flutter.io/sensors/altimeter');

class AccelerometerEvent {
  AccelerometerEvent(this.x, this.y, this.z);

  /// Acceleration force along the x axis (including gravity) measured in m/s^2.
  final double x;

  /// Acceleration force along the y axis (including gravity) measured in m/s^2.
  final double y;

  /// Acceleration force along the z axis (including gravity) measured in m/s^2.
  final double z;

  @override
  String toString() => '[AccelerometerEvent (x: $x, y: $y, z: $z)]';
}

class UserAccelerometerEvent {
  UserAccelerometerEvent(this.x, this.y, this.z, this.roll, this.pitch, this.yaw);

  /// Acceleration force along the x axis (excluding gravity) measured in m/s^2.
  final double x;

  /// Acceleration force along the y axis (excluding gravity) measured in m/s^2.
  final double y;

  /// Acceleration force along the z axis (excluding gravity) measured in m/s^2.
  final double z;

  final double roll;
  final double pitch;
  final double yaw;

  @override
  String toString() => '[UserAccelerometerEvent (x: $x, y: $y, z: $z)]';
}

class GyroscopeEvent {
  GyroscopeEvent(this.x, this.y, this.z);

  /// Rate of rotation around the x axis measured in rad/s.
  final double x;

  /// Rate of rotation around the y axis measured in rad/s.
  final double y;

  /// Rate of rotation around the z axis measured in rad/s.
  final double z;

  @override
  String toString() => '[GyroscopeEvent (x: $x, y: $y, z: $z)]';
}

class AltimeterEvent {
  AltimeterEvent(this.height);

  /// altimeter in meters.
  final double height;

  @override
  String toString() => '[AltimeterEvent (height: $height)]';
}

AccelerometerEvent _listToAccelerometerEvent(List<double> list) {
  return AccelerometerEvent(list[0], list[1], list[2]);
}

UserAccelerometerEvent _listToUserAccelerometerEvent(List<double> list) {
  if (list.length >= 6) {
    return UserAccelerometerEvent(list[0], list[1], list[2], list[3], list[4], list[5]);
  } else {
    return UserAccelerometerEvent(list[0], list[1], list[2], 0, 0, 0);
  }
}

GyroscopeEvent _listToGyroscopeEvent(List<double> list) {
  return GyroscopeEvent(list[0], list[1], list[2]);
}

AltimeterEvent _listToAltimeterEvent(List<double> list) {
  return AltimeterEvent(list[0]);
}

Stream<AccelerometerEvent> _accelerometerEvents;
Stream<UserAccelerometerEvent> _userAccelerometerEvents;
Stream<GyroscopeEvent> _gyroscopeEvents;
Stream<AltimeterEvent> _altimeterEvents;

/// A broadcast stream of events from the device accelerometer.
Stream<AccelerometerEvent> get accelerometerEvents {
  if (_accelerometerEvents == null) {
    _accelerometerEvents = _accelerometerEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _listToAccelerometerEvent(event.cast<double>()));
  }
  return _accelerometerEvents;
}

/// Events from the device accelerometer with gravity removed.
Stream<UserAccelerometerEvent> get userAccelerometerEvents {
  if (_userAccelerometerEvents == null) {
    _userAccelerometerEvents = _userAccelerometerEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _listToUserAccelerometerEvent(event.cast<double>()));
  }
  return _userAccelerometerEvents;
}

/// A broadcast stream of events from the device gyroscope.
Stream<GyroscopeEvent> get gyroscopeEvents {
  if (_gyroscopeEvents == null) {
    _gyroscopeEvents = _gyroscopeEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _listToGyroscopeEvent(event.cast<double>()));
  }
  return _gyroscopeEvents;
}

/// Events from the device accelerometer with gravity removed.
Stream<AltimeterEvent> get altimeterEvents {
  if (_altimeterEvents == null) {
    _altimeterEvents = _altimeterEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _listToAltimeterEvent(event.cast<double>()));
  }
  return _altimeterEvents;
}
