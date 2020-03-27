import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth extends ChangeNotifier {
  String _token;
  DateTime _tokenExpiryDate;
  String _userId;
  Timer _authTimer;
  bool _isAdmin;

  bool get isAuth {
    return _token != null;
  }

  bool get isAdmin {
    return _isAdmin;
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

    _autoLogout();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String userData = json.encode({
      'token': _token,
      'userId': _userId,
      'expiryDate': _tokenExpiryDate.toIso8601String(),
      'isAdmin': _isAdmin,
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

    _autoLogout();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String userData = json.encode({
      'token': _token,
      'userId': _userId,
      'expiryDate': _tokenExpiryDate.toIso8601String(),
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
    _tokenExpiryDate = expiryDate;

    notifyListeners();
    _autoLogout();
    return true;
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _tokenExpiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
