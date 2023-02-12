import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

Widget _buildPopupDialog(BuildContext context) {
  return new AlertDialog(
    title: const Text('Popup example'),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Hello"),
      ],
    ),
    actions: <Widget>[
      new TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Cancel'),
      ),
      new TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Confirm'),
      ),
    ],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karoo Collab Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.grey,
      ),
      home: const MyHomePage(title: 'Karoo Collab Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const ConnectionsPage(title: 'Connections')),
                );
              },
              icon: Icon(
                Icons.people,
              ),
              label: const Align(
                  alignment: Alignment.centerLeft,
                  child: ListTile(
                      title: Text("Connections"),
                      trailing: Icon(Icons.keyboard_arrow_right))),
            ),
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => _buildPopupDialog(context),
                );
              },
              icon: Icon(
                Icons.alarm,
              ),
              label: const Align(
                  alignment: Alignment.centerLeft,
                  child: ListTile(
                      title: Text("Alerts"),
                      trailing: Icon(Icons.keyboard_arrow_right))),
            ),
          ],
        ),
      ),
    );
  }
}

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<ConnectionsPage> createState() => _ConnectionsPage();
}

class _ConnectionsPage extends State<ConnectionsPage> {
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
                            const ProfilePage(title: 'Profile')),
                  );
                },
                icon: Icon(
                  Icons.person,
                ),
                label: const Align(
                  alignment: Alignment.centerLeft,
                  child: ListTile(
                      title: Text("Aimee"),
                      trailing: Icon(Icons.drag_handle))),
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
            showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopupDialog(context),
            );
          },
          child: Icon(Icons.add),
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(50, 50),
            shape: const CircleBorder(),
            backgroundColor: Colors.blueGrey,
          ),
        )
      ],
      persistentFooterAlignment: AlignmentDirectional.bottomStart,
    );
  }
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
                      trailing: Icon(Icons.keyboard_arrow_right))),
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
            showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopupDialog(context),
            );
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

class PairingPage extends StatefulWidget {
  const PairingPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<PairingPage> createState() => _PairingPage();
}

class _PairingPage extends State<PairingPage> {
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
                onPressed: () {},
                icon: Icon(
                  Icons.bluetooth,
                ),
                label: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Pair with Parter"))),
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
      ],
      persistentFooterAlignment: AlignmentDirectional.bottomStart,
    );
  }
}
