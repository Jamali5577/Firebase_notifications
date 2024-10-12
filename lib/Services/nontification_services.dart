import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_app/message_screen.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Request permission for notifications
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print("User granted permission");
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print("User granted provisional permission");
      }
    } else {
      if (kDebugMode) {
        print("User denied permission");
      }
    }
  }

  // Initialize local notification settings
  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {
        handleMessage(context, message);
      },
    );
  }

  // Firebase messaging listener
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (Platform.isAndroid) {
        initLocalNotification(context, message);
        showNotification(message);
      } else {
        showNotification(message);
      }
    });
  }

  // Show notification
  Future<void> showNotification(RemoteMessage message) async {
    // Define a static channel ID and details to avoid issues
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            presentSound: true, presentAlert: true, presentBadge: true);

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    // Check for null values in the notification content
    String? title = message.notification?.title;
    String? body = message.notification?.body;

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0, title, body, notificationDetails);
    });
  }

  // Get the device token
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  // Listen for token refresh
  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen(
      (newToken) {
        if (kDebugMode) {
          print("Token refreshed: $newToken");
        }
      },
    );
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'msg') {
      // print(message.data['type']);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MessageScreen(
                    id: message.data['id'],
                  )));
    }
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    //when app is terminated

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }

    //when app is in Background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }
}
