import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' hide Logger;
import 'package:geolocator/geolocator.dart';
import 'package:wakelock/wakelock.dart';
import '../ble_sensor_device.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:logging/logging.dart';
import '../rider_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logging/exercise_logger.dart';
import '../bluetooth_manager.dart';

class WorkoutPage extends StatefulWidget {
  final FlutterReactiveBle flutterReactiveBle;
  final List<BleSensorDevice>? deviceList;
  final String title;

  const WorkoutPage({
    super.key,
    required this.flutterReactiveBle,
    required this.deviceList,
    required this.title,
  });

  @override
  State<WorkoutPage> createState() => _WorkoutPage();
}

class _WorkoutPage extends State<WorkoutPage> {
  Stream<BluetoothDiscoveryResult>? discoveryStream;
  StreamSubscription<BluetoothDiscoveryResult>? discoveryStreamSubscription;

  static int myHR = 0;
  int myPower = 0;
  int myCadence = 0;
  int mySpeed = 0;

  int partnerHR = 0;
  int partnerPower = 0;
  int partnerCadence = 0;
  int partnerSpeed = 0;
  String _name = "";
  int _targetHR = 120;
  int _maxFTP = 150;
  final RiderData data = RiderData();
  Duration duration = Duration();
  Timer? timer;
  double distance = 0;
  bool pauseWorkout = false;
  bool stopWorkout = false;
  bool distanceSwitch = false;
  Position? currentPosition;
  Position? initialPosition;
  late StreamSubscription<Position> positionStreamSubscription;

  late StreamSubscription peerSubscription;
  StreamSubscription<List<int>>? subscribeStreamHR;

  int _readPower(List<int> data) {
    int total = data[3];
    /*
    data = [_, 0x??, 0x??, ...]
    want to read index 2 and 3 as one integer
    shift integer at index 3 left by 8 bits
    and add the 8 bits from index 2
    since the data is being stored in little-endian
    format
     */
    total = total << 8;
    return total + data[2];
  }

  //TODO: need to fix this
  double _readCadence(List<int> data) {
    int time = data[11] << 8;
    time += data[10];
    double timeDouble = time.toDouble();
    timeDouble *= 1 / 2048;
    return (1 / timeDouble) * 60.0;
  }

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _loadSettings();
    startTimer();
    getCurrentLocation();
    positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 15))
        .listen(onPositionUpdate);

    startBluetoothListening();
    BluetoothManager.instance.deviceDataStream.listen((dataMap) {
      Logger.root.info('got data from a connection: $dataMap');
    });

    startPartnerListening();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {

        _name = (prefs.getString('name') ?? "Name");
      print("Is this okay: {$_name}");
    });
    setState(() {
      _targetHR = (prefs.getInt('maxHR') ?? _targetHR);
      print('$_targetHR');
    });
    setState(() {
      _maxFTP = (prefs.getInt('FTP') ?? _maxFTP);
      print('$_maxFTP');
    });
  }

  void startBluetoothListening() {
    if (widget.deviceList != null) {
      debugPrint("MAYBE GOTTEM?");
      for (BleSensorDevice device in widget.deviceList!) {
        debugPrint("we Gottem");
        if (device.type == 'HR') {
          debugPrint("Device sub: ${device.deviceId}");
          subscribeStreamHR = widget.flutterReactiveBle
              .subscribeToCharacteristic(QualifiedCharacteristic(
                  characteristicId: device.characteristicId,
                  serviceId: device.serviceId,
                  deviceId: device.deviceId))
              .listen((event) {
            setState(() {
              // Update UI.
              myHR = event[1];
              // Broadcast heart rate to partner.
              BluetoothManager.instance.broadcastString('heartRate:$myHR');
              debugPrint("Broadcast string: heartRate:$myHR");
              // Log heart rate.
              ExerciseLogger.instance?.logHeartRateData(myHR);
            });
          });
        } else if (device.type == 'POWER') {
          debugPrint("Device sub: ${device.deviceId}");
          subscribeStreamHR = widget.flutterReactiveBle
              .subscribeToCharacteristic(QualifiedCharacteristic(
                  characteristicId: device.characteristicId,
                  serviceId: device.serviceId,
                  deviceId: device.deviceId))
              .listen((event) {
            setState(() {
              // Update UI.
              myPower = _readPower(event);
              //myCadence = _readCadence(event).toInt();
              // Broadcast power and cadence to partner.
              BluetoothManager.instance.broadcastString('power:$myPower');
              debugPrint("Broadcast string: power:$myPower");
              //BluetoothManager.instance.broadcastString('cadence:$myCadence');
              //debugPrint("Broadcast string: cadence:$myCadence");
              // Log heart rate.
              ExerciseLogger.instance?.logPowerData(myPower);
            });
          });
        }
      }
    }
  }

  void startPartnerListening() {
    BluetoothManager.instance.deviceDataStream.listen((event) {
      Logger.root.info('got data from a connection: $event');
      final map = event.values.first;
      setState(() {
        for (final key in map.keys) {
          switch (key) {
            case "heartRate":
              partnerHR = int.parse(map[key] ?? "-1");
              Logger.root.info('Set partner HR: $partnerHR');
              break;
            case "power":
              partnerPower = int.parse(map[key] ?? "-1");
              Logger.root.info('Set partner power: $partnerPower');
              break;
            case "cadence":
              partnerCadence = int.parse(map[key] ?? "-1");
              Logger.root.info('Set partner cadence: $partnerCadence');
              break;
            case "speed":
              partnerSpeed = int.parse(map[key] ?? "-1");
              Logger.root.info('Set partner speed: $partnerSpeed');
              break;
            default:
              Logger.root.warning('Unknown map key received: $key');
          }
        }
      });
    });
  }

  void getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      initialPosition = position;
      currentPosition = position;
    });
    listenToLocationChanges();
  }

  void listenToLocationChanges() {
    Geolocator.getPositionStream().listen((position) {
      if (mounted) {
        setState(() {
          currentPosition = position;
          distance = Geolocator.distanceBetween(
            initialPosition!.latitude,
            initialPosition!.longitude,
            currentPosition!.latitude,
            currentPosition!.longitude,
          );
          initialPosition = position;
        });
      }
    });
  }

  void onPositionUpdate(Position newPosition) {
    setState(() {
      currentPosition = newPosition;
      if (initialPosition != null) {
        final distanceInMeters = Geolocator.distanceBetween(
            initialPosition!.latitude,
            initialPosition!.longitude,
            currentPosition!.latitude,
            currentPosition!.longitude);
        initialPosition = newPosition;
        distance += distanceInMeters;

        debugPrint("Initial LONG: ${initialPosition!.longitude}");
        debugPrint("Initial LAT: ${initialPosition!.latitude}");
        debugPrint("Curr LONG: ${currentPosition!.longitude}");
        debugPrint("Curr LONG: ${currentPosition!.latitude}");

        debugPrint('Distance so far is: $distance');
      }
    });
  }

  void getLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission was denied again, handle the error
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission was permanently denied, take the user to app settings
      return;
    }

    // Permission has been granted, you can now access the device's location
    final position = await Geolocator.getCurrentPosition();
    print(position);
  }

  void addTime() {
    setState(() {
      final seconds = duration.inSeconds + 1;
      duration = Duration(seconds: seconds);
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  @override
  void dispose() {
    peerSubscription =
        BluetoothManager.instance.deviceDataStream.listen((event) {});
    if (subscribeStreamHR != null) {
      subscribeStreamHR?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String? hours, minutes, seconds;
    hours = twoDigits(duration.inHours.remainder(60));
    minutes = twoDigits(duration.inMinutes.remainder(60));
    seconds = twoDigits(duration.inSeconds.remainder(60));
    return Scaffold(
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      //   backgroundColor: Colors.black,
      //   automaticallyImplyLeading: false,
      // ),
      backgroundColor: Colors.black26,
      floatingActionButton:
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        FloatingActionButton(
          heroTag: "playpause",
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          onPressed: () {
            setState(() {
              pauseWorkout = !pauseWorkout;
              if (pauseWorkout) //PLAY/PAUSE WORKOUT!
              {
                timer?.cancel();
                positionStreamSubscription.pause();
              } else {
                startTimer();
                positionStreamSubscription.resume();
              }
            });
          },
          child: Icon(pauseWorkout ? Icons.play_arrow : Icons.pause),
        ),
        Visibility(
          visible: pauseWorkout == true,
          child: FloatingActionButton(
            heroTag: "endride",
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: const Icon(Icons.delete),
            onPressed: () {
              //END WORKOUT!
              stopWorkout = true;
              ExerciseLogger.instance?.endWorkoutAndSaveLog();
              Navigator.pop(context);
            },
          ),
        )
      ]),
      body: SafeArea(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        height: 30,
                        width: MediaQuery.of(context).size.width / 3,
                        child: Column(
                          children: [
                            const Text(
                              "Duration:",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '$minutes:$seconds',
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        )),
                    SizedBox(
                      height: 30,
                      width: MediaQuery.of(context).size.width / 3,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            distanceSwitch = !distanceSwitch;
                            distanceSwitch
                                ? debugPrint("Switching to km")
                                : debugPrint("Switching to mi");
                          });
                        },
                        style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                        child: Column(
                          children: distanceSwitch
                              ? [
                            const Text(
                              "Distance:",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "${(distance / 1000).floor()}km",
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ]
                              : [
                            const Text(
                              "Distance:",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "${(distance / 1609.34).floor()}mi",
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // SizedBox(
                    //     height: 80,
                    //     width: MediaQuery.of(context).size.width / 3,
                    //     child: Column(
                    //       children: const [
                    //         Text(
                    //           "Speed:",
                    //           style: TextStyle(
                    //               fontSize: 10,
                    //               color: Colors.white,
                    //               fontWeight: FontWeight.w600),
                    //         ),
                    //         Text(
                    //           "",
                    //           style: TextStyle(
                    //               fontSize: 15,
                    //               color: Colors.white,
                    //               fontWeight: FontWeight.w600),
                    //         ),
                    //       ],
                    //     )),
                  ],
                ),
                Row(children: [
                  SizedBox(
                    width: 120,
                    height: 20,
                    child:
                      Text(
                          "$_name",
                          style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ), 
                  )
                ],),
            Row(
              children: [
                SizedBox(
                    width: 120,
                    height: 100,
                    child: Column(
                      children: [
                        Icon(                         
                          Icons.favorite,
                          color: Colors.white,
                        ),

                        Text(
                          "$myHR",
                          style: const TextStyle(
                              fontSize: 50,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
                SizedBox(
                    width: 120,
                    height: 100,
                    child: Column(
                      children: [
                        Icon(                         
                          Icons.flash_on,
                          color: Colors.white,
                        ),

                        Text(
                          "$myPower",
                          style: const TextStyle(
                              fontSize: 50,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
              ],
            ),
            Row(children: [
                  Align(
                  alignment: Alignment.center,
                   child: Text(
                          "Partner name",
                          style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ), 

                  )
                ],),
            Row(
              children: [
                SizedBox(
                    width: 120,
                    height: 100,
                    child: Column(
                      children: [
                        Icon(                         
                          Icons.favorite,
                          color: Colors.white,
                        ),

                        Text(
                          "$partnerHR",
                          style: const TextStyle(
                              fontSize: 50,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
                SizedBox(
                    width: 120,
                    height: 100,
                    child: Column(
                      children: [
                        Icon(                         
                          Icons.flash_on,
                          color: Colors.white,
                        ),

                        Text(
                          "$partnerPower",
                          style: const TextStyle(
                              fontSize: 50,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
              ],
            ),
          ])),
    );
  }
}
