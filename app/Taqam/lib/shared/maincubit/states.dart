 abstract class AppState {}

 class IntialAppState extends AppState{}
 class ChangeNavBarSuccessStates extends AppState{}
 class GetAllUsersLoadingState extends AppState {}
 class GetAllUsersSuccessState extends AppState {}
 class GetAllUsersErrorState extends AppState
 {
  final String error;
  GetAllUsersErrorState(this.error);
 }




