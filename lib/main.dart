// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_this

import 'package:flutter/material.dart';
import 'package:notifications/notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'utils.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Notifications? _notifications;
  StreamSubscription<NotificationEvent>? _subscription;
  final storage = FlutterSecureStorage();
  String? webhook_url;
  String? info;

  bool getInfoIsnull() {
    return this.info.toString() == 'null';
  }

  void onData(NotificationEvent event) {}

  @override
  void initState() {
    _notifications = Notifications();
    try {
      _subscription = _notifications!.notificationStream!.listen(onData);
    } on NotificationException catch (exception) {
      print(exception);
    }

    super.initState();
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
