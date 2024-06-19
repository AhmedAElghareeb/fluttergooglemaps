import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'phone_auth_state.dart';

class PhoneAuthCubit extends Cubit<PhoneAuthState> {
  late String verificationId;

  PhoneAuthCubit() : super(PhoneAuthState());

  Future<void> submitPhoneNumber(String phoneNumber) async {
    emit(PhoneAuthLoading());

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+2$phoneNumber",
      timeout: const Duration(seconds: 14),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  void verificationCompleted(PhoneAuthCredential credential) async {
    if (kDebugMode) {
      print('verificationCompleted');
    }
    await signIn(credential);
  }

  void verificationFailed(FirebaseAuthException error) {
    if (kDebugMode) {
      print('verificationFailed : ${error.toString()}');
    }
    emit(
      PhoneAuthError(
        errorMsg: error.toString(),
      ),
    );
  }

  void codeSent(String verificationId, int? resendToken) {
    if (kDebugMode) {
      print('codeSent');
    }
    this.verificationId = verificationId;
    emit(
      PhoneAuthSubmitted(),
    );
  }

  void codeAutoRetrievalTimeout(String verificationId) {
    if (kDebugMode) {
      print('codeAutoRetrievalTimeout');
    }
  }

  Future<void> submitOTP(String otpCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: this.verificationId,
      smsCode: otpCode,
    );
    await signIn(credential);
  }

  Future<void> signIn(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      emit(PhoneAuthVerified());
    } catch (error) {
      emit(
        PhoneAuthError(
          errorMsg: error.toString(),
        ),
      );
    }
  }

  User getLoggedInUser() {
    User firebaseUser = FirebaseAuth.instance.currentUser!;
    return firebaseUser;
  }

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
