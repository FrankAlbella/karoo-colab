import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wakelock/wakelock.dart';

import '../ble_sensor_device.dart';
import '../bluetooth_manager.dart';
import '../rider_data.dart';

class SoloWorkout extends StatefulWidget {
  final String title;
  final FlutterReactiveBle flutterReactiveBle;
  final List<BleSensorDevice>? deviceList;

  const SoloWorkout({
    super.key,
    required this.flutterReactiveBle,
    required this.deviceList,
    required this.title,
  });

  @override
  State<SoloWorkout> createState() => _SoloWorkout();
}

class _SoloWorkout extends State<SoloWorkout> {

  static int myHR = 0;
  int myPower = 0;
  int myCadence = 0;
  int mySpeed = 0;
  Duration duration = Duration();
  Timer? timer;
  int distance = 0;

  final RiderData data = RiderData();

  late StreamSubscription peerSubscription;
  StreamSubscription<List<int>>? subscribeStreamHR;

  int _readPower(List<int> data) {
    int total = data[3];
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

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void addTime() {
    setState(() {
      final seconds = duration.inSeconds + 1;
      duration = Duration(seconds: seconds);

      //Testing purposes for peers
      //BluetoothManager.instance.broadcastString('0: ${rng.nextInt(200)}');
      //BluetoothManager.instance.broadcastString('1: ${150}');
    });
  }

  void startSensorListening() {
    if (widget.deviceList != null) {
      for (BleSensorDevice device in widget.deviceList!) {
        if (device.type == 'HR') {
          debugPrint("Device sub: ${device.deviceId}");
          subscribeStreamHR = widget.flutterReactiveBle.subscribeToCharacteristic(
              QualifiedCharacteristic(
                  characteristicId: device.characteristicId,
                  serviceId: device.serviceId,
                  deviceId: device.deviceId
              )).listen((event) {
            setState(() {
              myHR = event[1];
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
              myPower = _readPower(event);
              myCadence = _readCadence(event).toInt();
            });
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    startSensorListening();
    Wakelock.enable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: SizedBox(
        child: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Wakelock.disable();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
          child: Column(children: [
        Row(
          children: const <Widget>[
            Text("SPEED", style: TextStyle(fontSize: 25)),
            Spacer(),
            Text("SPEED", style: TextStyle(fontSize: 25)),
            Spacer(),
            Text("SPEED", style: TextStyle(fontSize: 25)),
          ],
        ),
        Row(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                  child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "HR: $myHR",
                  style: const TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
              )),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                  child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "PWR: $myPower",
                  style: const TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
              )),
            ),
          ],
        ),
      ])),
    );
  }
}
