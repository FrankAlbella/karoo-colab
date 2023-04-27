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

  static String partnerName = "Unknown";
  static int partnerMaxHR = 120;
  static int partnerFtp = 250;

  static List<BleSensorDevice> connectedDevices = <BleSensorDevice>[];
}