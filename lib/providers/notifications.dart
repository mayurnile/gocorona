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
  //phir code yaha pe ata hai idhar is function ko humne title and message pass kiya hai
  //phir apna firebase me na database ka url hota hai ek
  //voh vaha pe dikhaya voh toh maine voh ek file me store kr rakha hai

  Future<void> addNotificationAdmin(String title, String message) async {
    final url =
        FirebaseUrl.ADMIN_NOTFICATION_URL + '$userId.json?auth=$authToken';
        //aur yaha pe jo age userId add kiya hai na voh age userId jo login krne ke bad create hota hai
        //voh add krne keliye phir firebse hamein ek loginToken bhi deta hai ek random number for security reasons
        //phor voh dono userid and token add kiya age link kee

    //aur yaha pe maine firebase ko request bheja http.post
    //yeh isko na REST API's bolte hai 
    //server se baat cheet krne ka tarika
    //3 type ke request hote hai 
    //post : agar database me data enter krna ho toh
    //put : agar database me data update krna ho toh
    //get : agar database me se data fetch krna ho toh
    //for example
    final response = await http.post(
      url,
      body: json.encode(
        {
          'notification': {
            'title': title,
            'body': message,
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
      ),
    );
    if (response == null) {
      print('Something Went Wrong');
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
