import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth.dart';

class MainChatScreen extends StatefulWidget {
  @override
  // MainChatScreen(this.id);
  _MainChatScreenState createState() => _MainChatScreenState();
}

class _MainChatScreenState extends State<MainChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final databaseReference = FirebaseDatabase.instance.reference();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String receiverUserId;
  String receiverUserName;
  String senderUserId;
  String message;
  List<String> _messages = <String>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final List args = ModalRoute.of(context).settings.arguments;
    receiverUserId = args[0];
    receiverUserName = args[1];
    print(receiverUserId);

    senderUserId = Provider.of<Auth>(context).userId;
  }

  void sendindatabase() {
    print("Entered send in database");
    print(message);

    databaseReference
        .child("Messages")
        .child(senderUserId)
        .child(receiverUserId)
        .push()
        .set({
      'Message': message,
      'Order': '0',
    });

    databaseReference
        .child("Messages")
        .child(receiverUserId)
        .child(senderUserId)
        .once()
        .then(
      (DataSnapshot snapshot) {
        if (snapshot != null) {
          print('Data : ${snapshot.value.keys}');
          for (var key in snapshot.value.keys) {
            databaseReference
                .child("Messages")
                .child(receiverUserId)
                .child(senderUserId)
                .child(key)
                .once()
                .then(
              (DataSnapshot snapshot) {
                print(snapshot.value['Order']);
                if (snapshot.value['Order'] == "0") {
                  _messages.insert(0, snapshot.value['Message']);
                  print('fetched from database' +snapshot.value['Message']);
                  databaseReference
                      .child("Messages")
                      .child(senderUserId)
                      .child(receiverUserId)
                      .child(key)
                      .set(
                    {
                      'Message': snapshot.value['Message'],
                      'Order': '1',
                    },
                  );
                }
              },
            );
          }
        }
      },
    );
    setState(() {});
  }

  void _handleSubmit(String text) {
    _messageController.clear();

    setState(() {
      _messages.insert(0, text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    _messages = _messages.reversed.toList();

    print(mediaQuery);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          receiverUserName,
          style: Theme.of(context).textTheme.subtitle,
        ),
        elevation: 0.0,
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
              child: Container(
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
                width: mediaQuery.size.width,
                height: mediaQuery.size.height * 0.7,
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (ctx, index) => ListTile(
                    trailing: Text(
                      _messages[index],
                      style: Theme.of(context)
                          .textTheme
                          .subhead
                          .copyWith(color: Colors.black),
                    ),
                  ),
                ),
              ),
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
                        _handleSubmit(message);
                        //TODO, logic of senfing here...
                        // showText();

                        sendindatabase();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
