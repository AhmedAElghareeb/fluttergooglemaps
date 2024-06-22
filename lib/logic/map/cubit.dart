import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps/data/repo/map_repo.dart';
import 'package:google_maps/logic/map/states.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapCubit extends Cubit<MapStates> {
  final MapRepo mapRepo;

  MapCubit(this.mapRepo) : super(MapStates());

  void emitPlacesSuggestions(String place, String sessionToken) {
    mapRepo
        .getSuggestions(
      place,
      sessionToken,
    )
        .then((suggestions) {
      emit(
        PlacesLoaded(suggestions),
      );
    });
  }

  void emitPlaceLocation(String placeId, String sessionToken) {
    mapRepo
        .getPlaceLocation(
      placeId,
      sessionToken,
    )
        .then((place) {
      emit(
        PlaceDetailsLocationLoaded(place),
      );
    });
  }

  void emitPlaceDirections(LatLng origin, LatLng destination) {
    mapRepo
        .getDirections(
      origin,
      destination,
    )
        .then((directions) {
      emit(
        PlaceDirectionsLoaded(directions),
      );
    });
  }
}
