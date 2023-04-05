import 'dart:io';
import 'package:flutter/material.dart';
import 'package:karoo_collab/pages/paired_workout.dart';
import 'package:karoo_collab/pages/settings_page.dart';
import 'package:karoo_collab/pages/solo_workout.dart';
import 'profile_page.dart';
import 'sensor_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
            ],
            ),
          ),
        )
    );
  }
}