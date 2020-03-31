import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth.dart';
import 'dart:ui';
import 'dart:async';

class MainChatScreen extends StatefulWidget {
  @override
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
  Timer timer;
  List<String> _messages = <String>[
    'Did you heard about the case of COVID-19 patient from our area ?',
    'Yes I just heard that from my parents they told me that',
    'Yeah the whole situation is very dangerous how can we survive in this type of dangerous situation ?',
    'Do not worry I watched our PM Narendra Modi\'s news on tv, he said that we need to take good care of ourselves, wash hands in every half an hour and use sanitizers, avoid public places by taking care of these things we can avoid the threat created by corona virus',
    'Yes You are right all we need to do is stay at home and stay safe.'
  ];

  List<int> _orders = <int>[
    0,
    1,
    0,
    1,
    0,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final List args = ModalRoute.of(context).settings.arguments;
    receiverUserId = args[0];
    receiverUserName = args[1];
    print(receiverUserId);

    senderUserId = Provider.of<Auth>(context).userId;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void receivefromdatabase() {
    print("Entered receivefromdatabase");
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
                if (snapshot.value['Order'] == '0') {
                  _messages.insert(0, snapshot.value['Message']);
                  print('fetched from database' + snapshot.value['Message']);
                  databaseReference
                      .child("Messages")
                      .child(receiverUserId)
                      .child(senderUserId)
                      .child(key)
                      .update(
                    {
                      'Message': snapshot.value['Message'],
                      'Order': '1',
                    },
                  );
                  _messages.add(snapshot.value['Message']);
                }
              },
            );
          }
        }
      },
    );
    setState(() {});
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
    setState(() {});
  }

  void _handleSubmit(String text) {
    _messageController.clear();

    setState(() {
      _messages.add(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    //_messages = _messages.reversed.toList();
    //TODO, enabled this later
    // timer = Timer.periodic(
    //   Duration(seconds: 15),
    //   (Timer t) => receivefromdatabase(),
    // );
    // Timer.run(() => receivefromdatabase);

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
                    physics: BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(12.0),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, index) {
                      return Align(
                        alignment: _orders[index] == 0
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          width: mediaQuery.size.width * 0.6,
                          child: Text(
                            _messages[index],
                            style: Theme.of(context).textTheme.body1.copyWith(
                                  color: Colors.black.withOpacity(0.8),
                                ),
                          ),
                        ),
                      );
                    }
                    // ListTile(
                    //   trailing: Text(
                    //     _messages[index],
                    //     style: Theme.of(context)
                    //         .textTheme
                    //         .subhead
                    //         .copyWith(color: Colors.black),
                    //   ),
                    // ),
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
                        sendindatabase();
                        _handleSubmit(message);
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
