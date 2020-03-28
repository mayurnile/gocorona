import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './map_widget.dart';

class HeatMap extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HeatMapState();
}

class _HeatMapState extends State<HeatMap> {
  Position position;
  Geolocator geolocator = Geolocator();

  Position userLocation;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseUser user = null;

  @override
  void initState() {
    super.initState();
    _getLocation().then(
      (position) {
        userLocation = position;
        //getAddress(userLocation.latitude, userLocation.longitude);
      },
    );
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition();
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await firebaseAuth.currentUser();
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getLocation(),
      builder: (ctx, snapshot) {
        return Container(
          child: snapshot.connectionState == ConnectionState.waiting
              ? CircularProgressIndicator()
              : MapWidget(
                  userLocation: userLocation,
                ),
        );
      },
    );
  }
}
