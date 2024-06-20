import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps/core/consts/colors.dart';
import 'package:google_maps/core/helpers/location.dart';
import 'package:google_maps/views/map/widgets/side_drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  //search ctrl
  FloatingSearchBarController controller = FloatingSearchBarController();

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

  //search bar
  Widget buildSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return FloatingSearchBar(
      controller: controller,
      elevation: 6,
      hintStyle: const TextStyle(fontSize: 18),
      queryStyle: const TextStyle(fontSize: 18),
      hint: 'Find a place..',
      border: const BorderSide(style: BorderStyle.none),
      margins: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 52,
      iconColor: AppColors.blue,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 600),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {},
      onFocusChanged: (_) {},
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: Icon(Icons.place, color: Colors.black.withOpacity(0.6)),
            onPressed: () {},
          ),
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: SideDrawer(),
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
          fit: StackFit.expand,
          children: [
            position != null
                ? buildMap()
                : const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.blue,
                    ),
                  ),
            buildSearchBar(),
          ],
        ),
      ),
    );
  }
}
