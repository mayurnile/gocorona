import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../providers/notifications.dart';

import '../models/notification.dart';

class NotificationPanel extends StatefulWidget {
  @override
  _NotificationPanelState createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void addToNotificationsList(Map<String, dynamic> message) {
    final notification = message['notification'];
    Provider.of<MyNotifications>(context).addNotification(
      MyNotification(
        title: notification['title'],
        body: notification['body'],
        notificationTime: DateTime.now(),
      ),
    );
  }

  @override
  void initState() {  

    _firebaseMessaging.getToken();

    _firebaseMessaging.subscribeToTopic('all');
    
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        addToNotificationsList(message);
        print('onMessage : $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        addToNotificationsList(message);
        print('onLaunch : $message');
      },
      onResume: (Map<String, dynamic> message) async {
        addToNotificationsList(message);
        print('onResume : $message');
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<MyNotifications>(
        context,
        listen: false,
      ).fetchNotifications(),
      builder: (ctx, dataSnapshot) {
        if (dataSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          if (dataSnapshot.error != null) {
            // ...
            // Do error handling stuff
            return Center(
              child: Text('An error occurred!'),
            );
          } else {
            return Consumer<MyNotifications>(
              builder: (ctx, notificationData, child) => ListView.builder(
                itemCount: notificationData.getNotifications.length,
                itemBuilder: (ctx, index) => ListTile(
                  title: Text(
                    notificationData.getNotifications[index].title,
                  ),
                  subtitle: Text(
                    notificationData.getNotifications[index].body,
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }
}
