import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../providers/auth.dart';

class MyMapPage extends StatefulWidget {
  @override
  _MyMapPageState createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {
  final databaseReference = FirebaseDatabase.instance.reference();
  Location _locationTracker = Location();
  Geolocator geolocator = Geolocator();
  StreamSubscription _locationSubscription;
  Marker marker;
  GoogleMapController _controller;
  List<Marker> markers = [];
  List<Placemark> placemark;
  String address = "";
  var overalluserid;

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(19.2271, 73.1395),
    zoom: 14.4746,
  );

  void updateMarkerAndCircle(LocationData newLocalData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      marker = Marker(
        markerId: MarkerId(overalluserid),
        position: latlng,
        //rotation: newLocalData.heading,
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        icon: BitmapDescriptor.defaultMarker,
      );
    });
  }

  void initmarker(double latitude, double longitude, String id) {
    final Marker differentuser = Marker(
      markerId: MarkerId(id),
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title: "My Location"),
    );
    markers.add(differentuser);
  }

  int checkid = 0;

  void updateRecord(
    double latitude,
    double longitude,
    List<Placemark> placemark,
  ) {
    databaseReference.child("LOCATIONS").once().then((DataSnapshot snapshot) {
      for (var userids in snapshot.value.keys) {
        if (overalluserid.toString() == userids.toString()) {
          checkid = 1;
          databaseReference.child("LOCATIONS").child(overalluserid).update({
            'latitude': latitude,
            'longitude': longitude,
            'Address': address,
            'Country': placemark[0].country,
            'Locality': placemark[0].locality,
            'AdministrativeArea': placemark[0].administrativeArea,
            'PostalCode': placemark[0].postalCode,
            'Name': placemark[0].name,
            'ISO_CountryCode': placemark[0].isoCountryCode,
            'SubLocality': placemark[0].subLocality,
            'SubThoroughfare': placemark[0].subThoroughfare,
            'Thoroughfare': placemark[0].thoroughfare,
          });
        }
      }
    });
    print(checkid);
    if (checkid == 0) {
      databaseReference.child("LOCATIONS").child(overalluserid).set({
        'latitude': latitude,
        'longitude': longitude,
        'Address': address,
        'Country': placemark[0].country,
        'Locality': placemark[0].locality,
        'AdministrativeArea': placemark[0].administrativeArea,
        'PostalCode': placemark[0].postalCode,
        'Name': placemark[0].name,
        'ISO_CountryCode': placemark[0].isoCountryCode,
        'SubLocality': placemark[0].subLocality,
        'SubThoroughfare': placemark[0].subThoroughfare,
        'Thoroughfare': placemark[0].thoroughfare,
      });
    }

    databaseReference.child("CoronaYes").once().then((DataSnapshot snapshot) {
      for (var id in snapshot.value.keys) {
        databaseReference
            .child("LOCATIONS")
            .child(id)
            .once()
            .then((DataSnapshot snapshot) {
          if (snapshot.value != null) {
            // print(snapshot.value['latitude']);
            // print(snapshot.value['longitude']);
            initmarker(
              snapshot.value['latitude'],
              snapshot.value['longitude'],
              id,
            );
          }
        });
      }
    });
  }

  void getAddress(double latitude, double longitude) async {
    placemark = await geolocator.placemarkFromCoordinates(latitude, longitude);

    address =
        placemark[0].name.toString() + "," + placemark[0].locality.toString();
    print('My Address : ' + address);
    updateRecord(latitude, longitude, placemark);
  }

  void getCurrentLocation() async {
    try {
      var location = await _locationTracker.getLocation();
      getAddress(location.latitude, location.longitude);
      updateMarkerAndCircle(location);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged().listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(
            CameraUpdate.newCameraPosition(
              new CameraPosition(
                //bearing: 192.8334901395799,
                target: LatLng(newLocalData.latitude, newLocalData.longitude),
                tilt: 0,
                zoom: 18.00,
              ),
            ),
          );
          updateMarkerAndCircle(newLocalData);
          getAddress(newLocalData.latitude, newLocalData.longitude);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    overalluserid = Provider.of<Auth>(
      context,
      listen: false,
    ).userId;

    return Scaffold(
      body: ClipRRect(
        borderRadius: BorderRadius.circular(28.0),
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: initialLocation,
          markers: Set.from(markers),
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.location_searching,
            color: Colors.white,
          ),
          onPressed: () {
            getCurrentLocation();
          }),
    );
  }
}
