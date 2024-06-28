part of 'register_cubit.dart';

@immutable
abstract class RegisterState {}

class RegisterInitial extends RegisterState {}
class RegisterPasswordVisibility extends RegisterState {
  final bool showPassword;
  RegisterPasswordVisibility(this.showPassword);
}
class CheckBoxSuccess extends RegisterState {}

class RegisterLoadingState extends RegisterState{}
class RegisterSuccessState extends RegisterState{}
class RegisterErrorState extends RegisterState{
  final String error;
  RegisterErrorState(this.error);
}
class UserCreateSuccessState extends RegisterState{
}
class UserCreateErrorState extends RegisterState{
  final String error;
  UserCreateErrorState(this.error);
}

