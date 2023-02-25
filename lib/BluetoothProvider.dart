import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'BluetoothManager.dart';
import 'RiderData.dart';

class BluetoothProvider with ChangeNotifier {
  static const platform = MethodChannel('edu.uf.karoo_collab');

  double partnerHR = 0;
  double partnerPower = 0;
  double partnerSpeed = 0;

  startListening() async {
    BluetoothManager.instance.deviceDataStream.listen((event) {
      final map = event.values.first;

      for(final key in map.keys) {
        switch(key) {
          case "heartRate":
              partnerHR = double.parse(map[key] ?? "-1");
            try {
              platform.invokeListMethod('setPartnerHR', {"hr": partnerHR});
              Logger.root.info('Partner HR set to $partnerHR');
            } on PlatformException catch (e) {
              Logger.root.severe('Failed to set partner HR: $e');
            }
            break;
          case "power":
              partnerPower = double.parse(map[key] ?? "-1");
            try {
              platform.invokeListMethod('setPartnerPower', {"power": partnerPower});
              Logger.root.info('Partner power set to $partnerPower');
            } on PlatformException catch (e) {
              Logger.root.severe('Failed to set partner power: $e');
            }
            break;
          case "speed":
              partnerSpeed = double.parse(map[key] ?? "-1");
            try {
              platform.invokeListMethod('setPartnerSpeed', {"speed": partnerSpeed});
              Logger.root.info('Partner power set to $partnerSpeed');
            } on PlatformException catch (e) {
              Logger.root.severe('Failed to set partner speed: $e');
            }
            break;
          default:
            Logger.root.warning('Unknown map key received: $key');
        }
      }

      notifyListeners();
    });

    final streamController = StreamController<RiderData>();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      try {
        final double myHR = platform.invokeMethod('getMyHR') as double;
        final double myPower = platform.invokeMethod('getMyPower') as double;

        final RiderData data = RiderData();
        data.heartRate = myHR;
        data.power = myPower;

        streamController.add(data);

      } on PlatformException catch (e) {
        Logger.root.severe('Failed to get partner data from Stream: $e');
      }
    });

    streamController.stream.listen((event) {
      BluetoothManager.instance.broadcastString("heartRate:${event.heartRate}");
      BluetoothManager.instance.broadcastString("power:${event.power}");
      //BluetoothManager.instance.broadcastString("speed:${event.speed}");

      notifyListeners();
    });
  }
}