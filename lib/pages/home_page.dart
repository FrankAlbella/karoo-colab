import 'dart:io';
import 'package:flutter/material.dart';
import 'package:karoo_collab/pages/paired_workout.dart';
import 'package:karoo_collab/pages/solo_workout.dart';
import 'profile_page.dart';
import 'sensor_page.dart';
import 'host_page.dart';
import 'join_page.dart';
import 'settings_page.dart';

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
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          children: <Widget>[
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const HostPage(title: 'Host Workout')),
                );
              },
              icon: const Icon(
                Icons.people,
              ),
              label: const Align(
                  alignment: Alignment.centerLeft,
                  child: ListTile(
                      title: Text("Host Workout"),
                      trailing: Icon(Icons.keyboard_arrow_right))),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const JoinPage(title: 'Join Workout')),
                );
              },
              icon: const Icon(
                Icons.people,
              ),
              label: const Align(
                  alignment: Alignment.centerLeft,
                  child: ListTile(
                      title: Text("Join Workout"),
                      trailing: Icon(Icons.keyboard_arrow_right))),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const SensorPage(title: "Sensor Pairing")
                  )
                );
              },
              icon: const Icon(
                Icons.sensors
              ),
              label: const Align(
                alignment: Alignment.centerLeft,
                child: ListTile(
                  title: Text("Sensors"),
                  trailing: Icon(Icons.keyboard_arrow_right),
                )
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const SettingsPage(title: "Settings")
                    )
                );
              },
              icon: const Icon(
                Icons.settings
              ),
              label: const Align(
                alignment: Alignment.centerLeft,
                child: ListTile(
                  title: Text("Settings"),
                  trailing: Icon(Icons.keyboard_arrow_right),
                )
              ),
            ),
          ],
        ),
      )
    );
  }
}
