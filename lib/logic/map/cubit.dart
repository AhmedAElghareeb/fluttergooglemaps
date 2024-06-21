import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps/data/repo/map_repo.dart';
import 'package:google_maps/logic/map/states.dart';

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
}
