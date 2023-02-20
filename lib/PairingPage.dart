import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:karoo_collab/rounded_button.dart';
import 'BluetoothManager.dart';

class PairingPage extends StatefulWidget {
  const PairingPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<PairingPage> createState() => _PairingPage();
}

class _PairingPage extends State<PairingPage> {
  //random object for sending random numbers to connections
  Random random = Random();

  List<Widget> devices = [];
  bool scanning = false;

  Stream<BluetoothDiscoveryResult>? discoveryStream;
  StreamSubscription<BluetoothDiscoveryResult>? discoveryStreamSubscription;

  //make the device discoverable and also
  //listen for bluetooth serial connections
  void startBluetoothServer() async {
    int? res = await BluetoothManager.instance.requestDiscoverable(120);

    if (res == null) {
      print("was not able to make device discoverable");
      return;
    }

    await BluetoothManager.instance.listenForConnections("peer-cycle", 120);
  }

  //starts scanning for other nearby bluetooth devices
  void startScan() async {
    if (scanning) {
      return;
    }

    discoveryStream = await BluetoothManager.instance.startDeviceDiscovery();

    final subscription = discoveryStream?.listen((event) {
      setState(() {
        final textWidget = RoundedButton(
            text: event.device.name ?? "no name",
            height: 40,
            width: 40,
            onPressed: () =>
                {BluetoothManager.instance.connectToDevice(event.device)});
        devices = [...devices, textWidget];
      });
    });

    //set state to now scanning
    setState(() {
      scanning = true;
    });
  }

  //sends a randomly generated number to all currently connected devices
  void sayHi() async {
    final int randomNum = random.nextInt(100);
    String dataStr = "randomNum:$randomNum";
    print("Broadcasting data: $dataStr");
    BluetoothManager.instance.broadcastString(dataStr);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.black,
      body: Center(
                child: Container(
                    color: Colors.black,
                    height: 92,
                    width: 92,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          color: Colors.black,
                          height: 92,
                          width: 92,
                          child: ListView(
                            children: devices,
                          ),
                        ),
                        RoundedButton(
                          text: "Start Server",
                          height: 40,
                          width: 92 + 10,
                          onPressed: startBluetoothServer,
                        ),
                        RoundedButton(
                          text: "Scan for other Devices",
                          height: 40,
                          width: 92 + 10,
                          onPressed: startScan,
                        ),
                        RoundedButton(
                          text: "Say Hi",
                          height: 40,
                          width: 92 + 10,
                          onPressed: sayHi,
                        ),
                      ],
                    )
                )
      )
  );
}
