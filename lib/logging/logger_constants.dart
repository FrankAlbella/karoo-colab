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
  static const eventScreenOn = 14;
  static const eventScreenOff = 15;
  static const eventScreenUnlocked = 16;

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

enum DeviceType {
  karoo,
  smartwatch,
  smartphone
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