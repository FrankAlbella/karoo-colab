import 'dart:math';
import 'package:flutter/material.dart';
import 'package:karoo_collab/pages/workout_page.dart';
import 'package:karoo_collab/rider_data.dart';
import '../bluetooth_manager.dart';
import 'pairing_page.dart';
import '../monitor_sensor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../ble_sensor_device.dart';
import 'dart:async';
import '../rider_data.dart';
import 'settings_model.dart';
import 'workout_database.dart';

Widget _buildPopupDialog(
    BuildContext context, String funcType, TextEditingController _controller) {
  return AlertDialog(
    title: Text('Enter ' + funcType, style: TextStyle(fontSize: 10)),
    contentPadding: EdgeInsets.zero,
    content: SingleChildScrollView(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: _controller,
          style: TextStyle(fontSize: 10),
          decoration: InputDecoration(
            hintText: funcType,
          ),
        ),
      ],
    )),
    actionsPadding: EdgeInsets.zero,
    actions: <Widget>[
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          // print(_controller.text);
          // if (funcType == "Name") {
          //   data.name = _controller.text;
          //   print(data.name);
          // }
          // if (funcType == "Email") {
          //   data.name = _controller.text;
          //   print(data.name);
          // } else if (funcType == "FTP") {
          //   data.FTPvalue = _controller.text;
          // } else if (funcType == "Max HR") {
          //   data.maxHR = _controller.text;
          // }
          print(_controller.text);
          Navigator.of(context).pop();
        },
        child: const Text('Confirm'),
      ),
    ],
  );
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  final TextEditingController name_controller = TextEditingController();
  final TextEditingController FTP_controller = TextEditingController();
  final TextEditingController HR_controller = TextEditingController();
   int? profileID;
  int _counter = 0;
  
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    // name_controller.addListener(() {
    //   final String text = _controller.text.toLowerCase();
    //   _controller.value = _controller.value.copyWith(
    //     text: text,
    //     selection:
    //         TextSelection(baseOffset: text.length, extentOffset: text.length),
    //     composing: TextRange.empty,
    //   );
    // });
    _getPreviousSettings();
  }

  @override
  void dispose() {
    name_controller.dispose();
    FTP_controller.dispose();
    HR_controller.dispose();
    super.dispose();
  }
  
  Future _getPreviousSettings() async {
    ProfileSettings? previous = await WorkoutDatabase.instance.readSettings();
    print("owo?");
    if (previous != null) {
      print("pev not null");
      name_controller.text = previous.name;
      profileID = previous.id;
      if (previous.age != null) {
        FTP_controller.text = previous.age.toString();
      }
      if (previous.maxHR != null) {
        HR_controller.text = previous.maxHR.toString();
      }
    }
  }
  String getName() {
    return name_controller.text;
  }

  String getAge() {
    return FTP_controller.text;
  }

  String getMaxHR() {
    return HR_controller.text;
  }

  String calculateMaxHRString(String age) {
    return (208 - (0.7 * int.parse(age))).toString();
  }

  // void _saveSettings(ProfileSettings newSettings) async {
  //   String name = getName();
  //   String ageString = getAge();
  //   int? age = int.tryParse(ageString);
  //   String maxHRString = getMaxHR();
  //   int? maxHR = int.tryParse(maxHRString);
  //   ProfileSettings settings;
  //   if (profileID == null) {
  //     settings = ProfileSettings(name: name, age: age, maxHR: maxHR);
  //   } else {
  //     settings = ProfileSettings(id: profileID, name: name, age: age, maxHR: maxHR);
  //   }
  //   newSettings = await WorkoutDatabase.instance.updateSettings(settings);
  //   profileID = newSettings.id;
  // }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        _buildPopupDialog(context, "Name", name_controller),
                  );
                },
                icon: Icon(
                  Icons.person,
                ),
                label: const Align(
                    alignment: Alignment.centerLeft,
                    child: ListTile(
                        title: Text("Name"),
                        trailing: Icon(Icons.keyboard_arrow_right)))),
            TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        _buildPopupDialog(context, "Email", name_controller),
                  );
                },
                icon: Icon(
                  Icons.mail,
                ),
                label: const Align(
                    alignment: Alignment.centerLeft,
                    child: ListTile(
                        title: Text("Email"),
                        trailing: Icon(Icons.keyboard_arrow_right)))),
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildPopupDialog(context, "FTP", FTP_controller),
                );
              },
              icon: Icon(
                Icons.motorcycle,
              ),
              label: const Align(
                  alignment: Alignment.centerLeft,
                  child: ListTile(
                      title: Text("FTP"),
                      trailing: Icon(Icons.keyboard_arrow_right))),
            ),
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildPopupDialog(context, "Max HR", HR_controller),
                );
               
              },
              icon: Icon(
                Icons.heart_broken,
              ),
              label: const Align(
                  alignment: Alignment.centerLeft,
                  child: ListTile(
                      title: Text("Max Heart Rate"),
                      trailing: Icon(Icons.keyboard_arrow_right))),
            ),
          ],
        ),
      )),
      persistentFooterButtons: [
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
          alignment: Alignment.bottomLeft,
        ),
        const SizedBox(width: 100),
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () {
            ProfileSettings newSettings = ProfileSettings(id: profileID, name: name_controller.text, age: FTP_controller.text, maxHR: HR_controller.text);
             //_saveSettings;
              print("hg: "+ newSettings.name);
             print("oh");
          },
          alignment: Alignment.bottomLeft,
        ),
      ],
      persistentFooterAlignment: AlignmentDirectional.bottomStart,
    );
  }
}
