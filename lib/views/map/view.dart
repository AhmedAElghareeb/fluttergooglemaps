import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps/core/consts/colors.dart';
import 'package:google_maps/core/helpers/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {

  //for lat and long
  static Position? position;

  //for map completer
  final Completer<GoogleMapController> _controller = Completer();

  //for camera position
  static final CameraPosition _myCurrentLocation = CameraPosition(
    bearing: 0,
    zoom: 17,
    tilt: 0,
    target: LatLng(
      position!.latitude,
      position!.longitude,
    ),
  );

  //to get current location
  Future<void> getCurrentLocation() async {
    await LocationHelper.getCurrentLocation();

    position = await Geolocator.getLastKnownPosition().whenComplete(() {
      setState(() {});
    });
  }

  //to get current location when app is open
  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  //build map with customize styling
  Widget buildMap() {
    return GoogleMap(
      mapType: MapType.hybrid,
      //circle blue for my location
      myLocationEnabled: true,
      //zoom controls
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      initialCameraPosition: _myCurrentLocation,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }

  //to go to my location
  Future<void> _goToMyLocation() async {
    final GoogleMapController ctrl = await _controller.future;
    ctrl.animateCamera(
      CameraUpdate.newCameraPosition(
        _myCurrentLocation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: Container(
          margin: const EdgeInsetsDirectional.fromSTEB(
            0,
            0,
            8,
            30,
          ),
          child: FloatingActionButton(
            onPressed: _goToMyLocation,
            backgroundColor: AppColors.blue,
            child: const Icon(
              Icons.place,
              color: Colors.white,
            ),
          ),
        ),
        body: Stack(
          children: [
            position != null
                ? buildMap()
                : const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.blue,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
