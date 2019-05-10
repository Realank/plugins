import 'dart:async';
import 'package:flutter/services.dart';

const EventChannel _accelerometerEventChannel =
    EventChannel('plugins.flutter.io/sensors/accelerometer');

const EventChannel _userAccelerometerEventChannel =
    EventChannel('plugins.flutter.io/sensors/user_accel');

const EventChannel _gyroscopeEventChannel = EventChannel('plugins.flutter.io/sensors/gyroscope');

const EventChannel _altimeterEventChannel = EventChannel('plugins.flutter.io/sensors/altimeter');

const EventChannel _dcmEventChannel = EventChannel('plugins.flutter.io/sensors/dcm');

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

class DCMEvent {
  DCMEvent(
      this.m11, this.m12, this.m13, this.m21, this.m22, this.m23, this.m31, this.m32, this.m33);

  final double m11;
  final double m12;
  final double m13;
  final double m21;
  final double m22;
  final double m23;
  final double m31;
  final double m32;
  final double m33;

  @override
  String toString() => '[DCMEvent \n[$m11,$m12,$m13]\n[$m21,$m22,$m23]\n[$m31,$m32,$m33]\n]';
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

DCMEvent _listToDCMEvent(List<double> list) {
  return DCMEvent(list[0], list[1], list[2], list[3], list[4], list[5], list[6], list[7], list[8]);
}

Stream<AccelerometerEvent> _accelerometerEvents;
Stream<UserAccelerometerEvent> _userAccelerometerEvents;
Stream<GyroscopeEvent> _gyroscopeEvents;
Stream<AltimeterEvent> _altimeterEvents;
Stream<DCMEvent> _dcmEvents;

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

Stream<DCMEvent> get dcmEvents {
  if (_dcmEvents == null) {
    _dcmEvents = _dcmEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _listToDCMEvent(event.cast<double>()));
  }
  return _dcmEvents;
}
