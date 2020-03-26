import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

class MapWidget extends StatefulWidget {
  final Position userLocation;

  MapWidget({
    @required this.userLocation,
  });

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  Marker _marker;
  GoogleMapController _controller;
  Location _locationTracker = Location();
  StreamSubscription _locationSubscription;

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

  void locateMe() async {
    try {
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location);

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
                  zoom: 18.00,
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
  void initState() {
    locateMe();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: GoogleMap(
          mapType: MapType.normal,
          // markers: createMarker(),
          markers: Set.of((_marker != null) ? [_marker] : []),
          initialCameraPosition: CameraPosition(
            target: LatLng(
                widget.userLocation.latitude, widget.userLocation.longitude),
            zoom: 12.0,
          ),
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
          locateMe();
        },
      ),
    );
  }
}
