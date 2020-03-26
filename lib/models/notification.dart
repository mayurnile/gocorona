import 'package:flutter/foundation.dart';

class MyNotification {
  final String title;
  final String body;
  final DateTime notificationTime;

  MyNotification({
    @required this.title,
    @required this.body,
    @required this.notificationTime,
  });
}

