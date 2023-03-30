import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

class ExerciseLogger {
  // Used for the logger to be accessed in multiple locations
  static ExerciseLogger instance = ExerciseLogger();

  final Map<String, dynamic> _map = {};
  late Workout workout = Workout();

  ExerciseLogger() {
    _updateDeviceInfo();
    _map[LoggerConstants.fieldEvents] = [];
  }

  Future<void> _updateDeviceInfo()  async {
    var deviceInfo = (await DeviceInfoPlugin().androidInfo);
    _map[LoggerConstants.fieldName] = deviceInfo.device;
    _map[LoggerConstants.fieldDeviceId] = deviceInfo.id;
    _map[LoggerConstants.fieldSerialNum] = deviceInfo.serialNumber;
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
      default:
        throw Exception("logEvent: $event is not a valid event type");
    }

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
    workout.start(workoutType);
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
    workout.addPartner(partnerName, partnerDeviceId, partnerSerialNum);
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

  void logHeartRateData(int heartRate) {
    workout.addHeartRateData(heartRate);
  }

  void logPowerData(int power) {
    workout.addPowerData(power);
  }

  void logDistanceData(int distance) {
    workout.addDistanceData(distance);
  }

  static int secondsSinceEpoch() {
    int ms = DateTime.now().millisecondsSinceEpoch;
    return (ms/1000).round();
  }

  Future<void> saveToFile() async {
    final directory = (await getApplicationDocumentsDirectory()).path;

    File file = File("$directory/workout-$secondsSinceEpoch()");

    var asJson = jsonEncode(_map);

    file.writeAsString(asJson);
  }

  void insertInDatabase() async {
    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(LoggerConstants.databaseUrlPost));
    request.headers.set("apiKey", LoggerConstants.databaseApiKey);
    request.headers.contentType = ContentType("application", "json");

    _map[LoggerConstants.fieldWorkout] = workout.toMap();

    Map<String, dynamic> body = {
      "dataSource": "FitnessLog",
      "database": "FitnessLog",
      "collection": "Test",
      "document": _map
    };

    request.write(jsonEncode(body));

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();

    httpClient.close();

    if(response.statusCode == 200) {
      Logger.root.info("Database insertion successful: $reply");
    } else {
      Logger.root.warning("Database insertion unsuccessful: $reply");
    }
  }
}

enum WorkoutType {
  running,
  walking,
  cycling,
  biking
}

extension WorkoutTypeExtension on WorkoutType {
  String toShortString() {
    return toString().split('.').last;
  }
}

class Workout {
  late WorkoutType _workoutType;
  final Map<int, Map<String, String>> _partners = {};
  late int _startTime;

  late String _heartRateUnits;
  late int _heartRateMax;
  final List<Map<String, int>> _heartRateData = [];

  late String _powerUnits;
  final List<Map<String, int>> _powerData = [];

  late String _distanceUnits;
  final List<Map<String, int>> _distanceData = [];

  Workout({WorkoutType workoutType = WorkoutType.cycling, int maxHeartRate = 120}) {
    start(workoutType);
    _heartRateUnits = LoggerConstants.valueBPM;
    _powerUnits = LoggerConstants.valueWatts;
    _distanceUnits = LoggerConstants.valueMeters;
    _heartRateMax = maxHeartRate;
  }

  void start(WorkoutType workoutType) {
    _startTime = ExerciseLogger.secondsSinceEpoch();
    _workoutType = workoutType;
  }

  void setMaxHeartRate(int max) {
    _heartRateMax = max;
  }

  // TODO: make enum of heart rate units
  void setHeartRateUnits(String units) {
    _heartRateUnits = units;
  }

  // TODO: make enum of power units
  void setPowerUnits(String units) {
    _powerUnits = units;
  }
  
  // TODO: make enum of distance units
  void setDistanceUnits(String units) {
    _distanceUnits = units;
  }

  void addPartner(String partnerName, String partnerDeviceId, String partnerSerialNum) {
    Map<String, String> partnerMap = {};

    partnerMap[LoggerConstants.fieldName] = partnerName;
    partnerMap[LoggerConstants.fieldDeviceId] = partnerDeviceId;
    partnerMap[LoggerConstants.fieldSerialNum] = partnerSerialNum;

    int index = _partners.length;
    _partners[index] = partnerMap;
  }

  void addHeartRateData(int heartRate) {
    Map<String, int> heartRateMap = {};

    heartRateMap[LoggerConstants.fieldValue] = heartRate;
    heartRateMap[LoggerConstants.fieldTimestamp] = ExerciseLogger.secondsSinceEpoch();

    _heartRateData.add(heartRateMap);
  }

  void addPowerData(int power) {
    Map<String, int> powerMap = {};

    powerMap[LoggerConstants.fieldValue] = power;
    powerMap[LoggerConstants.fieldTimestamp] = ExerciseLogger.secondsSinceEpoch();

    _heartRateData.add(powerMap);
  }

  void addDistanceData(int distance) {
    Map<String, int> distanceMap = {};

    distanceMap[LoggerConstants.fieldValue] = distance;
    distanceMap[LoggerConstants.fieldTimestamp] = ExerciseLogger.secondsSinceEpoch();

    _distanceData.add(distanceMap);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    Map<String, dynamic> heartRateMap = {};
    Map<String, dynamic> powerMap = {};
    Map<String, dynamic> distanceMap = {};

    map[LoggerConstants.fieldWorkoutType] = _workoutType.toShortString();
    map[LoggerConstants.fieldTimestamp] = _startTime;

    map[LoggerConstants.fieldPartners] = _partners;

    heartRateMap[LoggerConstants.fieldUnits] = _heartRateUnits;
    heartRateMap[LoggerConstants.fieldMaxHeartRate] = _heartRateMax;
    heartRateMap[LoggerConstants.fieldData] = _heartRateData;
    map[LoggerConstants.fieldHeartRate] = heartRateMap;

    powerMap[LoggerConstants.fieldUnits] = _powerUnits;
    powerMap[LoggerConstants.fieldData] = _powerData;
    map[LoggerConstants.fieldPower] = powerMap;

    heartRateMap[LoggerConstants.fieldUnits] = _distanceUnits;
    map[LoggerConstants.fieldDistance] = distanceMap;

    return map;
  }
}

class LoggerConstants {
  // TODO: remove these from the source code into env variables or something
  static const databaseUrlPost = "https://us-east-1.aws.data.mongodb-api.com/app/data-nphof/endpoint/data/v1/action/insertOne";
  static const databaseApiKey = "e1G2HlcHaZPlJ2NOoFtP3ocZilWoQOoPIdZ8pndoFpECJhoNn7e5684PV0NTZSXg";

  static const eventAppLaunched = 0;
  static const eventAppClosed = 1;
  static const eventButtonPressed = 2;
  static const eventPageNavigate = 3;
  static const eventSettingChanged = 4;
  static const eventWorkoutStarted = 5;
  static const eventWorkoutEnded = 6;
  static const eventWorkoutPaused = 7;
  static const eventWorkoutUnpaused = 8;
  static const eventPartnerConnect = 9;
  static const eventPartnerDisconnect = 10;
  static const eventBluetoothInit = 11;
  static const eventBluetoothConnect = 12;
  static const eventBluetoothDisconnect = 13;

  static const fieldName = "name";
  static const fieldDeviceId = "device_id";
  static const fieldSerialNum = "serial_number";
  static const fieldWorkout = "workout";
  static const fieldEvents = "events";
  static const fieldEventType = "event_type";
  static const fieldWorkoutType = "workout_type";
  static const fieldPreviousPage = "previous_page";
  static const fieldCurrentPage = "current_page";
  static const fieldTimestamp = "timestamp";
  static const fieldSettingName = "setting_name";
  static const fieldPreviousValue = "previous_value";
  static const fieldCurrentValue = "current_value";
  static const fieldPartnerDeviceId = "partner_device_id";
  static const fieldPartnerSerialNum = "partner_serial_number";
  static const fieldDeviceName = "device_name";
  static const fieldStartTimestamp = "start_timestamp";
  static const fieldValue = "value";
  static const fieldUnits = "units";
  static const fieldData = "data";
  static const fieldPartners = "partners";
  static const fieldHeartRate = "heart_rate";
  static const fieldMaxHeartRate = "max_heart_rate";
  static const fieldDistance = "distance";
  static const fieldPower = "power";

  static const valueBPM = "beats_per_minute";
  static const valueMeters = "meters";
  static const valueWatts = "watts";
}