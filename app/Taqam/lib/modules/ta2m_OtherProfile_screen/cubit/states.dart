abstract class OtherProfileState {}

class IntialOtherProfileStateState extends OtherProfileState{}

class GetUserPostsLoadingState extends OtherProfileState{}
class GetUserPostsSuccessState extends OtherProfileState{}
class GetUserPostsErrorState extends OtherProfileState{
  final String error;
  GetUserPostsErrorState(this.error);
}

class UserFollowingLoadingState extends OtherProfileState{}
class UserFollowingSuccessState extends OtherProfileState{}
class UserFollowingErrorState extends OtherProfileState{
  final String error;
  UserFollowingErrorState(this.error);
}