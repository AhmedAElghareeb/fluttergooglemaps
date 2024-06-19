import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps/core/consts/colors.dart';
import 'package:google_maps/core/consts/strings.dart';
import 'package:google_maps/logic/phone_auth/phone_auth_cubit.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

// ignore: must_be_immutable
class OtpView extends StatelessWidget {
  OtpView({super.key, this.phoneNumber});

  final phoneNumber;

  late String otpCode;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 32,
            vertical: 88,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntroTexts(),
              const SizedBox(
                height: 88,
              ),
              _buildPinCodeFields(context),
              const SizedBox(
                height: 60,
              ),
              _buildButton(context),
              _buildPhoneNumberVerifiedBloc(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroTexts() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Verify your phone number",
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            margin: const EdgeInsetsDirectional.symmetric(horizontal: 2),
            child: RichText(
              text: TextSpan(
                text: "Enter your 6 digits code number sent to ",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                      text: "$phoneNumber",
                      style: const TextStyle(
                        color: AppColors.blue,
                      )),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildPinCodeFields(BuildContext appContext) => PinCodeTextField(
        appContext: appContext,
        length: 6,
        autoFocus: true,
        cursorColor: Colors.black,
        keyboardType: TextInputType.number,
        animationType: AnimationType.scale,
        pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(5),
            fieldHeight: 50,
            fieldWidth: 40,
            borderWidth: 1,
            activeColor: AppColors.blue,
            inactiveColor: AppColors.blue,
            inactiveFillColor: Colors.white,
            activeFillColor: AppColors.lightBlue,
            selectedColor: AppColors.blue,
            selectedFillColor: Colors.white),
        animationDuration: const Duration(microseconds: 300),
        backgroundColor: Colors.white,
        enableActiveFill: true,
        onCompleted: (submittedCode) {
          otpCode = submittedCode;
        },
      );

  Widget _buildButton(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerEnd,
        child: ElevatedButton(
          onPressed: () {
            showProgressIndicator(context);
            _verify(context);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(110, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            backgroundColor: Colors.black,
          ),
          child: const Text(
            "Verify",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      );

  _buildPhoneNumberVerifiedBloc() {
    return BlocListener<PhoneAuthCubit, PhoneAuthState>(
      listenWhen: (previous, current) {
        return previous != current;
      },
      listener: (context, state) {
        if (state is PhoneAuthLoading) {
          showProgressIndicator(context);
        }
        if (state is PhoneAuthVerified) {
          Navigator.pop(context);
          Navigator.of(context).pushNamed(otpView, arguments: phoneNumber);
        }
        if (state is PhoneAuthError) {
          String error = (state).errorMsg;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.black,
              duration: const Duration(seconds: 3),
              margin: const EdgeInsetsDirectional.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  void showProgressIndicator(BuildContext context) {
    AlertDialog alertDialog = const AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.black,
          ),
        ),
      ),
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white.withOpacity(0),
      builder: (context) => alertDialog,
    );
  }

  void _verify(BuildContext context) =>
      BlocProvider.of<PhoneAuthCubit>(context).submitOTP(
        otpCode,
      );
}
