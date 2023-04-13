import 'dart:developer';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:karoo_collab/logging/logger_constants.dart';
import 'package:path_provider/path_provider.dart';

class UploadManager {
  static final UploadManager _instance = UploadManager._();
  static UploadManager get instance => _instance;

  UploadManager._();

  void init() {
    Connectivity().onConnectivityChanged.listen((event) {
      log("got event ${event.name}");
      if (event == ConnectivityResult.wifi || event == ConnectivityResult.mobile) {
        _syncUnuploadedFiles();
      }
    });
  }

  Future<List<String>> getPastWorkouts() async {
    String appDocumentsDirectory =
        (await getApplicationDocumentsDirectory()).path;

    Directory unuploadedDir = Directory("$appDocumentsDirectory/not-synced");
    Directory uploadedDir = Directory("$appDocumentsDirectory/uploaded");

    List<String> unuploadedWorkouts = unuploadedDir.existsSync()
        ? unuploadedDir.listSync().map((entry) => entry.toString()).toList()
        : <String>[];
    List<String> uploadedWorkouts = uploadedDir.existsSync()
        ? uploadedDir.listSync().map((entry) => entry.toString()).toList()
        : <String>[];

    return [...unuploadedWorkouts, ...uploadedWorkouts];
  }

  Future<bool> createWorkoutFile(String filename, String json) async {
    try {
      String appDocumentsDirectory =
          (await getApplicationDocumentsDirectory()).path;
      File file = await File("$appDocumentsDirectory/not-synced/$filename.json")
          .create(recursive: true);
      await file.writeAsString(json);
      _uploadUncompletedFile(filename);
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> _uploadUncompletedFile(String filename) async {
    String appDocumentsDirectory =
        (await getApplicationDocumentsDirectory()).path;
    File file = File("$appDocumentsDirectory/not-synced/$filename.json");
    String json = await file.readAsString();
    bool result = await uploadWorkout(json);
    if(result) {
      String filename = file.path.substring(file.path.lastIndexOf("/"));

      //create uploaded directory if it doesn't exist
      await Directory("$appDocumentsDirectory/synced").create(recursive: true);

      file.rename("$appDocumentsDirectory/synced$filename");
    }
    return true;
  }

  void _syncUnuploadedFiles() async {
    String appDocumentsDirectory =
        (await getApplicationDocumentsDirectory()).path;
    Directory unuploadedDir = await Directory("$appDocumentsDirectory/not-synced").create(recursive: true);
    List<FileSystemEntity> entities = await unuploadedDir.list().toList();
    log("there are ${entities.length} files that need to be synced");
    for(FileSystemEntity entity in entities) {
      if(entity is! File) {
        continue;
      }
      File file = entity;
      String json = await file.readAsString();
      bool result = await uploadWorkout(json);
      if(result) {
        String filename = file.path.substring(file.path.lastIndexOf("/"));

        //create uploaded directory if it doesn't exist
        await Directory("$appDocumentsDirectory/synced").create(recursive: true);

        file.rename("$appDocumentsDirectory/synced$filename");
      }
    }

  }

  Future<bool> uploadWorkout(String json) async {
    const String apiKey = LoggerConstants.databaseApiKey;
    const String apiEndpoint = LoggerConstants.databaseUrlPost;

    HttpClient httpClient = HttpClient();
    HttpClientRequest request =
    await httpClient.postUrl(Uri.parse(apiEndpoint));
    request.headers.set("apiKey", apiKey);
    request.headers.set("Content-Type", "application/json");
    request.add(utf8.encode('''
    {
      "dataSource": "FitnessLog",
      "database": "FitnessLog",
      "collection": "Test",
      "document": $json
    }
    '''));

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();

    if (response.hasSuccessStatusCode) {
      log(reply);
      log("SUCCESS UPLOADING");
      return true;
    }
    log(response.statusCode.toString());
    log(reply);
    log("Error uploading workout: ${response.reasonPhrase}");
    return false;
  }
}

extension on HttpClientResponse {
  bool get hasSuccessStatusCode {
    return (statusCode ~/ 100) == 2;
  }
}
