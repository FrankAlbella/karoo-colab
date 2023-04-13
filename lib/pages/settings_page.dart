import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logging/exercise_logger.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

Widget _buildPopupDialog(
    BuildContext context, String funcType, String currentValue, TextEditingController controller) {
  return AlertDialog(
    title: Text('Enter $funcType', style: TextStyle(fontSize: 14)),
    //contentPadding: EdgeInsets.zero,
    content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: controller,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: currentValue
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

// TODO: Find better solution then copy and pasting this function
Widget _buildNumberPopupDialog(
    BuildContext context, String funcType, String currentValue, TextEditingController controller) {
  return AlertDialog(
    title: Text('Enter $funcType', style: TextStyle(fontSize: 14)),
    //contentPadding: EdgeInsets.zero,
    content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: controller,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: currentValue,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ftpController = TextEditingController();
  final TextEditingController hrController = TextEditingController();

  String _name = "";
  String _email = "";
  int _hr = 120;
  int _ftp = 250;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = (prefs.getString('name') ?? "Name");
      print(_name);
    });
    setState(() {
      _email = (prefs.getString('email') ?? "Email");
      print(_email);
    });
    setState(() {
      _hr = (prefs.getInt('maxHR') ?? 120);
      print('$_hr');
    });
    setState(() {
      _ftp = (prefs.getInt('FTP') ?? 250);
      print('$_ftp');
    });
  }

  Future<void> _updateSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if(nameController.text!="")
    {
      setState(() {
      prefs.setString('name', nameController.text);
      ExerciseLogger.instance?.setUserName(nameController.text);
    });
    }
    if(emailController.text!="")
    {
      setState(() {
      prefs.setString('email', emailController.text);
    });
    }
    if(hrController.text!="")
    {
      setState(() {
      prefs.setInt('maxHR', int.parse(hrController.text));
      ExerciseLogger.instance?.setTargetHeartRate(int.parse(hrController.text));
    });
    }
    if(ftpController.text!="")
    {
      setState(() {
      prefs.setInt('FTP', int.parse(ftpController.text));
      ExerciseLogger.instance?.setMaxFTP(int.parse(ftpController.text));
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
    nameController.dispose();
    ftpController.dispose();
    hrController.dispose();
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
                        _buildPopupDialog(context, "name", _name, nameController),
                  );
                },
                icon: const Icon(
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
                        _buildPopupDialog(context, "email address", _email, emailController),
                  );
                },
                icon: const Icon(
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
                      _buildNumberPopupDialog(context, "max FTP", _ftp.toString(), ftpController),
                );
              },
              icon: const Icon(
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
                      _buildNumberPopupDialog(context, "target heart rate", _hr.toString(), hrController),
                );
                print(hrController.text);
              },
              icon: const Icon(
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
            ExerciseLogger.instance?.logButtonPressed("BackButton");
            Navigator.pop(context);
          },
          alignment: Alignment.bottomLeft,
        ),
        const SizedBox(width: 100),
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () {
            ExerciseLogger.instance?.logButtonPressed("SettingsUpdate");
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
