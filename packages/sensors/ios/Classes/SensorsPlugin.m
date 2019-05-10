// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "SensorsPlugin.h"
#import <CoreMotion/CoreMotion.h>
#import <CoreMotion/CMAltimeter.h>

@implementation FLTSensorsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    //acc
  FLTAccelerometerStreamHandler* accelerometerStreamHandler =
      [[FLTAccelerometerStreamHandler alloc] init];
  FlutterEventChannel* accelerometerChannel =
      [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io/sensors/accelerometer"
                                binaryMessenger:[registrar messenger]];
  [accelerometerChannel setStreamHandler:accelerometerStreamHandler];
    //user acc
  FLTUserAccelStreamHandler* userAccelerometerStreamHandler =
      [[FLTUserAccelStreamHandler alloc] init];
  FlutterEventChannel* userAccelerometerChannel =
      [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io/sensors/user_accel"
                                binaryMessenger:[registrar messenger]];
  [userAccelerometerChannel setStreamHandler:userAccelerometerStreamHandler];
    //gyro
  FLTGyroscopeStreamHandler* gyroscopeStreamHandler = [[FLTGyroscopeStreamHandler alloc] init];
  FlutterEventChannel* gyroscopeChannel =
      [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io/sensors/gyroscope"
                                binaryMessenger:[registrar messenger]];
  [gyroscopeChannel setStreamHandler:gyroscopeStreamHandler];
    //alti
  FLTAltimeterStreamHandler* altimeterStreamHandler = [[FLTAltimeterStreamHandler alloc] init];
    FlutterEventChannel* altimeterChannel =
        [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io/sensors/altimeter"
                                  binaryMessenger:[registrar messenger]];
    [altimeterChannel setStreamHandler:altimeterStreamHandler];
}

@end

const double GRAVITY = 9.8;
CMMotionManager* _motionManager;
CMAltimeter * _altimeter;

void _initMotionManager() {
  if (!_motionManager) {
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.accelerometerUpdateInterval = 0.2;
    _motionManager.gyroUpdateInterval = 0.2;
    _motionManager.deviceMotionUpdateInterval = 0.2;
  }
}

void _initAltimeter () {
    if(!_altimeter) {
        _altimeter = [[CMAltimeter alloc]init];
    }
}

static void sendTriplet(Float64* dataList,NSInteger length, FlutterEventSink sink) {
  NSMutableData* event = [NSMutableData dataWithCapacity:length * sizeof(Float64)];
  [event appendBytes:dataList length:sizeof(Float64) * length];
  sink([FlutterStandardTypedData typedDataWithFloat64:event]);
}

@implementation FLTAccelerometerStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  _initMotionManager();
  [_motionManager
      startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
                           withHandler:^(CMAccelerometerData* accelerometerData, NSError* error) {
                             CMAcceleration acceleration = accelerometerData.acceleration;
                             // Multiply by gravity, and adjust sign values to
                             // align with Android.
                             Float64 datas[] =  {-acceleration.x * GRAVITY, -acceleration.y * GRAVITY,
                                                                                         -acceleration.z * GRAVITY};
                             sendTriplet(datas,3, eventSink);
                           }];
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  [_motionManager stopAccelerometerUpdates];
  return nil;
}

@end

@implementation FLTUserAccelStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  _initMotionManager();
  [_motionManager
      startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical toQueue:[[NSOperationQueue alloc] init]
                          withHandler:^(CMDeviceMotion* data, NSError* error) {
                            CMAcceleration acceleration = data.userAcceleration;
                            CMAttitude *attitude = data.attitude;
                            CMRotationMatrix matrix = attitude.rotationMatrix;
                            // Multiply by gravity, and adjust sign values to align with Android.
                            Float64 datas[] =  {-acceleration.x * GRAVITY,
                                                                                       -acceleration.y * GRAVITY,
                                                                                       -acceleration.z * GRAVITY,
                                                                                       attitude.roll,
                                                                                       attitude.pitch,
                                                                                       attitude.yaw,
                                                                                       matrix.m11,
                                                                                       matrix.m12,
                                                                                       matrix.m13,
                                                                                       matrix.m21,
                                                                                       matrix.m22,
                                                                                       matrix.m23,
                                                                                       matrix.m31,
                                                                                       matrix.m32,
                                                                                       matrix.m33};
                            sendTriplet(datas,
                                        15,
                                         eventSink);
                          }];
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  [_motionManager stopDeviceMotionUpdates];
  return nil;
}

@end



@implementation FLTGyroscopeStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  _initMotionManager();
  [_motionManager
      startGyroUpdatesToQueue:[[NSOperationQueue alloc] init]
                  withHandler:^(CMGyroData* gyroData, NSError* error) {
                    CMRotationRate rotationRate = gyroData.rotationRate;
                    Float64 datas[] = {rotationRate.x, rotationRate.y, rotationRate.z};
                    sendTriplet(datas,3, eventSink);
                  }];
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  [_motionManager stopGyroUpdates];
  return nil;
}

@end

@implementation FLTAltimeterStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  _initAltimeter();
  [_altimeter startRelativeAltitudeUpdatesToQueue:NSOperationQueue.mainQueue withHandler:^(CMAltitudeData * _Nullable altitudeData, NSError * _Nullable error) {
        float alti = [altitudeData.relativeAltitude floatValue];
        Float64 datas[] = {alti};
        sendTriplet(datas, 1, eventSink);

      }];
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  [_altimeter stopRelativeAltitudeUpdates];
  return nil;
}

@end

