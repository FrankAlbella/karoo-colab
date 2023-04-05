import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wakelock/wakelock.dart';

class SoloWorkout extends StatefulWidget {
  final String title;

  const SoloWorkout({
    super.key,
    required this.title,
  });

  @override
  State<SoloWorkout> createState() => _SoloWorkout();
}

class _SoloWorkout extends State<SoloWorkout> {
  int myHR = 0;
  int myPower = 0;
  int mySpeed = 0;
  Duration duration = Duration();
  Timer? timer;
  int distance = 0;
  int? partnerHR = 0;
  int? partnerPower = 0;
  int? partnerSpeed = 0;

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

  @override
  void initState() {
    super.initState();
    startTimer();
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
