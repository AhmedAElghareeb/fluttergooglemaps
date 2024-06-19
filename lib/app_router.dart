import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps/core/consts/strings.dart';
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
          builder: (_) => const MapView(),
        );
    }
  }
}
