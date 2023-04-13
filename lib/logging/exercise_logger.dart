import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:karoo_collab/logging/upload_manager.dart';
import 'package:karoo_collab/logging/workout.dart';
import 'package:path_provider/path_provider.dart';

import 'logger_constants.dart';

class ExerciseLogger {
  static ExerciseLogger? _instance;
  static ExerciseLogger? get instance => _instance;

  final Map<String, dynamic> _map = {};
  late final Workout _workout = Workout();

  late DeviceType _deviceType;

  Future<void> _updateDeviceInfo()  async {
    var deviceInfo = (await DeviceInfoPlugin().androidInfo);
    _map[LoggerConstants.fieldName] = deviceInfo.device;
    _map[LoggerConstants.fieldDeviceId] = deviceInfo.id;
    _map[LoggerConstants.fieldSerialNum] = deviceInfo.serialNumber;
  }

  static Future<void> create(DeviceType deviceType) async {
    var logger = ExerciseLogger();

    await logger._updateDeviceInfo();
    logger._map[LoggerConstants.fieldGroupId] = deviceType.index;
    logger._map[LoggerConstants.fieldEvents] = [];

    logger._deviceType = deviceType;

    _instance = logger;
  }

  void _logEvent(int event, [List? info]) {
    Map<String, dynamic> eventMap = {};

    eventMap[LoggerConstants.fieldEventType] = event;
    eventMap[LoggerConstants.fieldTimestamp] = secondsSinceEpoch();

    switch(event) {
      case LoggerConstants.eventAppLaunched:
        if(info == null) {
          throw Exception("logEvent: info cannot be null on app launched event");
        }

        eventMap[LoggerConstants.fieldCurrentPage] = info[0];
        break;
      case LoggerConstants.eventAppClosed:
        if(info != null) {
          eventMap[LoggerConstants.fieldCurrentPage] = info[0];
        }
        break;
      case LoggerConstants.eventButtonPressed:
        if(info == null) {
          throw Exception("logEvent: info cannot be null on button pressed event");
        }

        eventMap[LoggerConstants.fieldName] = info[0];
        break;
      case LoggerConstants.eventPageNavigate:
        if(info == null) {
          throw Exception("logEvent: info cannot be null on page navigate event");
        }

        eventMap[LoggerConstants.fieldPreviousPage] = info[0];
        eventMap[LoggerConstants.fieldCurrentPage] = info[1];
        break;
      case LoggerConstants.eventSettingChanged:
        if(info == null) {
          throw Exception("logEvent: info cannot be null on settings changed event");
        }

        eventMap[LoggerConstants.fieldSettingName] = info[0];
        eventMap[LoggerConstants.fieldPreviousValue] = info[1];
        eventMap[LoggerConstants.fieldCurrentValue] = info[2];
        break;
      case LoggerConstants.eventWorkoutStarted:
      case LoggerConstants.eventWorkoutEnded:
        if(info == null) {
          throw Exception("logEvent: info cannot be null on workout started/ended event");
        }
        
        eventMap[LoggerConstants.fieldWorkoutType] = info[0];
        break;
      case LoggerConstants.eventWorkoutPaused:
      case LoggerConstants.eventWorkoutUnpaused:
        break;
      case LoggerConstants.eventPartnerConnect:
      case LoggerConstants.eventPartnerDisconnect:
        if(info == null) {
          throw Exception("logEvent: info cannot be null on partner connection changed event");
        }

        eventMap[LoggerConstants.fieldPartnerDeviceId] = info[0];
        eventMap[LoggerConstants.fieldPartnerSerialNum] = info[1];
        break;
      case LoggerConstants.eventBluetoothInit:
        break;
      case LoggerConstants.eventBluetoothConnect:
      case LoggerConstants.eventBluetoothDisconnect:
        if(info == null) {
          throw Exception("logEvent: info cannot be null on bluetooth connection change event");
        }

        eventMap[LoggerConstants.fieldDeviceName] = info[0];
        break;
      case LoggerConstants.eventScreenOn:
      case LoggerConstants.eventScreenOff:
      case LoggerConstants.eventScreenUnlocked:
        break;
      default:
        throw Exception("logEvent: $event is not a valid event type");
    }

    log("New event log entry: $eventMap");

    _map[LoggerConstants.fieldEvents].add(eventMap);
  }

  void logAppLaunched(String pageName) {
    _logEvent(LoggerConstants.eventAppLaunched, [pageName]);
  }

  void logAppClosed(String pageName) {
    _logEvent(LoggerConstants.eventAppClosed, [pageName]);
  }

  void logButtonPressed(String buttonName) {
    _logEvent(LoggerConstants.eventButtonPressed, [buttonName]);
  }

  void logPageNavigate(String previousPageName, String currentPageName) {
    _logEvent(LoggerConstants.eventPageNavigate, [previousPageName, currentPageName]);
  }

  void logSettingChanged(String settingName, String previousValue, String currentValue) {
    _logEvent(LoggerConstants.eventSettingChanged, [settingName, previousValue, currentValue]);
  }

  void logWorkoutStarted(WorkoutType workoutType) {
    _workout.start(workoutType);
    _logEvent(LoggerConstants.eventWorkoutStarted, [workoutType.toShortString()]);
  }

  void logWorkoutEnded(WorkoutType type) {
    _logEvent(LoggerConstants.eventWorkoutEnded, [type.toShortString()]);
  }

  void logWorkoutPaused() {
    _logEvent(LoggerConstants.eventWorkoutPaused);
  }

  void logWorkoutUnpaused() {
    _logEvent(LoggerConstants.eventWorkoutUnpaused);
  }

  void logPartnerConnected(String partnerName, String partnerDeviceId, String partnerSerialNum) {
    _workout.addPartner(partnerName, partnerDeviceId, partnerSerialNum);
    _logEvent(LoggerConstants.eventPartnerConnect, [partnerName, partnerDeviceId]);
  }

  void logPartnerDisconnected(String partnerName, String partnerId) {
    _logEvent(LoggerConstants.eventPartnerDisconnect, [partnerName, partnerId]);
  }

  void logBluetoothInit() {
    _logEvent(LoggerConstants.eventBluetoothInit);
  }

  void logBluetoothConnect(String deviceConnectedName) {
    _logEvent(LoggerConstants.eventBluetoothConnect, [deviceConnectedName]);
  }

  void logBluetoothDisconnect(String deviceDisconnectedName) {
    _logEvent(LoggerConstants.eventBluetoothDisconnect, [deviceDisconnectedName]);
  }

  void logScreenTurnedOn() {
    _logEvent(LoggerConstants.eventScreenOn);
  }

  void logScreenTurnedOff() {
    _logEvent(LoggerConstants.eventScreenOff);
  }

  void logScreenUnlocked() {
    _logEvent(LoggerConstants.eventScreenUnlocked);
  }

  void logHeartRateData(int heartRate) {
    _workout.addHeartRateData(heartRate);
  }

  void logPowerData(int power) {
    _workout.addPowerData(power);
  }

  void logDistanceData(int distance) {
    _workout.addDistanceData(distance);
  }

  void logCadenceData(int cadence) {
    _workout.addCadenceData(cadence);
  }

  void logCalorieData(int calories) {
    _workout.addCalorieData(calories);
  }

  void logStepData(int steps) {
    _workout.addStepData(steps);
  }

  void logSpeedData(int speed) {
    _workout.addSpeedData(speed);
  }

  void logLocationData(double latitude, double longitude) {
    _workout.addLocationData(latitude, longitude);
  }

  static int secondsSinceEpoch() {
    int ms = DateTime.now().millisecondsSinceEpoch;
    return (ms/1000).round();
  }

  Future<void> endWorkoutAndSaveLog() async {
    final connectionStatus = await (Connectivity().checkConnectivity());
    bool synced = false;

    // try to upload the file when the workout ends
    if(connectionStatus == ConnectivityResult.mobile || connectionStatus == ConnectivityResult.wifi) {
      synced = await UploadManager.instance.uploadWorkout(toJsonString());
    }

    _saveToFile(synced);

    await create(_deviceType);
  }

  Future<void> _saveToFile(bool isSynced) async {
    final appFilesDir = (await getApplicationDocumentsDirectory()).path;
    int time = secondsSinceEpoch();

    File file;

    if(isSynced) {
      await Directory("$appFilesDir/synced").create(recursive: true);
      file = File("$appFilesDir/synced/workout-$time");
    } else {
      await Directory("$appFilesDir/not-synced").create(recursive: true);
      file = File("$appFilesDir/not-synced/workout-$time");
    }

    file.writeAsString(toJsonString());
    log("Log saved to: $file");
  }

  Map<String, dynamic> toMap() {
    _map[LoggerConstants.fieldWorkout] = _workout.toMap();
    return _map;
  }

  String toJsonString() {
    _map[LoggerConstants.fieldWorkout] = _workout.toMap();
    return jsonEncode(_map);
  }
}