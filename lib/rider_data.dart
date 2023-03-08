import 'package:flutter/material.dart';

import 'ble_sensor_device.dart';

class RiderData {
  late double heartRate;
  late double power;
  late double speed;

  static List<BleSensorDevice> connectedDevices = <BleSensorDevice>[];
}