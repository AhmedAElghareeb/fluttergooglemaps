part of 'phone_auth_cubit.dart';

class PhoneAuthState {}
class PhoneAuthLoading extends PhoneAuthState {}
class PhoneAuthSubmitted extends PhoneAuthState {}
class PhoneAuthVerified extends PhoneAuthState {}
class PhoneAuthError extends PhoneAuthState {
  final String errorMsg;
  PhoneAuthError({required this.errorMsg});
}
