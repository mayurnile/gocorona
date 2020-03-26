import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/notification.dart';

import '../constants/constants.dart';

class MyNotifications with ChangeNotifier {
  final String authToken;
  final String userId;

  MyNotifications(
    this.authToken,
    this.userId,
    this._notifications,
  );

  List<MyNotification> _notifications = [];

  List<MyNotification> get getNotifications {
    return [..._notifications];
  }

  Future<void> addNotification(MyNotification notification) async {
    final url = FirebaseUrl.NOTIFICATION_URL + '$userId.json?auth=$authToken';
    final response = await http.post(
      url,
      body: json.encode(
        {
          'title': notification.title,
          'body': notification.body,
          'notificationTime': notification.notificationTime.toIso8601String(),
        },
      ),
    );
    if (response == null) {
      print('Something Went Wrong');
    } else {
      _notifications.insert(0, notification);
    }
    print('success');
    print(_notifications);
    notifyListeners();
  }

  Future<void> fetchNotifications() async {
    final url = FirebaseUrl.NOTIFICATION_URL + '$userId.json?auth=$authToken';
    final response = await http.get(url);
    final List<MyNotification> extractedNotifications = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null) {
      return;
    }
    extractedData.forEach((id, notification) {
      extractedNotifications.add(
        MyNotification(
          title: notification['title'],
          body: notification['body'],
          notificationTime: DateTime.parse(notification['notificationTime']),
        ),
      );
    });
    _notifications = extractedNotifications;
    notifyListeners();
  }
}
