import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ShowGroceries extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new ShowGroceriesPage();
}

class ShowGroceriesPage extends State<ShowGroceries> {
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
    for (var key in snapshot.data.snapshot.value.keys) {
      print(snapshot.data.snapshot.value[key]['Details']);
      print(snapshot.data.snapshot.value[key]['Name']);
      print(snapshot.data.snapshot.value[key]['Address']);
      usersList.add(
        {
          'Username': snapshot.data.snapshot.value[key]['Name'],
          'Address': snapshot.data.snapshot.value[key]['Address'],
          'Details': snapshot.data.snapshot.value[key]['Details'],
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        child: StreamBuilder(
          stream: databaseReference.child('Groceries').onValue,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              print(snapshot.data.snapshot.value);
              getUsersList(snapshot);
              print("Entereed hare");
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(10.0),
                itemCount: usersList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ExpansionTile(
                      title: Text(
                        usersList[index]['Username'],
                      ),
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                usersList[index]['Address'],
                              ),
                              Text(
                                usersList[index]['Details'],
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FlatButton(
                                  onPressed: () {
                                    //TODO, remove function
                                    databaseReference
                                        .child("Groceries ")
                                        .child(overalluserid)
                                        .remove();
                                  },
                                  child: Text(
                                    'Remove',
                                    style: Theme.of(context)
                                        .textTheme
                                        .button
                                        .copyWith(
                                            color:
                                                Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                            ],
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
