import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        actions: <Widget>[
          IconButton(
          icon: Icon(
            Icons.exit_to_app,
            size: 35,
            color: Colors.white,
          ),
          onPressed: () {
            Provider.of<Auth>(context).logout();
          },
        ),
        ],
      ),
      body: Center(
        child: Text('Admin Controlr'),
      ),
    );
  }
}
