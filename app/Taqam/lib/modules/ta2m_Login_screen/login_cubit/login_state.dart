part of 'login_cubit.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginPasswordVisibility extends LoginState {
  final bool showPassword;
  LoginPasswordVisibility(this.showPassword);
}

class LoginLoadingState extends LoginState{}
class LoginSuccessState extends LoginState{
  final String uId;
  LoginSuccessState(this.uId);
}
class LoginErrorState extends LoginState{
  final String error;
  LoginErrorState(this.error);
}

class GoogleSignInLoadingState extends LoginState{}
class GoogleSignInSuccessState extends LoginState{
  final String uId;
  GoogleSignInSuccessState(this.uId);
}
class GoogleSignInErrorState extends LoginState{
  final String error;
  GoogleSignInErrorState(this.error);
}

class UserCreateSuccessState extends LoginState{
}
class UserCreateErrorState extends LoginState{
  final String error;
  UserCreateErrorState(this.error);
}

class VerifyEmailSuccessState extends LoginState{}
class VerifyEmailErrorState extends LoginState{}

class ResetEmailSuccessState extends LoginState{}
class ResetEmailErrorState extends LoginState{}
