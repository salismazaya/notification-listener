// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_this, depend_on_referenced_packages, unused_import

import 'package:flutter/material.dart';
import 'package:notifications/notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:http/http.dart' as http;
import 'listener.dart';
import 'storage.dart';

import 'utils.dart';
import 'dart:async';

// this will be used as notification channel id
const notificationChannelId = 'salisganteng';

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(),
  );
  service.startService();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = getStorage();
  String? webhook_url;
  String? info;

  bool getInfoIsnull() {
    return this.info.toString() == 'null';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Notification Listener'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Visibility(
                    visible: !this.getInfoIsnull(),
                    child: Text(this.info.toString()),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Webhook Url',
                    hintText: 'Enter Webhook Url',
                  ),
                  onChanged: (String text) {
                    this.webhook_url = text;
                  },
                ),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  child: ElevatedButton(
                    onPressed: (() async {
                      if (!isUrlValid(this.webhook_url)) {
                        setState(() {
                          this.info = null;
                        });
                        await Future.delayed(Duration(seconds: 1));
                        setState(() {
                          this.info = 'Url not valid!';
                        });

                        return;
                      }
                      await this
                          .storage
                          .write(key: "webhook_url", value: this.webhook_url);
                      setState(() {
                        this.info = null;
                      });
                      await Future.delayed(Duration(seconds: 1));
                      setState(() {
                        this.info = 'Success set url!';
                      });
                    }),
                    child: Text(
                      "Save",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
