import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:async';
// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';

class Distress extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new Distresscall();
}

class Distresscall extends State<Distress> {
  final _formKey = new GlobalKey<FormState>();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.reference();

  var overalluserid;
  String name;
  String _errorMessage;
  String number;
  String distress_title;
  String distress_message;

  void initState() {
    _errorMessage = "";
    inputData();

    super.initState();
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  void inputData() async {
    FirebaseUser user = await firebaseAuth.currentUser();
    overalluserid = user.uid;
    print(overalluserid);
  }

  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
    });
    if (validateAndSave()) {
      try {
        print("Entered Validate and Submit");
        print(name);
        print(number);
        print(distress_title);
        print(distress_message);

        databaseReference
            .child("Distress_Messages")
            .child(overalluserid)
            .push()
            .set({
          'Name': name,
          'Mobile Number': number,
          'Distress Title': distress_title,
          'Distress Message': distress_message,
          // 'UserId': overalluserid,
        });
        resetForm();
        showalertbox();
      } catch (e) {
        print('Error: $e');
        setState(() {
          _errorMessage = e.message;
          _formKey.currentState.reset();
        });
      }
      showAlertBox();
    }
  }

  //Show this Alert after submit
  void showAlertBox() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Success',
          style: Theme.of(context).textTheme.subhead,
        ),
        content: Text(
          'Your response is recorded, we\'ll get back to you soon...',
          style: Theme.of(context).textTheme.body1,
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Okay',
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget showalertbox() {
    print("Entered show alert box");

    return AlertDialog(
      title: new Text("Alert Dialotle"),
      content: new Text("Alert Dialog body"),
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _showForm(),
    );
  }

  Widget _showForm() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Distress Call',
              style: Theme.of(context).textTheme.subhead,
            ),
            showNameinput(),
            showNumberinput(),
            showDistresstitleinput(),
            showDistressMessageinput(),
            showPrimaryButton(),
            showErrorMessage(),
          ],
        ),
      ),
    );
  }

  Widget showDistressMessageinput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Distress Message',
            icon: new Icon(
              Icons.message,
              color: Colors.grey,
            )),
        validator: (value) {
          if (value.isEmpty) {
            return "Distress Message should not be empty";
          } else {
            return null;
          }
        },
        onSaved: (value) => distress_message = value.trim(),
      ),
    );
  }

  Widget showDistresstitleinput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Distress Title',
            icon: new Icon(
              Icons.airline_seat_flat,
              color: Colors.grey,
            )),
        validator: (value) {
          if (value.isEmpty) {
            return "Distress Title should not be empty";
          } else {
            return null;
          }
        },
        onSaved: (value) => distress_title = value.trim(),
      ),
    );
  }

  Widget showNameinput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Name',
            icon: new Icon(
              Icons.person,
              color: Colors.grey,
            )),
        validator: (value) {
          if (value.isEmpty) {
            return "Name should not be empty";
          } else {
            return null;
          }
        },
        onSaved: (value) => name = value.trim(),
      ),
    );
  }

  Widget showNumberinput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Mobile Number',
            icon: new Icon(
              Icons.phone,
              color: Colors.grey,
            )),
        validator: (value) {
          if (value.isEmpty) {
            return "Mobile Number should not be empty";
          } else {
            return null;
          }
        },
        onSaved: (value) => number = value.trim(),
      ),
    );
  }

  Widget showPrimaryButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: Text("Submit",
                style: TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () {
              validateAndSubmit();
              // Navigator.push(
              // context,
              // MaterialPageRoute(builder: (context) => chatscreen()),
              // );
            },
          ),
        ),
      ),
    );
  }
}
