import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';

class ExerciseLogger {
  static ExerciseLogger instance = ExerciseLogger();

  Map<String, dynamic> map = {};

  ExerciseLogger() {
    // TODO: get real values
    map[LoggerConstants.fieldName] = "Unknown name";
    map[LoggerConstants.fieldDeviceId] = "Unknown Device";
    map[LoggerConstants.fieldSerialNum] = "Unknown Serial Num";
    map[LoggerConstants.fieldWorkout] = {};
    map[LoggerConstants.fieldEvents] = {};
  }

  void logEvent(int event, [String? info]) {

  }

  void saveToFile() {
    //final directory = await getApplicationDocumentsDirectory();
  }

  void insertInDatabase() async {
    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(LoggerConstants.databaseUrlPost));
    request.headers.set("apiKey", LoggerConstants.databaseApiKey);
    request.headers.contentType = ContentType("application", "json");

    Map<String, dynamic> body = {
      "dataSource": "FitnessLog",
      "database": "FitnessLog",
      "collection": "Test",
      "document": map
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
}