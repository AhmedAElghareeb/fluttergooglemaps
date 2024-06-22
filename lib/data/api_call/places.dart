import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps/core/consts/strings.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Places {
  late Dio dio;

  Places() {
    BaseOptions options = BaseOptions(
      connectTimeout: const Duration(
        seconds: 20,
      ),
      receiveTimeout: const Duration(seconds: 20),
      receiveDataWhenStatusError: true,
    );

    dio = Dio(options);
  }

  Future<List<dynamic>> getSuggestions(
      String place, String sessionToken) async {
    try {
      Response response = await dio.get(
        suggestionsBaseUrl,
        queryParameters: {
          'input': place,
          'types': 'address',
          'components': 'country:eg',
          'key': googleAPIKey,
          'sessiontoken': sessionToken,
        },
      );
      if (kDebugMode) {
        print("Response is: ${response.data['predictions']}");
      }
      if (kDebugMode) {
        print("Code of Status: ${response.statusCode}");
      }
      return response.data['predictions'];
    } catch (error) {
      if (kDebugMode) {
        print("Error is: ${error.toString()}");
      }
      return [];
    }
  }

  Future<dynamic> getPlaceLocation(String placeId, String sessionToken) async {
    try {
      Response response = await dio.get(
        placeLocationBaseUrl,
        queryParameters: {
          'place_id': placeId,
          'types': 'geometry',
          'key': googleAPIKey,
          'sessiontoken': sessionToken,
        },
      );
      if (kDebugMode) {
        print("Response is: ${response.data}");
      }
      if (kDebugMode) {
        print("Code of Status: ${response.statusCode}");
      }
      return response.data;
    } catch (error) {
      return Future.error(
        "Place Location Error : ",
        StackTrace.fromString("This is its Trace"),
      );
    }
  }

  Future<dynamic> getDirections(LatLng origin, LatLng destination) async {
    try {
      Response response = await dio.get(
        directionsBaseUrl,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': googleAPIKey,
        },
      );
      if (kDebugMode) {
        print("Response is: ${response.data}");
      }
      if (kDebugMode) {
        print("Code of Status: ${response.statusCode}");
      }
      return response.data;
    } catch (error) {
      return Future.error(
        "Place Location Error : ",
        StackTrace.fromString("This is its Trace"),
      );
    }
  }
}
