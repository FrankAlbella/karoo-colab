import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'ble_sensor_device.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:karoo_collab/BluetoothProvider.dart';

import 'BluetoothDeviceListEntry.dart';
import 'BluetoothManager.dart';
import 'RiderData.dart';

import 'ProfilePage.dart';

class ActiveRun extends StatefulWidget {
  final FlutterReactiveBle flutterReactiveBle;
  final List<BleSensorDevice>? deviceList;
  final String title;
  const ActiveRun({super.key,
    required this.flutterReactiveBle,
    required this.deviceList,
    required this.title,
  });

  @override
  State<ActiveRun> createState() => _ActiveRun();
}

class _ActiveRun extends State<ActiveRun> {
  //random object for sending random numbers to connections
  Random random = Random();

  List<Widget> devices = [];
  bool scanning = false;

  Stream<BluetoothDiscoveryResult>? discoveryStream;
  StreamSubscription<BluetoothDiscoveryResult>? discoveryStreamSubscription;
  

  int myHR = 0;
  int myPower = 0;
  int mySpeed = 0;
  int? partnerHR = 0;
  int? partnerPower = 0;
  int? partnerSpeed = 0;
  late StreamSubscription peerSubscription;
  StreamSubscription<List<int>>? subscribeStreamHR;

  @override
  void initState() {
    super.initState();
    // BluetoothManager.instance.deviceDataStream.listen((dataMap) {
    //   print('got data from a connection: $dataMap');
    // });
    startBluetoothListening();
    peerSubscription = BluetoothManager.instance.deviceDataStream.listen((event) {
      setState(() {
        int type = int.parse(event.toString().substring(0, 1));
        int value = int.parse(event.toString().substring(3));
        switch (type) {
          case 0:
            partnerHR = value;
            break;
          default:
        }
      });
    });
  }

  void startBluetoothListening() {
    if (widget.deviceList != null) {
        for (BleSensorDevice device in widget.deviceList!) {
          debugPrint("we Gottem");
          if (device.type == 'HR') {
            debugPrint("Device sub: " + device.deviceId);
            subscribeStreamHR = widget.flutterReactiveBle.subscribeToCharacteristic(
              QualifiedCharacteristic(
                  characteristicId: device.characteristicId,
                  serviceId: device.serviceId,
                  deviceId: device.deviceId
              )).listen((event) {
              setState(() {
                // Update UI.
                myHR = event[1];
                // Broadcast heartrate to partner.
                BluetoothManager.instance.broadcastString('0: $myHR');
                debugPrint("send: " + myHR.toString());
                // Log heartrate.
                //widget.logger.workout.logHeartRate(event[1]);
              });
            });
          }
        }
    }
  }
  
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
          ],
        ),
      ),
      persistentFooterButtons: [
        IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
          alignment: Alignment.bottomLeft,
        ),
        SizedBox(width: 100),
        
      ],
      persistentFooterAlignment: AlignmentDirectional.bottomStart,
    );
  }
  
}