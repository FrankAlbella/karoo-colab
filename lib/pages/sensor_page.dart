import 'dart:math';
import 'package:flutter/material.dart';
import 'package:karoo_collab/pages/workout_page.dart';
import '../bluetooth_manager.dart';
import 'pairing_page.dart';
import '../monitor_sensor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../ble_sensor_device.dart';
import 'dart:async';
import 'package:flutter/services.dart';

Random random = Random();

void sayHi() async {
  final int randomNum = random.nextInt(100);
  String dataStr = "randomNum:$randomNum";
  print("Broadcasting data: $dataStr");
  BluetoothManager.instance.broadcastString(dataStr);
}

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
  late OverlayEntry overlayEntry;

  static const platform = MethodChannel('edu.uf.karoo_collab');

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
        child: MonitorConnect(
                  flutterReactiveBle: flutterReactiveBle,
                  callback: (deviceList)=> setState(() {
                    connectedDevices = deviceList;
                  }),
                  connectedDevices: connectedDevices,
                  offset: const Offset(0, 0),
                  link: layerLink,
                  dialogWidth: dialogWidth,
                  dialogHeight: dialogHeight
              ),
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

  Route _createRoute(FlutterReactiveBle ble,
      List<BleSensorDevice>? connectedDevices, String type) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => WorkoutPage(
          flutterReactiveBle: ble,
          deviceList: connectedDevices,
          title: "Active Run"),
    );
  }

  void dismissMenu() {
    overlayEntry.remove();
  }

  List<BleSensorDevice> connectedDevices = <BleSensorDevice>[];
  // Obtain FlutterReactiveBle instance for entire app.
  final flutterReactiveBle = FlutterReactiveBle();


}