import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminDistress extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AdminDistresscall();
}

class AdminDistresscall extends State<AdminDistress> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.reference();

  var overalluserid;

  void inputData() async {
    FirebaseUser user = await firebaseAuth.currentUser();
    overalluserid = user.uid;
    print(overalluserid);
  }

  List<Map<String, String>> usersList = [];

  Future<void> getUsersList(AsyncSnapshot snapshot) async {
    usersList = [];
    print("enetreed main screeen");
    print(snapshot.data.snapshot.value);

    //Display this as Buttons
    for (var id in snapshot.data.snapshot.value.keys) {
      for (var other in snapshot.data.snapshot.value[id].keys) {
        print(snapshot.data.snapshot.value[id][other]['Name']);
        print(snapshot.data.snapshot.value[id][other]['Mobile Number']);
        print(snapshot.data.snapshot.value[id][other]['Distress Message']);
        print(snapshot.data.snapshot.value[id][other]['Distress Title']);
        usersList.add(
          {
            'userId': id,
            'Username': snapshot.data.snapshot.value[id][other]['Name'],
            'Mobile Number': snapshot.data.snapshot.value[id][other]
                ['Mobile Number'],
            'Distress Title': snapshot.data.snapshot.value[id][other]
                ['Distress Title'],
            'Distress Message': snapshot.data.snapshot.value[id][other]
                ['Distress Message'],
          },
        );
      }
    }
  }

  Future<void> _launchCaller(String number) async {
    final url = "tel:$number";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        child: StreamBuilder(
          stream: databaseReference.child('Distress_Messages').onValue,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                    // valueColor: AlwaysStoppedAnimation
                    ),
              );
            } else {
              print(snapshot.data.snapshot.value.keys);
              getUsersList(snapshot);
              print("Entereed hare");
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: usersList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ExpansionTile(
                      title: Text(usersList[index]['Distress Title']),
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Name : ${usersList[index]['Username']}',
                                ),
                                Text(
                                  'Mobile Number : ${usersList[index]['Mobile Number']}',
                                ),
                                Text(
                                  'Message : ${usersList[index]['Distress Message']}',
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FlatButton(
                                    onPressed: () async {
                                      await _launchCaller(
                                          usersList[index]['Mobile Number']);
                                    },
                                    child: Text(
                                      'Dial',
                                      style: Theme.of(context)
                                          .textTheme
                                          .button
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
