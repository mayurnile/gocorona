import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import './show_groceries.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:async';
// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';

class Groceries extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new GroceriesDonate();
}

class GroceriesDonate extends State<Groceries> {
  final _formKey = new GlobalKey<FormState>();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.reference();

  var overalluserid;
  String address;
  String _errorMessage;
  String details;
  String name;

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
        databaseReference.child("Groceries").child(overalluserid).set({
          'Name': name,
          'Address': address,
          'Details': details,
          // 'UserId': overalluserid,
        });
      } catch (e) {
        print('Error: $e');
        setState(() {
          _errorMessage = e.message;
          _formKey.currentState.reset();
        });
      }
    }
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
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _showForm(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Received Groceries',
                style: Theme.of(context).textTheme.subhead,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: ShowGroceries(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showForm() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Donate Groceries',
              style: Theme.of(context).textTheme.subhead,
            ),
            showNameinput(),
            showAddressinput(),
            showDetailsinput(),
            showPrimaryButton(),
            showErrorMessage(),
          ],
        ),
      ),
    );
  }

  Widget showNameinput() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Name',
            icon: new Icon(
              Icons.mail,
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

  Widget showAddressinput() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Address',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) {
          if (value.isEmpty) {
            return "Address should not be empty";
          } else {
            return null;
          }
        },
        onSaved: (value) => address = value.trim(),
      ),
    );
  }

  Widget showDetailsinput() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Details Here',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) {
          if (value.isEmpty) {
            return "Field should not be empty";
          } else {
            return null;
          }
        },
        onSaved: (value) => details = value.trim(),
      ),
    );
  }

  Widget showPrimaryButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: new Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: new Text("Submit",
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
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
