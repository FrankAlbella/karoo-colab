import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
import 'package:wakelock/wakelock.dart';
import '../ble_sensor_device.dart';
import '../bluetooth_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logging/exercise_logger.dart';
import '../rider_data.dart';

class SoloWorkout extends StatefulWidget {
  final String title;
  final FlutterReactiveBle flutterReactiveBle;
  final List<BleSensorDevice>? deviceList;

  const SoloWorkout({
    super.key,
    required this.flutterReactiveBle,
    required this.deviceList,
    required this.title,
  });

  @override
  State<SoloWorkout> createState() => _SoloWorkout();
}

class _SoloWorkout extends State<SoloWorkout> {
  static int myHR = 0;
  int myPower = 0;
  int myCadence = 0;
  double mySpeed = 0;
  String _name = "";
  String _HR = "";
  String _FTP = "";
  Duration duration = Duration();
  Timer? timer;
  double distance = 0;
  bool pauseWorkout = false;
  bool stopWorkout = false;
  bool distanceSwitch = false;
  Position? currentPosition;
  Position? initialPosition;
  late StreamSubscription<Position> positionStreamSubscription;

  final RiderData data = RiderData();

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = (prefs.getString('name') ?? "Name").substring(0, 4);
      print("Is this okay: {$_name}");
    });
    setState(() {
      _HR = (prefs.getString('maxHR') ?? "Max HR");
      print('$_HR');
    });
    setState(() {
      _FTP = (prefs.getString('FTP') ?? "FTP");
      print('$_FTP');
    });
  }

  late StreamSubscription peerSubscription;
  StreamSubscription<List<int>>? subscribeStreamHR;

  int _readPower(List<int> data) {
    int total = data[3];
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

  void addTime() {
    setState(() {
      final seconds = duration.inSeconds + 1;
      duration = Duration(seconds: seconds);
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void startSensorListening() {
    if (widget.deviceList != null) {
      for (BleSensorDevice device in widget.deviceList!) {
        if (device.type == 'HR') {
          debugPrint("Device sub: ${device.deviceId}");
          subscribeStreamHR = widget.flutterReactiveBle
              .subscribeToCharacteristic(QualifiedCharacteristic(
                  characteristicId: device.characteristicId,
                  serviceId: device.serviceId,
                  deviceId: device.deviceId))
              .listen((event) {
            setState(() {
              myHR = event[1];
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
              myPower = _readPower(event);
              myCadence = _readCadence(event).toInt();
            });
          });
        }
      }
    }
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

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _loadSettings();
    startTimer();
    getCurrentLocation();
    positionStreamSubscription = Geolocator.getPositionStream(
            locationSettings: LocationSettings(
                accuracy: LocationAccuracy.high, distanceFilter: 15))
        .listen(onPositionUpdate);

    startSensorListening();
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String? hours, minutes, seconds;
    hours = twoDigits(duration.inHours.remainder(60));
    minutes = twoDigits(duration.inMinutes.remainder(60));
    seconds = twoDigits(duration.inSeconds.remainder(60));
    return Scaffold(
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
                    height: 80,
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
                  height: 80,
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
                                "${(distance / 1000.00).floor()}km",
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
                SizedBox(
                    height: 80,
                    width: MediaQuery.of(context).size.width / 3,
                    child: Column(
                      children: const [
                        Text(
                          "Speed:",
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "", //TODO Add speed
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
              ],
            ),
            Row(
              children: [
                SizedBox.square(
                    dimension: 120,
                    child: Column(
                      children: [
                        const Text(
                          "HR:",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
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
                SizedBox.square(
                    dimension: 120,
                    child: Column(
                      children: [
                        const Text(
                          "Power:",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
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
          ])),
    );
  }
}
