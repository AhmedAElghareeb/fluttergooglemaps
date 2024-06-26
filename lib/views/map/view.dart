import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps/core/consts/colors.dart';
import 'package:google_maps/core/helpers/location.dart';
import 'package:google_maps/data/models/directions.dart';
import 'package:google_maps/data/models/place.dart';
import 'package:google_maps/data/models/place_suggestions.dart';
import 'package:google_maps/logic/map/cubit.dart';
import 'package:google_maps/logic/map/states.dart';
import 'package:google_maps/views/map/widgets/distance_and_time.dart';
import 'package:google_maps/views/map/widgets/place_item.dart';
import 'package:google_maps/views/map/widgets/side_drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:uuid/uuid.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  List<dynamic> places = [];

  //variables for getPlaceLocation
  Set<Marker> markers = {};
  late PlaceSuggestions placeSuggestions;
  late PlaceDetails selectedPlace;
  late Marker searchedPlaceMarker;
  late Marker currentLocationMarker;
  late CameraPosition goToSearchedForPlace;

  //variables for directions
  PlaceDirections? placeDirections;
  var progressIndicator = false;
  late List<LatLng> polyLinePoints;
  var isSearchedPlaceMarkerClicked = false;
  var isTimeAndDistanceVisible = false;
  late String time;
  late String distance;

  void buildNewCameraPosition() {
    goToSearchedForPlace = CameraPosition(
      bearing: 0,
      tilt: 0,
      target: LatLng(
        selectedPlace.result.geometry.location.lat,
        selectedPlace.result.geometry.location.lng,
      ),
      zoom: 12,
    );
  }

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
      markers: markers,
      initialCameraPosition: _myCurrentLocation,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      polylines: placeDirections != null
          ? {
              Polyline(
                polylineId: const PolylineId("First"),
                color: AppColors.blue,
                width: 5,
                points: polyLinePoints,
              ),
            }
          : {},
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
      margins: const EdgeInsetsDirectional.fromSTEB(20, 30, 20, 0),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
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
      progress: progressIndicator,
      onQueryChanged: (query) {
        getPlacesSuggestions(query);
      },
      onFocusChanged: (_) {
        //hide distance and time row
        setState(() {
          isTimeAndDistanceVisible = false;
        });
      },
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildPlacesListBloc(),
              buildPlaceDetailsBloc(),
              buildDirectionsBloc(),
            ],
          ),
        );
      },
    );
  }

  Widget buildDirectionsBloc() {
    return BlocListener<MapCubit, MapStates>(
      listener: (context, state) {
        if (state is PlaceDirectionsLoaded) {
          placeDirections = state.placeDirections;
          getPolyLinePoints();
        }
      },
      child: const SizedBox(),
    );
  }

  void getPolyLinePoints() {
    polyLinePoints = placeDirections!.polyLinePoints
        .map(
          (e) => LatLng(
            e.latitude,
            e.longitude,
          ),
        )
        .toList();
  }

  Widget buildPlacesListBloc() {
    return BlocBuilder<MapCubit, MapStates>(
      builder: (context, state) {
        if (state is PlacesLoaded) {
          places = state.places;

          if (places.isNotEmpty) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) => InkWell(
                onTap: () async {
                  placeSuggestions = places[index];
                  controller.close();
                  getSelectedPlaceLocation();
                  polyLinePoints.clear();
                  removeAllMarkersAndUpdateUi();
                },
                child: PlaceItem(
                  suggestions: places[index],
                ),
              ),
              itemCount: places.length,
            );
          } else {
            return const SizedBox();
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }

  void removeAllMarkersAndUpdateUi() {
    setState(() {
      markers.clear();
    });
  }

  Widget buildPlaceDetailsBloc() {
    return BlocListener<MapCubit, MapStates>(
      listener: (context, state) {
        if (state is PlaceDetailsLocationLoaded) {
          selectedPlace = state.placeDetails;
          goToMySearchedLocation();
          getDirections();
        }
      },
      child: const SizedBox(),
    );
  }

  void getDirections() {
    BlocProvider.of<MapCubit>(context).emitPlaceDirections(
      LatLng(
        position!.latitude,
        position!.longitude,
      ),
      LatLng(
        selectedPlace.result.geometry.location.lat,
        selectedPlace.result.geometry.location.lng,
      ),
    );
  }

  Future<void> goToMySearchedLocation() async {
    buildNewCameraPosition();
    final GoogleMapController ctrll = await _controller.future;
    ctrll.animateCamera(
      CameraUpdate.newCameraPosition(goToSearchedForPlace),
    );
    showSearchedPlaceMarker();
  }

  void showSearchedPlaceMarker() {
    searchedPlaceMarker = Marker(
      position: goToSearchedForPlace.target,
      onTap: () {
        showSelectedPlaceDetailsAndMarker();
        //show Time and Distance
        setState(() {
          isSearchedPlaceMarkerClicked = true;
          isTimeAndDistanceVisible = true;
        });
      },
      infoWindow: InfoWindow(
        title: placeSuggestions.description,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      ),
      markerId: const MarkerId("2"),
    );
    addMarkerToMarkersAndUpdateUi(searchedPlaceMarker);
  }

  void showSelectedPlaceDetailsAndMarker() {
    currentLocationMarker = Marker(
      position: LatLng(
        position!.latitude,
        position!.longitude,
      ),
      onTap: () {},
      infoWindow: const InfoWindow(
        title: "Your Current Location",
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
      markerId: const MarkerId("1"),
    );
    addMarkerToMarkersAndUpdateUi(currentLocationMarker);
  }

  void addMarkerToMarkersAndUpdateUi(Marker marker) {
    markers.add(marker);
    setState(() {});
  }

  void getSelectedPlaceLocation() {
    final sessionToken = const Uuid().v4();
    BlocProvider.of<MapCubit>(context).emitPlaceLocation(
      placeSuggestions.placeId,
      sessionToken,
    );
  }

  void getPlacesSuggestions(String query) {
    final sessionToken = const Uuid().v4();
    BlocProvider.of<MapCubit>(context).emitPlacesSuggestions(
      query,
      sessionToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: SideDrawer(),
        floatingActionButton: Container(
          margin: const EdgeInsetsDirectional.fromSTEB(35, 0, 0, 1),
          child: Align(
            alignment: AlignmentDirectional.bottomStart,
            child: FloatingActionButton(
              onPressed: _goToMyLocation,
              backgroundColor: AppColors.blue,
              child: const Icon(Icons.place, color: Colors.white),
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
            isSearchedPlaceMarkerClicked
                ? DistanceAndTime(
                    isTimeAndDistanceVisible: isTimeAndDistanceVisible,
                    placeDirections: placeDirections,
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
