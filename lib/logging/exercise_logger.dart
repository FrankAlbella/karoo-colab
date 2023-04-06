import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

class ExerciseLogger {
  final Map<String, dynamic> _map = {};
  late final Workout _workout = Workout();

  Future<void> _updateDeviceInfo()  async {
    var deviceInfo = (await DeviceInfoPlugin().androidInfo);
    _map[LoggerConstants.fieldName] = deviceInfo.device;
    _map[LoggerConstants.fieldDeviceId] = deviceInfo.id;
    _map[LoggerConstants.fieldSerialNum] = deviceInfo.serialNumber;
  }

  static Future<ExerciseLogger> create() async {
    var logger = ExerciseLogger();

    await logger._updateDeviceInfo();
    logger._map[LoggerConstants.fieldEvents] = [];

    return logger;
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

    print("New log entry: $eventMap");

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

  Future<void> saveToFile() async {
    final directory = (await getApplicationDocumentsDirectory()).path;

    int time = secondsSinceEpoch();

    File file = File("$directory/workout-$time");

    var asJson = toJsonString();

    file.writeAsString(asJson);

    print("Log saved to: $file");
  }

  Future<void> insertInDatabase() async {
    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(LoggerConstants.databaseUrlPost));
    request.headers.set("apiKey", LoggerConstants.databaseApiKey);
    request.headers.contentType = ContentType("application", "json");

    Map<String, dynamic> body = {
      "dataSource": "FitnessLog",
      "database": "FitnessLog",
      "collection": "Test",
      "document": toMap()
    };

    request.write(jsonEncode(body));

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();

    httpClient.close();

    if(response.statusCode ~/ 100 == 2) {
      log("Database insertion successful: $reply");
    } else {
      log("Database insertion unsuccessful: $reply");
    }
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
  final List<Map<String, String>> _partners = [];
  late int _startTime;

  late String _heartRateUnits;
  late int _heartRateMax;
  final List<Map<String, int>> _heartRateData = [];

  late String _powerUnits;
  final List<Map<String, int>> _powerData = [];

  late String _cadenceUnits;
  final List <Map<String, int>> _cadenceData = [];

  late String _distanceUnits;
  final List<Map<String, int>> _distanceData = [];

  late String _calorieUnits;
  final List <Map<String, int>> _calorieData = [];

  late String _stepUnits;
  final List <Map<String, int>> _stepData = [];

  late String _speedUnits;
  final List <Map<String, int>> _speedData = [];

  late String _locationUnits;
  final List <Map<String, dynamic>> _locationData = [];

  Workout({WorkoutType workoutType = WorkoutType.cycling, int maxHeartRate = 120}) {
    start(workoutType);

    _heartRateUnits = LoggerConstants.valueBPM;
    _powerUnits = LoggerConstants.valueWatts;
    _cadenceUnits = LoggerConstants.valueRPM;
    _distanceUnits = LoggerConstants.valueMeters;
    _calorieUnits = LoggerConstants.valueKcal;
    _stepUnits = LoggerConstants.valueSteps;
    _speedUnits = LoggerConstants.valueKPH;
    _locationUnits = LoggerConstants.valueLatLong;

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

  void setCadenceUnits(String units) {
    _cadenceUnits = units;
  }

  void setSpeedUnits(String units) {
    _speedUnits = units;
  }

  void setCalorieUnits(String units) {
    _calorieUnits = units;
  }

  void setLocationUnits(String units) {
    _locationUnits = units;
  }

  void setStepUnits(String units) {
    _stepUnits = units;
  }

  void addPartner(String partnerName, String partnerDeviceId, String partnerSerialNum) {
    Map<String, String> partnerMap = {};

    partnerMap[LoggerConstants.fieldName] = partnerName;
    partnerMap[LoggerConstants.fieldDeviceId] = partnerDeviceId;
    partnerMap[LoggerConstants.fieldSerialNum] = partnerSerialNum;

    _partners.add(partnerMap);
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

    _powerData.add(powerMap);
  }

  void addDistanceData(int distance) {
    Map<String, int> distanceMap = {};

    distanceMap[LoggerConstants.fieldValue] = distance;
    distanceMap[LoggerConstants.fieldTimestamp] = ExerciseLogger.secondsSinceEpoch();

    _distanceData.add(distanceMap);
  }

  void addCadenceData(int cadence) {
    Map<String, int> map = {};

    map[LoggerConstants.fieldValue] = cadence;
    map[LoggerConstants.fieldTimestamp] = ExerciseLogger.secondsSinceEpoch();

    _cadenceData.add(map);
  }

  void addCalorieData(int calories) {
    Map<String, int> map = {};

    map[LoggerConstants.fieldValue] = calories;
    map[LoggerConstants.fieldTimestamp] = ExerciseLogger.secondsSinceEpoch();

    _calorieData.add(map);
  }

  void addStepData(int steps) {
    Map<String, int> map = {};

    map[LoggerConstants.fieldValue] = steps;
    map[LoggerConstants.fieldTimestamp] = ExerciseLogger.secondsSinceEpoch();

    _stepData.add(map);
  }

  void addSpeedData(int speed) {
    Map<String, int> map = {};

    map[LoggerConstants.fieldValue] = speed;
    map[LoggerConstants.fieldTimestamp] = ExerciseLogger.secondsSinceEpoch();

    _speedData.add(map);
  }

  void addLocationData(double latitude, double longitude) {
    Map<String, dynamic> map = {};

    map[LoggerConstants.fieldValue] = "$latitude/$longitude";
    map[LoggerConstants.fieldTimestamp] = ExerciseLogger.secondsSinceEpoch();

    _locationData.add(map);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    map[LoggerConstants.fieldWorkoutType] = _workoutType.toShortString();
    map[LoggerConstants.fieldTimestamp] = _startTime;

    if(_partners.isNotEmpty) {
      map[LoggerConstants.fieldPartners] = _partners;
    }

    if( _heartRateData.isNotEmpty) {
      Map<String, dynamic> heartRateMap = {};
      heartRateMap[LoggerConstants.fieldUnits] = _heartRateUnits;
      heartRateMap[LoggerConstants.fieldMaxHeartRate] = _heartRateMax;
      heartRateMap[LoggerConstants.fieldData] = _heartRateData;
      map[LoggerConstants.fieldHeartRate] = heartRateMap;
    }

    if(_powerData.isNotEmpty) {
      Map<String, dynamic> powerMap = {};
      powerMap[LoggerConstants.fieldUnits] = _powerUnits;
      powerMap[LoggerConstants.fieldData] = _powerData;
      map[LoggerConstants.fieldPower] = powerMap;
    }

    if(_distanceData.isNotEmpty) {
      Map<String, dynamic> distanceMap = {};
      distanceMap[LoggerConstants.fieldUnits] = _distanceUnits;
      distanceMap[LoggerConstants.fieldData] = _distanceData;
      map[LoggerConstants.fieldDistance] = distanceMap;
    }

    if(_cadenceData.isNotEmpty) {
      Map<String, dynamic> cadenceMap = {};
      cadenceMap[LoggerConstants.fieldUnits] = _cadenceUnits;
      cadenceMap[LoggerConstants.fieldData] = _cadenceData;
      map[LoggerConstants.fieldCadence] = cadenceMap;
    }

    if(_speedData.isNotEmpty) {
      Map<String, dynamic> speedMap = {};
      speedMap[LoggerConstants.fieldUnits] = _speedUnits;
      speedMap[LoggerConstants.fieldData] = _speedData;
      map[LoggerConstants.fieldSpeed] = speedMap;
    }

    if(_stepData.isNotEmpty) {
      Map<String, dynamic> stepMap = {};
      stepMap[LoggerConstants.fieldUnits] = _stepUnits;
      stepMap[LoggerConstants.fieldData] = _stepData;
      map[LoggerConstants.fieldSteps] = stepMap;
    }

    if(_calorieData.isNotEmpty) {
      Map<String, dynamic> calorieMap = {};
      calorieMap[LoggerConstants.fieldUnits] = _calorieUnits;
      calorieMap[LoggerConstants.fieldData] = _calorieData;
      map[LoggerConstants.fieldCalories] = calorieMap;
    }

    if(_locationData.isNotEmpty) {
      Map<String, dynamic> locationMap = {};
      locationMap[LoggerConstants.fieldUnits] = _locationUnits;
      locationMap[LoggerConstants.fieldData] = _locationData;
      map[LoggerConstants.fieldLocation] = locationMap;
    }

    return map;
  }
}

class LoggerConstants {
  // TODO: remove these from the source code into env variables or something
  static const databaseUrlPost = "https://us-east-1.aws.data.mongodb-api.com/app/data-nphof/endpoint/data/v1/action/insertOne";
  static const databaseUrlFind = "https://us-east-1.aws.data.mongodb-api.com/app/data-nphof/endpoint/data/v1/action/find";
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

  static const fieldGroupId = "group_id";
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
  static const fieldCalories = "calories";
  static const fieldSteps = "steps";
  static const fieldLocation = "location";
  static const fieldSpeed = "speed";
  static const fieldCadence = "cadence";

  static const valueBPM = "beats_per_minute";
  static const valueMeters = "meters";
  static const valueWatts = "watts";
  static const valueRPM = "revolutions_per_minute";
  static const valueKPH = "kilometers_per_hour";
  static const valueLatLong = "latitude/longitude";
  static const valueKcal = "kilocalories";
  static const valueSteps = "steps";
}