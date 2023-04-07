import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' hide Logger;
import 'package:wakelock/wakelock.dart';
import '../ble_sensor_device.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:logging/logging.dart';
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


  static int myHR = 0;
  int myPower = 0;
  int myCadence = 0;
  int mySpeed = 0;

  int partnerHR = 0;
  int partnerPower = 0;
  int partnerCadence = 0;
  int partnerSpeed = 0;
  final RiderData data = RiderData();

  late StreamSubscription peerSubscription;
  StreamSubscription<List<int>>? subscribeStreamHR;

  int _readPower(List<int> data) {
    int total = data[3];
    /*
    data = [_, 0x??, 0x??, ...]
    want to read index 2 and 3 as one integer
    shift integer at index 3 left by 8 bits
    and add the 8 bits from index 2
    since the data is being stored in little-endian
    format
     */
    total = total << 8;
    return total + data[2];
  }

  //TODO: need to fix this
  double _readCadence(List<int> data) {
    int time = data[11] << 8;
    time += data[10];
    double timeDouble = time.toDouble();
    timeDouble *= 1/2048;
    return (1 / timeDouble) * 60.0;
  }

  @override
  void initState() {
    super.initState();

    startBluetoothListening();
    BluetoothManager.instance.deviceDataStream.listen((dataMap) {
      Logger.root.info('got data from a connection: $dataMap');
    });

    startPartnerListening();
    Wakelock.enable();
  }

  void startBluetoothListening() {
    if (widget.deviceList != null) {
      debugPrint("MAYBE GOTTEM?");
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
                myPower = _readPower(event);
                myCadence = _readCadence(event).toInt();
                // Broadcast power and cadence to partner.
                BluetoothManager.instance.broadcastString('power:$myPower');
                debugPrint("Broadcast string: power:$myPower");
                BluetoothManager.instance.broadcastString('cadence:$myCadence');
                debugPrint("Broadcast string: cadence:$myCadence");
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
            debugPrint("we Gottem");
            setState(() {
              partnerHR = int.parse(map[key] ?? "-1");
            });
            Logger.root.info('Set partner HR: $partnerHR');
            break;
          case "power":
            setState(() {
              partnerPower = int.parse(map[key] ?? "-1");
            });
            Logger.root.info('Set partner power: $partnerPower');
            break;
          case "cadence":
            setState(() {
              partnerCadence = int.parse(map[key] ?? "-1");
            });
            Logger.root.info('Set partner cadence: $partnerCadence');
            break;
          case "speed":
            setState(() {
              partnerSpeed = int.parse(map[key] ?? "-1");
            });
            Logger.root.info('Set partner speed: $partnerSpeed');
            break;
          default:
            Logger.root.warning('Unknown map key received: $key');
        }}
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
              child: Text(
                "HR: $myHR",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.w600),
              ),)
            ),
            SizedBox(
              child: FittedBox(
                child: Text(
                "Partner HR: $partnerHR",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, color: Colors.red.shade200, fontWeight: FontWeight.w600),

              ),)
            ),
            SizedBox(
              child: FittedBox(
              child: Text(
                "PWR: $myPower",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.w600),
              ),)
            ),
            SizedBox(
              child: FittedBox(
                child: Text(
                "Partner PWR: $partnerPower",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, color: Colors.red.shade200, fontWeight: FontWeight.w600),
              ),)
            ),
            SizedBox(
              child: FittedBox(
                child: Text(
                "Name: ${data.name}",
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
            Wakelock.disable();
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