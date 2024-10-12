import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notification_app/Services/nontification_services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  NotificationServices notification = NotificationServices();

  @override
  void initState() {
    super.initState();
    notification.requestNotificationPermission();
    notification.firebaseInit(context);
    notification.setupInteractMessage(context);
    notification.getDeviceToken().then((value) {
      if (kDebugMode) {
        print("Device Token");
        print(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text(
          "Notification",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          Badge.count(
            count: 10,
            child: const Icon(
              CupertinoIcons.bell,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            width: 30,
          ),
        ],
      ),
    );
  }
}
