import 'package:flutter/material.dart';

import 'ble_sensor_device.dart';

class RiderData {
  late double heartRate;
  late double power;
  late double speed;
  String name = "User";
  String email = "example@gmail.com";
  String maxHR = "122";
  String FTPvalue = "122";

  static List<BleSensorDevice> connectedDevices = <BleSensorDevice>[];
}