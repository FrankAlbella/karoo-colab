import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:karoo_collab/pages/paired_workout.dart';
import 'package:karoo_collab/pages/settings_page.dart';
import 'package:karoo_collab/pages/solo_workout.dart';
import '../logging/exercise_logger.dart';
import '../logging/logger_constants.dart';
import 'sensor_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<void> _testLogger() async {
  ExerciseLogger.instance?.logAppLaunched("pageName");
  ExerciseLogger.instance?.logAppClosed("pageName");
  ExerciseLogger.instance?.logButtonPressed("buttonName");
  ExerciseLogger.instance?.logPageNavigate("prev", "current");
  ExerciseLogger.instance?.logSettingChanged("settingName", "previousValue", "currentValue");
  ExerciseLogger.instance?.logWorkoutStarted(WorkoutType.cycling);
  ExerciseLogger.instance?.logWorkoutEnded(WorkoutType.cycling);
  ExerciseLogger.instance?.logWorkoutPaused();
  ExerciseLogger.instance?.logWorkoutUnpaused();
  ExerciseLogger.instance?.logPartnerConnected("partnerName", "partnerDeviceId", "partnerSerialNum");
  ExerciseLogger.instance?.logPartnerDisconnected("partnerName", "partnerId");
  ExerciseLogger.instance?.logBluetoothInit();
  ExerciseLogger.instance?.logBluetoothConnect("deviceConnectedName");
  ExerciseLogger.instance?.logBluetoothDisconnect("deviceDisconnectedName");
  ExerciseLogger.instance?.logHeartRateData(1);
  ExerciseLogger.instance?.logPowerData(2);
  ExerciseLogger.instance?.logDistanceData(3);
  ExerciseLogger.instance?.saveToFile();
  ExerciseLogger.instance?.insertInDatabase();

}

class _MyHomePageState extends State<MyHomePage> {

  Future<void> initLogger() async{
    await ExerciseLogger.create(DeviceType.karoo);
    ExerciseLogger.instance?.logAppLaunched("home_page");
  }

  @override
  void initState() {
    super.initState();
    initLogger();
  }

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
              exit(0); //Might need better method of exiting app
            },
          ),
        ),
        body: Center(
          child: SizedBox(
            width: 175,
            child: ListView(shrinkWrap: true, children: <Widget>[
              SizedBox(
                  height: 65,
                  width: 10,
                  child: Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.all(0)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const PartnerWorkout(
                                        title: 'Paired Workout')));
                          },
                          child: const ListTile(
                            title: Text("PAIRED WORKOUT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                )),
                          )))),
              SizedBox(
                  height: 65,
                  width: 10,
                  child: Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.all(0)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SoloWorkout(
                                        title: 'Solo Workout')));
                          },
                          child: const ListTile(
                            title: Text("SOLO WORKOUT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                )),
                          )))),
              SizedBox(
                  height: 65,
                  width: 10,
                  child: Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.all(0)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SettingsPage(
                                        title: 'Settings')));
                          },
                          child: const ListTile(
                            title: Text("SETTINGS",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                )),
                          )))),
              SizedBox(
                  height: 65,
                  width: 10,
                  child: Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.all(0)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SensorPage(
                                        title: 'Sensors')));
                          },
                          child: const ListTile(
                            title: Text("SENSORS",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                )),
                          )))),
              SizedBox(
                  height: 65,
                  width: 10,
                  child: Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.all(0)),
                          onPressed: () {
                           _testLogger();
                          },
                          child: const ListTile(
                            title: Text("Test Logging!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                )),
                          ))))

            ],
            ),
          ),
        )
    );
  }
}