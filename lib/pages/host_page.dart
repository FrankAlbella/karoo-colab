import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' hide Logger;
import 'package:karoo_collab/BluetoothProvider.dart';
import 'package:logging/logging.dart';
import 'workout_page.dart';
import '../BluetoothDeviceListEntry.dart';
import '../BluetoothManager.dart';
import '../RiderData.dart';
import '../ble_sensor_device.dart';

class HostPage extends StatefulWidget {
  const HostPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HostPage> createState() => _HostPage();
}

class _HostPage extends State<HostPage> {
  //random object for sending random numbers to connections
  Random random = Random();

  // Obtain FlutterReactiveBle instance for entire app.
  final flutterReactiveBle = FlutterReactiveBle();

  List<Widget> devices = [];
  bool scanning = false;

  Stream<BluetoothDiscoveryResult>? discoveryStream;
  StreamSubscription<BluetoothDiscoveryResult>? discoveryStreamSubscription;

  static const platform = MethodChannel('edu.uf.karoo_collab');

  double myHR = 0;
  double myPower = 0;
  double mySpeed = 0;

  @override
  void initState() {
    super.initState();
    startBluetoothServer();
    BluetoothManager.instance.deviceDataStream.listen((dataMap) {
      Logger.root.info('got data from a connection: $dataMap');
    });
    startBluetoothListening();
  }

  void startBluetoothListening() {
    double partnerHR = 0;
    double partnerPower = 0;
    double partnerSpeed = 0;

    BluetoothManager.instance.deviceDataStream.listen((event) {
      Logger.root.info('got data from a connection: $event');
      final map = event.values.first;

      for(final key in map.keys) {
        switch(key) {
          case "heartRate":
            partnerHR = double.parse(map[key] ?? "-1");
            try {
              platform.invokeListMethod('setPartnerHR', {"hr": partnerHR});
              //Logger.root.info('Partner HR set to $partnerHR');
            } on PlatformException catch (e) {
              Logger.root.severe('Failed to set partner HR: $e');
            }
            break;
          case "power":
            partnerPower = double.parse(map[key] ?? "-1");
            try {
              platform.invokeListMethod('setPartnerPower', {"power": partnerPower});
              //Logger.root.info('Partner power set to $partnerPower');
            } on PlatformException catch (e) {
              Logger.root.severe('Failed to set partner power: $e');
            }
            break;
          case "speed":
            partnerSpeed = double.parse(map[key] ?? "-1");
            try {
              platform.invokeListMethod('setPartnerSpeed', {"speed": partnerSpeed});
              //Logger.root.info('Partner power set to $partnerSpeed');
            } on PlatformException catch (e) {
              Logger.root.severe('Failed to set partner speed: $e');
            }
            break;
          default:
            Logger.root.warning('Unknown map key received: $key');
        }
      }
    });

    final streamController = StreamController<RiderData>();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateMyHR();
      _updateMyPower();

      final RiderData data = RiderData();
      data.heartRate = myHR;
      data.power = myPower;

      streamController.add(data);

    });

    streamController.stream.listen((event) {
      BluetoothManager.instance.broadcastString("heartRate:${event.heartRate}");
      BluetoothManager.instance.broadcastString("power:${event.power}");
      //BluetoothManager.instance.broadcastString("speed:${event.speed}");
    });
  }

  Future<void> _updateMyHR() async{
    try {
      myHR = await platform.invokeMethod('getMyHR');
    } on PlatformException catch (e) {
      Logger.root.severe('Failed to get partner data from Stream: $e');
    }
  }

  Future<void> _updateMyPower() async{
    try {
      myPower = await platform.invokeMethod('getMyPower');
    } on PlatformException catch (e) {
      Logger.root.severe('Failed to get partner data from Stream: $e');
    }
  }

  //make the device discoverable and also
  //listen for bluetooth serial connections
  void startBluetoothServer() async {
    int? res = await BluetoothManager.instance.requestDiscoverable(120);

    if (res == null) {
      Logger.root.severe("Failed to make device discoverable");
      return;
    }

    Logger.root.info(await BluetoothManager.instance.listenForConnections("peer-cycle", 120000));
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

  List<BleSensorDevice> connectedDevices = <BleSensorDevice>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            TextButton.icon(
              onPressed: startBluetoothServer,
              icon: const Icon(
                Icons.bluetooth,
              ),
              label: const Align(
                  alignment: Alignment.centerLeft,
                  child: ListTile(
                      title: Text("Start Server"),
                      trailing: Icon(Icons.sensors))),
            ),

            ...devices
          ]
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
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(_createRoute(
                flutterReactiveBle, connectedDevices, ""));
          },
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(50, 50),
            shape: const CircleBorder(),
            backgroundColor: Colors.yellow,
          ),
          child: const Icon(Icons.play_arrow),
        )
      ],
      persistentFooterAlignment: AlignmentDirectional.bottomStart,
    );
  }
}
