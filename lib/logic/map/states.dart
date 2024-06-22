
import 'package:google_maps/data/models/place.dart';

class MapStates {}

class PlacesLoaded extends MapStates {
  final List<dynamic> places;

  PlacesLoaded(this.places);
}

class PlaceDetailsLocationLoaded extends MapStates {
  final PlaceDetails placeDetails;

  PlaceDetailsLocationLoaded(this.placeDetails);
}