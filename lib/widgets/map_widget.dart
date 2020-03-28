import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';

import '../providers/auth.dart';

class MapWidget extends StatefulWidget {
  final Position userLocation;

  MapWidget({
    @required this.userLocation,
  });

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final databaseReference = FirebaseDatabase.instance.reference();
  Marker _marker;
  GoogleMapController _controller;
  Location _locationTracker = Location();
  Geolocator geolocator = Geolocator();
  StreamSubscription _locationSubscription;
  List<Placemark> placemark;
  String address = "";
  var overalluserid;
  var check = 0;
  List<Marker> markers = [Marker(
    markerId: MarkerId('12345678'),
    position: LatLng(19.231280,73.13849),
    icon: BitmapDescriptor.defaultMarker,
  ),];
  Map<MarkerId, Marker> usersmarkers = <MarkerId, Marker>{};

  @override
  void initState() {
    locateMe().then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    overalluserid = Provider.of<Auth>(
      context,
      listen: false,
    ).userId;
    super.didUpdateWidget(oldWidget);
  }

  void initmarker(double latitude, double longitude, String id) {
    final MarkerId diffuserid = MarkerId(id);
    print(diffuserid.toString());
    final Marker differentuser = Marker(
      markerId: MarkerId(id),
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(title: "Homeeeeeeeeeeee"),
    );
    markers.add(differentuser);
    usersmarkers[diffuserid] = differentuser;
    print(id);
  }

  void updateRecord(
      double latitude, double longitude, List<Placemark> placemark) {
    print("Update record fucntion");
    print(overalluserid);

    int checkid = 0;
    databaseReference.child("LOCATIONS").once().then((DataSnapshot snapshot) {
      print('${snapshot.value.keys}');
      for (var userids in snapshot.value.keys) {
        if (overalluserid == userids) {
          checkid = 1;
          print(check);
        }
      }
    });

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
            initmarker(
                snapshot.value['latitude'], snapshot.value['longitude'], id);
          }
        });
      }
    });

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
    } else {
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

  void getAddress(double latitude, double longitude) async {
    placemark = await geolocator.placemarkFromCoordinates(latitude, longitude);

    address =
        placemark[0].name.toString() + "," + placemark[0].locality.toString();

    updateRecord(latitude, longitude, placemark);
  }

  void updateMarkerAndCircle(LocationData newLocalData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      _marker = Marker(
        markerId: MarkerId("Home"),
        position: latlng,
        rotation: newLocalData.heading,
        draggable: false,
        //zIndex: 2,
        //flat: true,
        anchor: Offset(0.5, 0.5),
        icon: BitmapDescriptor.defaultMarker,
      );
    });
  }

  Future<void> locateMe() async {
    try {
      var location = await _locationTracker.getLocation();
      getAddress(location.latitude, location.longitude);
      await updateMarkerAndCircle(location);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription = _locationTracker.onLocationChanged().listen(
        (newLocalData) {
          if (_controller != null) {
            _controller.animateCamera(
              CameraUpdate.newCameraPosition(
                new CameraPosition(
                  bearing: 192.8334901395799,
                  target: LatLng(newLocalData.latitude, newLocalData.longitude),
                  tilt: 0,
                  zoom: 5.00,
                ),
              ),
            );
            updateMarkerAndCircle(newLocalData);
          }
        },
      );
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //print('User Markers While Building Maps Keys : ${usersmarkers.values}');
    print('Markers List : $markers');
    return Scaffold(
      body: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: GoogleMap(
          mapType: MapType.hybrid,
          buildingsEnabled: true,
          // markers: createMarker(),
          //markers: Set.of((_marker != null) ? [_marker] : []),
          markers: Set.from(markers),
          initialCameraPosition: CameraPosition(
            target: LatLng(
                widget.userLocation.latitude, widget.userLocation.longitude),
            zoom: 5.0,
          ),
          onMapCreated: (GoogleMapController controller) {
            setState(() {
              _controller = controller;
            });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.location_searching,
          color: Colors.white,
        ),
        onPressed: () {
          locateMe();
        },
      ),
    );
  }
}
