import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:karoo_collab/rounded_button.dart';
import 'BluetoothDeviceListEntry.dart';
import 'BluetoothManager.dart';

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

  @override
  void initState() {
    super.initState();

    startBluetoothServer();
    //startScan();
  }

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
    if(scanning) {
      return;
    }

    discoveryStream = await BluetoothManager.instance.startDeviceDiscovery();

    final subscription = discoveryStream?.listen((event) {
      setState(() {
        String deviceName = event.device.name ?? "没有名字";

        final textWidget = TextButton.icon(
          onPressed: () => {
            BluetoothManager.instance.connectToDevice(event.device)
          },
          icon: const Icon(
            Icons.people,
          ),
          label: Align(
              alignment: Alignment.centerLeft,
              child: ListTile(
                  title: Text(deviceName),
                  trailing: const Icon(Icons.keyboard_arrow_right))),
        );

        if(deviceName.contains("Karoo")) {
          devices = [...devices, textWidget];
        }
      });
    });

    //set state to now scanning
    setState(() {scanning = true;});
  }

  //sends a randomly generated number to all currently connected devices
  void sayHi() async {
    final int randomNum = random.nextInt(100);
    String dataStr = "randomNum:$randomNum";
    print("Broadcasting data: $dataStr");
    BluetoothManager.instance.broadcastString(dataStr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: ListView(
          children: <Widget>[
            TextButton.icon(
              onPressed: startScan,
              icon: const Icon(
                Icons.bluetooth,
              ),
              label: const Align(
                  alignment: Alignment.centerLeft,
                  child: ListTile(
                      title: Text("Start Scan"),
                      trailing: Icon(Icons.smoke_free))),
            ),
            ...devices
          ]
      ),
    );
  }
}
