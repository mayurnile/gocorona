import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/notifications.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _title = "";

  String _message = "";

  var isLoading = false;

  void submitMessage() async {
    setState(() {
      isLoading = true;
    });
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      print('Title : $_title');
      print('Message : $_message');
      //TODO, code to store on database
      await Provider.of<MyNotifications>(context)
          .addNotificationAdmin(_title, _message);
    }
    setState(() {
      isLoading = false;
    });
  }

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
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Text(
              'Send Notification',
              style: Theme.of(context)
                  .textTheme
                  .subtitle
                  .copyWith(color: Colors.black),
            ),
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Title : ',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  SizedBox(
                    width: 44,
                  ),
                  Flexible(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Enter Title Here',
                        hintStyle: Theme.of(context).textTheme.body1,
                      ),
                      onSaved: (value) {
                        _title = value;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Message : ',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  Flexible(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Enter Message Here',
                        hintStyle: Theme.of(context).textTheme.body1,
                      ),
                      onSaved: (value) {
                        _message = value;
                      },
                    ),
                  ),
                ],
              ),
            ),
            RaisedButton(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 8.0,
              ),
              color: Theme.of(context).primaryColor,
              onPressed: submitMessage,
              child: isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text(
                      'Notify All',
                      style: Theme.of(context).textTheme.button,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
