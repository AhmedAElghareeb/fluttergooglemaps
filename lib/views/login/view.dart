import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps/core/consts/colors.dart';
import 'package:google_maps/core/consts/strings.dart';
import 'package:google_maps/logic/phone_auth/phone_auth_cubit.dart';

// ignore: must_be_immutable
class LoginView extends StatelessWidget {
  LoginView({super.key});

  late String phoneNumber;

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 32,
              vertical: 88,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntroTexts(),
                const SizedBox(
                  height: 110,
                ),
                _buildPhoneFormField(),
                const SizedBox(
                  height: 60,
                ),
                _buildButton(context),
                _buildPhoneNumberSubmittedBloc(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroTexts() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What is your phone number?",
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
            child: const Text(
              "Please Enter Your Phone Number To Verify Your Account",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
        ],
      );

  Widget _buildPhoneFormField() => Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.lightGrey,
                ),
              ),
              child: Text(
                "${generateCountryFlag()} +20",
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 12,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.blue,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextFormField(
                autofocus: true,
                onTapOutside: (ev) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 2,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                cursorColor: Colors.black,
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Please Enter Phone Number";
                  } else if (val.length < 11) {
                    return "Phone Number Must be at least 11 digits";
                  }
                  return null;
                },
                onSaved: (value) {
                  phoneNumber = value!;
                },
              ),
            ),
          ),
        ],
      );

  String generateCountryFlag() {
    String countryCode = "eg";
    String flag = countryCode.toUpperCase().replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) =>
              String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
        );
    return flag;
  }

  Widget _buildButton(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerEnd,
        child: ElevatedButton(
          onPressed: () {
            showProgressIndicator(context);
            _login(context);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(110, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            backgroundColor: Colors.black,
          ),
          child: const Text(
            "Next",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      );

  Widget _buildPhoneNumberSubmittedBloc() {
    return BlocListener<PhoneAuthCubit, PhoneAuthState>(
      listenWhen: (previous, current) {
        return previous != current;
      },
      listener: (context, state) {
        if (state is PhoneAuthLoading) {
          showProgressIndicator(context);
        }
        if (state is PhoneAuthSubmitted) {
          Navigator.pop(context);
          Navigator.of(context).pushNamed(otpView, arguments: phoneNumber);
        }
        if (state is PhoneAuthError) {
          Navigator.pop(context);
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

  void _login(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      Navigator.pop(context);
      return;
    } else {
      Navigator.pop(context);
      formKey.currentState!.save();
      BlocProvider.of<PhoneAuthCubit>(context).submitPhoneNumber(
        phoneNumber,
      );
    }
  }
}
