import 'package:google_maps/data/api_call/places.dart';
import 'package:google_maps/data/models/place.dart';
import 'package:google_maps/data/models/place_suggestions.dart';

class MapRepo {
  final Places places;

  MapRepo(this.places);

  Future<List<dynamic>> getSuggestions(
      String place, String sessionToken) async {
    final suggestions = await places.getSuggestions(
      place,
      sessionToken,
    );
    return suggestions
        .map((suggest) => PlaceSuggestions.fromJson(suggest))
        .toList();
  }

  Future<PlaceDetails> getPlaceLocation(
      String placeId, String sessionToken) async {
    final placeDetails = await places.getPlaceLocation(
      placeId,
      sessionToken,
    );
    return PlaceDetails.fromJson(placeDetails);
  }
}
