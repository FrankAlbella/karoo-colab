import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karoo_collab/pages/workout_page.dart';
import 'package:karoo_collab/rider_data.dart';
import '../bluetooth_manager.dart';
import '../logging/exercise_logger.dart';
import '../monitor_sensor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../ble_sensor_device.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

@override
void initState() {
  super.initState();
}


Widget _buildPopupDialog(
    BuildContext context, String funcType, TextEditingController _controller) {
  return AlertDialog(
    //title: Text('Enter ' + funcType, style: TextStyle(fontSize: 14)),
    //contentPadding: EdgeInsets.zero,
    content: SingleChildScrollView(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: _controller,
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: funcType,
          ),
        ),
      ],
    )),
    actionsPadding: EdgeInsets.zero,
    actions: <Widget>[
      Center(
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Confirm'),
        ),
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
  final TextEditingController email_controller = TextEditingController();
  final TextEditingController FTP_controller = TextEditingController();
  final TextEditingController HR_controller = TextEditingController();

  String _name = "";
  String _email = "";
  String _HR = "";
  String _FTP = "";

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = (prefs.getString('name') ?? "Name");
      print('$_name');
    });
    setState(() {
      _email = (prefs.getString('email') ?? "Email");
      print('$_email');
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

  Future<void> _updateSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if(name_controller.text!="")
    {
      setState(() {
      prefs.setString('name', name_controller.text);
    });
    }
    if(email_controller.text!="")
    {
      setState(() {
      prefs.setString('email', email_controller.text);
    });
    }
    if(HR_controller.text!="")
    {
      setState(() {
      prefs.setString('maxHR', HR_controller.text);
    });
    }
    if(FTP_controller.text!="")
    {
      setState(() {
      prefs.setString('FTP', FTP_controller.text);
    });
    }  
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    name_controller.dispose();
    FTP_controller.dispose();
    HR_controller.dispose();
    super.dispose();
  }

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
                        _buildPopupDialog(context, _name, name_controller),
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
                        _buildPopupDialog(context, _email, email_controller),
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
                      _buildPopupDialog(context, _FTP, FTP_controller),
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
                      _buildPopupDialog(context, _HR, HR_controller),
                );
                print(HR_controller.text);
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
            _updateSettings();
            Fluttertoast.showToast(
                msg: "Updated Settings!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
          },
          alignment: Alignment.bottomLeft,
        ),
      ],
      persistentFooterAlignment: AlignmentDirectional.bottomStart,
    );
  }
}
