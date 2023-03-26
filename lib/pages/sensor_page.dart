import 'dart:math';
import 'package:flutter/material.dart';
import '../bluetooth_manager.dart';
import '../rider_data.dart';
import '../monitor_sensor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../ble_sensor_device.dart';
import 'package:screen/screen.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<SensorPage> createState() => _SensorPage();
}

class _SensorPage extends State<SensorPage> {
  // final flutterReactiveBle = FlutterReactiveBle();
  // List<BleSensorDevice> connectedDevices = <BleSensorDevice>[];
  late double dialogWidth = MediaQuery.of(context).size.width * 1;
  late double dialogHeight = MediaQuery.of(context).size.height * 1;
  final LayerLink layerLink = LayerLink();

  // Obtain FlutterReactiveBle instance for entire app.
  final flutterReactiveBle = FlutterReactiveBle();

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
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.center,
              child: Text("Choose device to pair",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  )),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: MonitorConnect(
                  flutterReactiveBle: flutterReactiveBle,
                  callback: (deviceList) => setState(() {
                        RiderData.connectedDevices = deviceList;
                      }),
                  connectedDevices: RiderData.connectedDevices,
                  offset: const Offset(.1, .1),
                  link: layerLink,
                  dialogWidth: dialogWidth,
                  dialogHeight: dialogHeight),
            ),
          ),
        ],
      ),
      persistentFooterButtons: [
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
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
