import 'dart:async';
import 'package:flutter/material.dart';
import '../ble_sensor_device.dart';
import 'package:logging/logging.dart';
import 'package:screen/screen.dart';

import '../bluetooth_manager.dart';

class SoloWorkout extends StatefulWidget {
  final String title;
  const SoloWorkout({super.key,
    required this.title,
  });

  @override
  State<SoloWorkout> createState() => _SoloWorkout();
}

class _SoloWorkout extends State<SoloWorkout> {


  int myHR = 0;
  int myPower = 0;
  int mySpeed = 0;
  int? partnerHR = 0;
  int? partnerPower = 0;
  int? partnerSpeed = 0;
  late StreamSubscription peerSubscription;
  StreamSubscription<List<int>>? subscribeStreamHR;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: SizedBox(
        child: FloatingActionButton (
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)
          ),
          child: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                    "PWR: $myPower",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.w600),
                  ),)
            ),
          ],
        ),
      ),
    );
  }

}