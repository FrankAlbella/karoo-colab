import 'exercise_logger.dart';
import 'logger_constants.dart';

class Workout {
  late WorkoutType _workoutType;
  final List<Map<String, String>> _partners = [];
  late int _startTime;

  late String _heartRateUnits;
  late int _heartRateTarget;
  final List<Map<String, int>> _heartRateData = [];

  late String _powerUnits;
  late int _maxFTP;
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

  Workout({WorkoutType workoutType = WorkoutType.cycling, int targetHeartRate = 120, int maxFTP = 250}) {
    start(workoutType);

    _heartRateUnits = LoggerConstants.valueBPM;
    _powerUnits = LoggerConstants.valueWatts;
    _cadenceUnits = LoggerConstants.valueRPM;
    _distanceUnits = LoggerConstants.valueMeters;
    _calorieUnits = LoggerConstants.valueKcal;
    _stepUnits = LoggerConstants.valueSteps;
    _speedUnits = LoggerConstants.valueKPH;
    _locationUnits = LoggerConstants.valueLatLong;

    _heartRateTarget = targetHeartRate;
    _maxFTP = 250;
  }

  void start(WorkoutType workoutType) {
    _startTime = ExerciseLogger.secondsSinceEpoch();
    _workoutType = workoutType;
  }

  void setTargetHeartRate(int target) {
    _heartRateTarget = target;
  }

  void setMaxFTP(int max) {
    _maxFTP = max;
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
      heartRateMap[LoggerConstants.fieldTargetHeartRate] = _heartRateTarget;
      heartRateMap[LoggerConstants.fieldData] = _heartRateData;
      map[LoggerConstants.fieldHeartRate] = heartRateMap;
    }

    if(_powerData.isNotEmpty) {
      Map<String, dynamic> powerMap = {};
      powerMap[LoggerConstants.fieldUnits] = _powerUnits;
      powerMap[LoggerConstants.fieldData] = _powerData;
      powerMap[LoggerConstants.fieldMaxFTP] = _maxFTP;
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