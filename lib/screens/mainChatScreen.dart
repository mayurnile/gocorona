import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class MainChatScreen extends StatefulWidget {
  @override
  _MainChatScreenState createState() => _MainChatScreenState();
}

class _MainChatScreenState extends State<MainChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String receiverUserId;
  String receiverUserName;
  String senderUserId;
  String message;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final List args = ModalRoute.of(context).settings.arguments;
    receiverUserId = args[0];
    receiverUserName = args[1];
    senderUserId = Provider.of<Auth>(context).userId;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          receiverUserName,
          style: Theme.of(context).textTheme.subtitle,
        ),
        elevation: 0.0,
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: Colors.white,
        ),
        height: mediaQuery.size.height,
        width: mediaQuery.size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            //TODO, is container ko listview me dal dena scrolling keliye
            Container(
              child: Text('show conversation here....'),
            ),
            Spacer(),
            Container(
              alignment: Alignment.center,
              height: 45,
              width: mediaQuery.size.width,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type Message Here...',
                        hintStyle: Theme.of(context).textTheme.body1,
                      ),
                    ),
                  ),
                  IconButton(
                    alignment: Alignment.center,
                    icon: Icon(
                      Icons.send,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      message = _messageController.text;
                      //TODO, logic of senfing here...
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
          ],
        ),
      ),
    );
  }
}
