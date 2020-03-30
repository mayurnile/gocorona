import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../screens/mainChatScreen.dart';

import '../providers/auth.dart';

import '../constants/constants.dart';

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final databaseReference = FirebaseDatabase.instance.reference();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name = "";
  int yes = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(MessageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void validateAndSubmit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      print("Entered Validate and submit");
      Provider.of<Auth>(context).setName(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textTheme = Theme.of(context).textTheme;
    bool isCorona = Provider.of<Auth>(context, listen: false).isCoronaOne;
    String isName = Provider.of<Auth>(context, listen: false).getName;
    List<Map<String, String>> usersList = [];

    final alertDialog = AlertDialog(
      title: Text(
        'Are You a Corona Patient ?',
        style: textTheme.button.copyWith(
          color: Colors.black.withOpacity(0.8),
        ),
      ),
      content: Text(
        'Please be honest to help save others life too...',
        style: textTheme.body1,
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () async {
            await Provider.of<Auth>(context).setCoronaOne(true);
            setState(() {
              isCorona = true;
            });
            //Navigator.of(context).pop();
          },
          child: Text('YES'),
        ),
        FlatButton(
          onPressed: () async {
            await Provider.of<Auth>(context).setCoronaOne(false);
            //Navigator.of(context).pop();
            setState(() {
              isCorona = false;
            });
          },
          child: Text('NO'),
        ),
      ],
    );

    Future<void> getUsersList(AsyncSnapshot snapshot) async {
      usersList = [];
      print("enetreed main screeen");
      print(snapshot.data.snapshot.value);

      //Display this as Buttons
      for (var key in snapshot.data.snapshot.value.keys) {
        usersList.add(
          {
            'userId': key,
            'username': snapshot.data.snapshot.value[key]['Username'],
          },
        );
        //usernames.add(snapshot.data.snapshot.value[key]['Username']);
      }
    }

    return Container(
      height: mediaQuery.size.height,
      width: mediaQuery.size.width,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: isName == null
                ? Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            maxLines: 1,
                            keyboardType: TextInputType.emailAddress,
                            autofocus: false,
                            decoration: InputDecoration(
                              hintText: 'Name',
                              icon: Icon(
                                Icons.mail,
                                color: Colors.grey,
                              ),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Name should not be empty";
                              } else {
                                return null;
                              }
                            },
                            onSaved: (value) => name = value.trim(),
                          ),
                        ),
                        RaisedButton(
                          elevation: 5.0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 42,
                            vertical: 8.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            "Submit",
                            style: Theme.of(context).textTheme.button,
                          ),
                          onPressed: () {
                            validateAndSubmit();
                          },
                        ),
                      ],
                    ),
                  )
                : Container(
                    child: StreamBuilder(
                      stream: databaseReference.child('Users').onValue,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          );
                        } else {
                          getUsersList(snapshot);

                          return ListView.builder(
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.all(10.0),
                            itemCount: usersList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical : 8.0),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 35,
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(
                                    usersList[index]['username'],
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      Routes.MAIN_CHAT_SCREEN,
                                      arguments: [
                                        usersList[index]['userId'],
                                        usersList[index]['username'],
                                      ],
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
          ),
          isCorona == null ? alertDialog : SizedBox.shrink(),
        ],
      ),
    );
  }
}
