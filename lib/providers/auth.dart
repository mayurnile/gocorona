import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';



class Auth extends ChangeNotifier {
  String _token;
  DateTime _tokenExpiryDate;
  String _userId;
  Timer _authTimer;
  bool _isAdmin;
  bool _isCoronaOne;
  bool _isCoronaTwo;

  bool get isAuth {
    return _token != null;
  }

  bool get isAdmin {
    return _isAdmin;
  }

  bool get isCoronaOne {
    return _isCoronaOne;
  }

  bool get isCoronaTwo {
    return _isCoronaTwo;
  }

  String get token {
    if (_tokenExpiryDate != null &&
        _tokenExpiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _tokenExpiryDate = null;
    _isAdmin = null;
    _isCoronaOne = null;
    _isCoronaTwo = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  Future<void> signIn(String email, String password, bool isAdmin) async {
    final _user = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password))
        .user;
    final _tokenResult = await _user.getIdToken();
    _token = _tokenResult.token;
    _tokenExpiryDate = _tokenResult.expirationTime;

    _userId = _user.uid;
    _isAdmin = isAdmin;
    _isCoronaOne = null;
    _isCoronaTwo = null;

    _autoLogout();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String userData = json.encode({
      'token': _token,
      'userId': _userId,
      'expiryDate': _tokenExpiryDate.toIso8601String(),
      'isAdmin': _isAdmin,
      'isCorona': _isCoronaOne,
    });
    prefs.setString('userData', userData);
  }

  Future<void> signUp(String email, String password) async {
    final _user = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password))
        .user;
    final _tokenResult = await _user.getIdToken();
    _token = _tokenResult.token;
    _tokenExpiryDate = _tokenResult.expirationTime;

    _userId = _user.uid;
    _isCoronaOne = null;
    _isCoronaTwo = null;
    
    _autoLogout();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String userData = json.encode({
      'token': _token,
      'userId': _userId,
      'expiryDate': _tokenExpiryDate.toIso8601String(),
      'isAdmin': false,
      'isCorona': null,
    });
    prefs.setString('userData', userData);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final extractedData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _isAdmin = extractedData['isAdmin'];
    _isCoronaOne = extractedData['isCorona'];
    _isCoronaTwo = extractedData['isCorona'];
    _tokenExpiryDate = expiryDate;

    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> setCoronaOne(bool value) async {
    _isCoronaOne = value;
    final databaseReference = FirebaseDatabase.instance.reference();
     final FirebaseMessaging _fcm = FirebaseMessaging();
     

    if (value == true) {
      _fcm.subscribeToTopic('CoronaYes');
      databaseReference.child("CoronaYes").once().then((DataSnapshot snapshot) {
        print('${snapshot.value.keys}');
        // print(snapshot.value.keys);
        for (var id in snapshot.value.keys) {
          print(id);
          print("raghav");
          databaseReference
              .child("LOCATIONS")
              .child(id)
              .once()
              .then((DataSnapshot snapshot) {
            // print('${snapshot.value['latitude']}');
            if (snapshot.value != null) {
              print(snapshot.value['latitude']);
              print(snapshot.value['longitude']);
            }
          });
        }
      });
       

      databaseReference.child("CoronaNo").child(_userId).remove();
      databaseReference.child("CoronaYes").child(_userId).set({
        'title': 'You have corona',
        // 'UserId': overalluserid,
      });
    } else {
      databaseReference.child("CoronaNo").child(_userId).once().then(
        (DataSnapshot snapshot) {
          print('Data : ${snapshot.value}');
        },
      );
      //Ask alert multiple times because if by mistake click.
      databaseReference.child("CoronaYes").child(_userId).remove();
      databaseReference.child("CoronaNo").child(_userId).set(
        {
          'title': 'You dont have corona',
          // 'UserId': overalluserid,
        },
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final extractedData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userData = json.encode({
      'token': extractedData['token'],
      'userId': extractedData['userId'],
      'expiryDate': _tokenExpiryDate.toIso8601String(),
      'isAdmin': false,
      'isCorona': _isCoronaOne,
    });
    prefs.setString('userData', userData);
    notifyListeners();
  }

  Future<void> setCoronaTwo(bool value) async {
    _isCoronaTwo = value;
    final databaseReference = FirebaseDatabase.instance.reference();
     final FirebaseMessaging _fcm = FirebaseMessaging();
    if (value == true) {
      _fcm.subscribeToTopic('CoronaYes');
      databaseReference.child("CoronaYes").once().then(
        (DataSnapshot snapshot) {
          print('${snapshot.value.keys}');
          for (var id in snapshot.value.keys) {
            print(id);
            print("raghav");
            databaseReference.child("LOCATIONS").child(id).once().then(
              (DataSnapshot snapshot) {
                // print('${snapshot.value['latitude']}');
                if (snapshot.value != null) {
                  print(snapshot.value['latitude']);
                  print(snapshot.value['longitude']);
                }
              },
            );
          }
        },
      );

      databaseReference.child("CoronaNo").child(_userId).remove();
      databaseReference.child("CoronaYes").child(_userId).set({
        'title': 'You have corona',
        // 'UserId': overalluserid,
      });
    } else {
      databaseReference
          .child("CoronaNo")
          .child(_userId)
          .once()
          .then((DataSnapshot snapshot) {
        print('Data : ${snapshot.value}');
      });
      //Ask alert multiple times because if by mistake click.
      databaseReference.child("CoronaYes").child(_userId).remove();
      databaseReference.child("CoronaNo").child(_userId).set({
        'title': 'You dont have corona',
        // 'UserId': overalluserid,
      });
    }

    final prefs = await SharedPreferences.getInstance();
    final extractedData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    String userData = json.encode({
      'token': extractedData['token'],
      'userId': extractedData['userId'],
      'expiryDate': _tokenExpiryDate.toIso8601String(),
      'isAdmin': false,
      'isCorona': _isCoronaTwo,
    });
    prefs.setString('userData', userData);
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _tokenExpiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
