import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' hide Logger;
import '../ble_sensor_device.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:logging/logging.dart';
import 'package:screen/screen.dart';
import '../rider_data.dart';

import '../bluetooth_manager.dart';

class WorkoutPage extends StatefulWidget {
  final FlutterReactiveBle flutterReactiveBle;
  final List<BleSensorDevice>? deviceList;
  final String title;
  const WorkoutPage({super.key,
    required this.flutterReactiveBle,
    required this.deviceList,
    required this.title,
  });

  @override
  State<WorkoutPage> createState() => _WorkoutPage();
}

class _WorkoutPage extends State<WorkoutPage> {
  Stream<BluetoothDiscoveryResult>? discoveryStream;
  StreamSubscription<BluetoothDiscoveryResult>? discoveryStreamSubscription;
  

  int myHR = 0;
  int myPower = 0;
  int mySpeed = 0;
  int? partnerHR = 0;
  int? partnerPower = 0;
  int? partnerSpeed = 0;
  final RiderData data = RiderData();
  late StreamSubscription peerSubscription;
  StreamSubscription<List<int>>? subscribeStreamHR;

  @override
  void initState() {
    super.initState();
    
    // BluetoothManager.instance.deviceDataStream.listen((dataMap) {
    //   print('got data from a connection: $dataMap');
    // });
    startBluetoothListening();
    BluetoothManager.instance.deviceDataStream.listen((dataMap) {
      Logger.root.info('got data from a connection: $dataMap');
    });
    // peerSubscription = BluetoothManager.instance.deviceDataStream.listen((event) {
    //   setState(() {
    //     // ##:#
    //     int type = int.parse(event.toString().substring(0, 1));
    //     int value = int.parse(event.toString().substring(3));
    //     switch (type) {
    //       case 0:
    //         partnerHR = value;
    //         break;
    //       default:
    //     }
    //   });
    // });
    startPartnerListening();
    Screen.keepOn(true);
  }

  void startBluetoothListening() {
    if (widget.deviceList != null) {
        for (BleSensorDevice device in widget.deviceList!) {
          debugPrint("we Gottem");
          if (device.type == 'HR') {
            debugPrint("Device sub: ${device.deviceId}");
            subscribeStreamHR = widget.flutterReactiveBle.subscribeToCharacteristic(
              QualifiedCharacteristic(
                  characteristicId: device.characteristicId,
                  serviceId: device.serviceId,
                  deviceId: device.deviceId
              )).listen((event) {
              setState(() {
                // Update UI.
                myHR = event[1];
                // Broadcast heart rate to partner.
                BluetoothManager.instance.broadcastString('heartRate:$myHR');
                debugPrint("Broadcast string: heartRate:$myHR");
                // Log heart rate.
                //widget.logger.workout.logHeartRate(event[1]);
              });
            });
          }
          else if (device.type == 'POWER') {
            debugPrint("Device sub: ${device.deviceId}");
            subscribeStreamHR = widget.flutterReactiveBle.subscribeToCharacteristic(
              QualifiedCharacteristic(
                  characteristicId: device.characteristicId,
                  serviceId: device.serviceId,
                  deviceId: device.deviceId
              )).listen((event) {
              setState(() {
                // Update UI.
                myPower = event[1];
                // Broadcast heart rate to partner.
                BluetoothManager.instance.broadcastString('power:$myPower');
                debugPrint("Broadcast string: power:$myPower");
                // Log heart rate.
                //widget.logger.workout.logHeartRate(event[1]);
              });
            });
          }
        }
    }
  }

  void startPartnerListening() {
    BluetoothManager.instance.deviceDataStream.listen((event) {
      Logger.root.info('got data from a connection: $event');
      final map = event.values.first;

      for(final key in map.keys) {
        switch(key) {
          case "heartRate":
            partnerHR = int.parse(map[key] ?? "-1");
            Logger.root.info('Set partner HR: $partnerHR');
            break;
          case "power":
            partnerPower = int.parse(map[key] ?? "-1");
            Logger.root.info('Set partner power: $partnerPower');
            break;
          case "speed":
            partnerSpeed = int.parse(map[key] ?? "-1");
            Logger.root.info('Set partner speed: $partnerSpeed');
            break;
          default:
            Logger.root.warning('Unknown map key received: $key');
        }
      }
    });
  }
  
  @override
  void dispose() {
    peerSubscription = BluetoothManager.instance.deviceDataStream.listen((event) {});
    if (subscribeStreamHR != null) {
      subscribeStreamHR?.cancel();
    }
    super.dispose();
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // SizedBox(
            //   child: const Icon(Icons.heart_broken, size: 30, color: Colors.black,),
            // ),
            SizedBox(
              child: FittedBox(
                fit: BoxFit.scaleDown,
              child: Text(
                "HR: $myHR",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.w600),
              ),)
            ),
            SizedBox(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                "Partner HR: $partnerHR",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, color: Colors.red.shade200, fontWeight: FontWeight.w600),
              ),)
            ),
            SizedBox(
              child: FittedBox(
                fit: BoxFit.scaleDown,
              child: Text(
                "PWR: $myPower",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.w600),
              ),)
            ),
            SizedBox(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                "Partner PWR: $partnerPower",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, color: Colors.red.shade200, fontWeight: FontWeight.w600),
              ),)
            ),
            SizedBox(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                "Name: " + data.name,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, color: Colors.red.shade200, fontWeight: FontWeight.w600),
              ),)
            ),
          ],
        ),
      ),
      persistentFooterButtons: [
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Screen.keepOn(false);
            Navigator.pop(context);
          },
          alignment: Alignment.bottomLeft,
        ),
        const SizedBox(width: 100),
      ],
      persistentFooterAlignment: AlignmentDirectional.bottomStart,
    );
  }
}