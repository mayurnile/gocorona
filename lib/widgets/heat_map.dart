import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
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

  var userLocation;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseUser user = null;

  @override
  void initState() {
    super.initState();
    _getLocation();
    // _getLocation().then(
    //   (position) {
    //     userLocation = position;
    //     //getAddress(userLocation.latitude, userLocation.longitude);
    //   },
    // );
  }

  Future<void> _getLocation() async {
    var currentLocation;
    try {
      // currentLocation = await geolocator.getCurrentPosition();
      currentLocation = await Location().getLocation();
      userLocation = currentLocation;
      print('User Location : '+currentLocation.latitude+currentLocation.longitude);
    } catch (e) {
      currentLocation = null;
    }
    //return currentLocation;
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
              // : Container(
              //   child: Text('Location : ${userLocation.latitude} + ${userLocation.longitude}'),
              // ),
              : MapWidget(
                  userLocation: userLocation,
                ),
        );
      },
    );
  }
}
