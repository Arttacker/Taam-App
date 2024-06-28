abstract class AccountState{}
class IntialAccountState extends AccountState{}
class SuccessPickImageProfileStates extends AccountState{}
class ErrorPickImageProfileStates extends AccountState{}
class SignOutSuccessState extends AccountState{}
class SignOutErrorState extends AccountState{
  final String error;
  SignOutErrorState(this.error);
}
class GoogleSignOutSuccessState extends AccountState{}
class GoogleSignOutErrorState extends AccountState{
  final String error;
  GoogleSignOutErrorState(this.error);
}
class GetUserLoadingState extends AccountState{}
class GetUserSuccessState extends AccountState{}
class GetUserErrorState extends AccountState{
  final String error;
  GetUserErrorState(this.error);
}
class UpdateUserLoadingState extends AccountState{}
class UpdateUserSuccessState extends AccountState{}
class UpdateUserErrorState extends AccountState{}

class UpdateLastSeenSuccessState extends AccountState{}
class UpdateLastSeenErrorState extends AccountState{}

class UploadProfileImageLoadingState extends AccountState{}
class UploadProfileImageSuccessState extends AccountState{}
class UploadProfileImageErrorState extends AccountState{}

class ConnectivityErrorState extends AccountState{}