import 'dart:math';
import 'package:flutter/material.dart';
import 'BluetoothManager.dart';
import 'PairingPage.dart';
import 'monitor_sensor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'ble_sensor_device.dart';
import 'dart:async';
import 'package:flutter/services.dart';

Widget _buildPopupDialog(BuildContext context) {
  return AlertDialog(
    title: const Text('Popup example'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        Text("Hello"),
      ],
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Confirm'),
      ),
    ],
  );
}

class SensorsPage extends StatefulWidget {
  const SensorsPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<SensorsPage> createState() => _SensorsPage();
}

class _SensorsPage extends State<SensorsPage> {
  final flutterReactiveBle = FlutterReactiveBle();
  List<BleSensorDevice> connectedDevices = <BleSensorDevice>[];
  late double dialogWidth = MediaQuery.of(context).size.width * 0.9;
  late double dialogHeight = MediaQuery.of(context).size.height * .60;
  final LayerLink layerLink = LayerLink();
  late OverlayEntry overlayEntry;
  late Offset dialogOffset;

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
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
          children: <Widget>[
            TextButton.icon(
              onPressed: () {
                showConnectMonitorsDialog();
              },
              icon: Icon(
                Icons.people,
              ),
              label: const Align(
                  alignment: Alignment.centerLeft,
                  child: ListTile(
                      title: Text("Sensors"),
                      trailing: Icon(Icons.keyboard_arrow_right))),
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

  void showConnectMonitorsDialog() {
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Stack(
            children: <Widget>[
              Positioned(
                width: dialogWidth,
                height: dialogHeight,
                top: 0.0,
                left: 0.0,
                child: MonitorConnect(
                    flutterReactiveBle: flutterReactiveBle,
                    callback: (deviceList)=> setState(() {
                      connectedDevices = deviceList;
                    }),
                    connectedDevices: connectedDevices,
                    offset: dialogOffset,
                    link: layerLink,
                    dialogWidth: dialogWidth,
                    dialogHeight: dialogHeight,
                    overlayEntry: overlayEntry
                ),
              )
            ]
        );
      },
    );
    Overlay.of(context)?.insert(overlayEntry);
  }
}
