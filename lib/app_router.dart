import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps/core/consts/strings.dart';
import 'package:google_maps/data/api_call/places.dart';
import 'package:google_maps/data/repo/map_repo.dart';
import 'package:google_maps/logic/map/cubit.dart';
import 'package:google_maps/logic/phone_auth/phone_auth_cubit.dart';
import 'package:google_maps/views/login/view.dart';
import 'package:google_maps/views/map/view.dart';
import 'package:google_maps/views/otp/view.dart';

class AppRouter {
  PhoneAuthCubit? phoneAuthCubit;

  AppRouter() {
    phoneAuthCubit = PhoneAuthCubit();
  }

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginView:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<PhoneAuthCubit>.value(
            value: phoneAuthCubit!,
            child: LoginView(),
          ),
        );
      case otpView:
        final phoneNumber = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<PhoneAuthCubit>.value(
            value: phoneAuthCubit!,
            child: OtpView(phoneNumber: phoneNumber),
          ),
        );
      case mapView:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
              create: (context) => MapCubit(
                    MapRepo(
                      Places(),
                    ),
                  ),
              child: const MapView()),
        );
    }
    return null;
  }
}
