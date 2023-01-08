// ignore_for_file: depend_on_referenced_packages

import 'package:notifications/notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:http/http.dart' as http;
import 'package:notification_listener/storage.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

@pragma('vm:entry-point')
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

MyHttpOverrides _httpOverrid = MyHttpOverrides();

@pragma('vm:entry-point')
void onData(NotificationEvent event) async {
  try {
    HttpOverrides.global = _httpOverrid;
    var storage = getStorage();
    var payload = {
      'message': event.message,
      'title': event.title,
      'packageName': event.packageName,
      'timestamp': event.timeStamp.toString(),
    };

    var uri = Uri.parse(await storage.read(key: "webhook_url") ?? '');
    await http.post(uri,
        body: json.encode(payload),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {}
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  Notifications? _notifications;
  StreamSubscription<NotificationEvent>? _subscription;
  _notifications = Notifications();
  try {
    _subscription = _notifications.notificationStream!.listen(onData);
  } on NotificationException catch (exception) {}

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}
