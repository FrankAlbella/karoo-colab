import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karoo_collab/logging/upload_manager.dart';
import 'package:karoo_collab/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  UploadManager.instance.init();

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karoo Collab Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const KarooScreen(),
    );
  }
}

class KarooScreen extends StatelessWidget {
  const KarooScreen({super.key});

  final platform = const MethodChannel('edu.uf.karoo_collab');

  @override
  Widget build(BuildContext context){
    return WillPopScope(
        onWillPop: () async {
          if(Navigator.of(context).canPop()) {
            return true;
          } else {
            return false;
          }
    },
        child: const MyHomePage(title: 'Karoo Collab'));
  }
}






