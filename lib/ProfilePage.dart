import 'package:flutter/material.dart';
import 'PairingPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';


Widget _buildPopupDialog(BuildContext context) {
  return AlertDialog(
    title: const Text('Popup example'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        Text("Hello"),
      ],
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Confirm'),
      ),
    ],
  );
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  int _counter = 0;
  static const platform = const MethodChannel('edu.uf.karoo_collab');

  String _batteryLevel = 'Unknown battery level';
  double _indicatorWidth=0;

  Future<void> _getBatteryLevel() async {
    print("got in");
    String batteryLevel;

    int percentageBattery=0;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      print(result);
      batteryLevel = ' $result % ';
      percentageBattery=result;

    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
      _indicatorWidth=(percentageBattery)*1.9;


    });
  }

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const PairingPage(title: 'Pairing with Partner')),
                  );
                },
                icon: Icon(
                  Icons.bluetooth,
                ),
                label: const Align(
                    alignment: Alignment.centerLeft,
                    child: ListTile(
                        title: Text("Pair with Partner"),
                        trailing: Icon(Icons.keyboard_arrow_right)))),
          ],
        ),
      ),
      persistentFooterButtons: [
        IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
          alignment: Alignment.bottomLeft,
        ),
        SizedBox(width: 100),
        ElevatedButton(
          onPressed: () {
           _getBatteryLevel();
           print("pressed");
          },
          child: Icon(Icons.play_arrow),
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(50, 50),
            shape: const CircleBorder(),
            backgroundColor: Colors.yellow,
          ),
        )
      ],
      persistentFooterAlignment: AlignmentDirectional.bottomStart,
    );
  }
}