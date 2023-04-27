import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'ble_sensor_device.dart';
import 'package:collection/collection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MonitorConnect extends StatefulWidget {
  final FlutterReactiveBle flutterReactiveBle;
  final List<BleSensorDevice> connectedDevices;
  final Function(List<BleSensorDevice>) callback;
  final LayerLink link;
  final Offset offset;
  final double dialogWidth;
  final double dialogHeight;
  const MonitorConnect({Key? key, required this.flutterReactiveBle,
    required this.callback, required this.connectedDevices, required this.link,
    required this.offset, required this.dialogWidth, required this.dialogHeight}) : super(key: key);


  @override
  State<MonitorConnect> createState() => _MonitorConnectState();
}

class _MonitorConnectState extends State<MonitorConnect> {
  final Uuid _heartRateServiceUUID = Uuid.parse('180d');
  final Uuid _heartRateCharacteristicUUID = Uuid.parse('2a37');
  final Uuid _cyclingPowerServiceUUID = Uuid.parse('1818');
  final Uuid _cyclingPowerCharacteristicUUID = Uuid.parse('2a63');

  late final FlutterReactiveBle flutterReactiveBle;
  List<DiscoveredDevice> devices = <DiscoveredDevice>[];
  List<BleSensorDevice> connectingDevices = <BleSensorDevice>[];
  StreamSubscription? scanSubscription;
  late StreamSubscription<ConnectionStateUpdate> _connection;
  //List<BleSensorDevice> connectedDevices = <BleSensorDevice>[];
  Color _colorTile = Colors.white;
  //bool isConnecting = false;

  @override
  void initState() {
    super.initState();

    requestSensorPermissions();
    flutterReactiveBle = widget.flutterReactiveBle;

    flutterReactiveBle.statusStream.listen((status) {
      debugPrint(status.toString());
    if (flutterReactiveBle.status == BleStatus.ready) {
      //scanSubscription?.cancel();
      scanSubscription = flutterReactiveBle.scanForDevices(
          withServices: [_heartRateServiceUUID, _cyclingPowerServiceUUID]).listen((device) {
        final knownDeviceIndex = devices.indexWhere((d) => d.id == device.id);
        if (knownDeviceIndex >= 0) {
          devices[knownDeviceIndex] = device;
        } else {
          setState(() {
            devices.add(device);
          });
          debugPrint('Device found.');
        }
      }, onError: (Object e) {
        debugPrint('Error scanning for heart rate sensor: $e');
      });
    }
    else {
      debugPrint('Error: BLE status not ready');
    }
    for (BleSensorDevice d in widget.connectedDevices) {
      debugPrint("Device id: ${d.deviceId}");
    }
    });
  }

  bool isConnected(String id) {
    bool result = widget.connectedDevices.firstWhereOrNull((element) => element.deviceId==id) != null;
    if (result) {
      debugPrint("True somehow");
    }
    else {
      debugPrint("False");
    }
    return result;
  }
    bool isConnecting(String id) {
    bool result = connectingDevices.firstWhereOrNull((element) => element.deviceId==id) != null;
    if (result) {
      debugPrint("Connecting now");
    }
    else {
      debugPrint("Not connecting now");
    }
    return result;
  }
  Icon deviceIcon(String id) {
    if(id.contains(_heartRateServiceUUID.toString()) == true)
    {
      return Icon(Icons.heart_broken, color: Colors.black,);
    }
    else if(id.contains(_cyclingPowerServiceUUID.toString()) == true)
    {
      return Icon(Icons.flash_on, color: Colors.black,);
    }
    return Icon(Icons.bluetooth, color: Colors.black,);
  }

  // TODO: ListView is scrolling into the Positioned elements.
  @override
  Widget build(BuildContext context) {
    return CompositedTransformFollower(
      offset: widget.offset,
      link: widget.link,
      child: Scaffold(
        body: Column(
                  children: [
                    SizedBox(height: widget.dialogWidth * .12,),  // Margin for ListView
                    Flexible(
                      child: ListView(
                        children: [
                          ...devices
                              .map(
                                (device) => ListTile(
                              title: Text(device.name,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 1.7,
                                      color: Colors.black
                                  )),
                              subtitle: Text("${device.id}\nRSSI: ${device.rssi}",
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 1.7,
                                      color: Colors.black
                                  )),
                              leading: deviceIcon(device.serviceUuids.toString()),
                              tileColor: !isConnected(device.id) ?
                              Colors.white10 : Color.fromARGB(255, 14, 112, 158),                            // minVerticalPadding: widget.dialogWidth * .03,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                              trailing: !isConnecting(device.id) ? !isConnected(device.id)? null: Icon(Icons.link) : Container(width: 20, height: 20, child: Image(image: AssetImage('images/loading-buffering.gif'))),
                              onTap: () async {
                                debugPrint("tappin");
                                if(connectingDevices.isEmpty)
                                {
                                  final snackBar = SnackBar(
                                      content: const Text('Please do not exit screen while device is connecting'),
                                      duration: Duration(days: 365),
                                      action: SnackBarAction(
                                        label: 'Ok',
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                        },
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                }
                                else{
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                }
                                //connect
                                BleSensorDevice connectedSensor;
                                if (!isConnected(device.id)) {
                                  _connection = flutterReactiveBle.connectToDevice(
                                    id: device.id,
                                    servicesWithCharacteristicsToDiscover: {
                                      _heartRateServiceUUID: [_heartRateCharacteristicUUID],
                                      _cyclingPowerServiceUUID: [_cyclingPowerCharacteristicUUID],
                                    },
                                  ).listen((update) {
                                    debugPrint('Connection state update: ${update
                                        .connectionState}');
                                    if(update.connectionState == (DeviceConnectionState.connecting))
                                    {
                                      setState(() {
                                      if ((device.serviceUuids.toString().contains(_heartRateServiceUUID.toString())) == true) {
                                    connectedSensor = BleSensorDevice(
                                      type: 'HR',
                                      flutterReactiveBle: flutterReactiveBle,
                                      deviceId: device.id,
                                      serviceId: _heartRateServiceUUID,
                                      characteristicId: _heartRateCharacteristicUUID,
                                    );
                                  }
                                  else {
                                    connectedSensor = BleSensorDevice(
                                      type: 'POWER',
                                      flutterReactiveBle: flutterReactiveBle,
                                      deviceId: device.id,
                                      serviceId: _cyclingPowerServiceUUID,
                                      characteristicId: _cyclingPowerCharacteristicUUID,
                                    );
                                  }
                                  connectingDevices.add(connectedSensor);
                                  
                                    });
                                    }
                                    else if(update.connectionState == (DeviceConnectionState.connected))
                                    {
                                    setState(() {
                                          connectingDevices.removeWhere((element) => element.deviceId == device.id);
                                        });
                                      Fluttertoast.showToast(
                                      msg: "Sensors Connected!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                      ScaffoldMessenger.of(context).clearSnackBars();
                                      final snackBar = SnackBar(
                                      content: const Text('Connected to a sensor, keep connecting or go back to home screen to start a workout'),
                                      duration: Duration(days: 365),
                                      action: SnackBarAction(
                                        label: 'Ok',
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                        },
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }
                                  });
                                  // debugPrint("is uid hr? ${device.serviceUuids.toString().contains(_heartRateServiceUUID.toString())}");
                                  // debugPrint("uid? ${device.serviceUuids}");
                                  // debugPrint("hr? $_heartRateServiceUUID");
                                  if ((device.serviceUuids.toString().contains(_heartRateServiceUUID.toString())) == true) {
                                    debugPrint("Oh my god please");
                                    connectedSensor = BleSensorDevice(
                                      type: 'HR',
                                      flutterReactiveBle: flutterReactiveBle,
                                      deviceId: device.id,
                                      serviceId: _heartRateServiceUUID,
                                      characteristicId: _heartRateCharacteristicUUID,
                                    );
                                  }
                                  else {
                                    connectedSensor = BleSensorDevice(
                                      type: 'POWER',
                                      flutterReactiveBle: flutterReactiveBle,
                                      deviceId: device.id,
                                      serviceId: _cyclingPowerServiceUUID,
                                      characteristicId: _cyclingPowerCharacteristicUUID,
                                    );
                                  }
                                  widget.connectedDevices.add(connectedSensor);
                                }
                                else {
                                  print("remove device");
                                  setState(() {
                                    connectingDevices.removeWhere((element) => element.deviceId == device.id);
                                  });
                                  _connection.cancel();
                                  widget.connectedDevices.removeWhere((element) => element.deviceId == device.id);
                                }
                                setState(() {
                                  _colorTile = _colorTile == Colors.black ? Colors.blue : Colors.black;
                                });
                                widget.callback(widget.connectedDevices);
                              },
                            ),
                          )
                              .toList(),
                        ],
                      ),
                    ),
                  ],
                ),
      )
    );
  }

  @override
  void dispose() {
    //widget.callback()
    scanSubscription?.cancel();
    ScaffoldMessenger.of(context).clearSnackBars();
    super.dispose();
  }

  Future<void> requestSensorPermissions() async {
    if (!await Permission.contacts.request().isGranted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.sensors,
        Permission.location
      ].request();
    }
  }
}