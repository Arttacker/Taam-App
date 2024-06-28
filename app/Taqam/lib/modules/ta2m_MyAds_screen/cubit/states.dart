abstract class MyAdsState {}

class InitialOtherProfileStateState extends MyAdsState{}

class GetAllMyPostsLoadingState extends MyAdsState{}
class GetAllMyPostsSuccessState extends MyAdsState{}
class GetAllMyPostsErrorState extends MyAdsState{
  final String error;
  GetAllMyPostsErrorState(this.error);
}

class RenewPostLoadingState extends MyAdsState{}
class RenewPostSuccessState extends MyAdsState{}
class RenewPostErrorState extends MyAdsState{}

class DeletePostLoadingState extends MyAdsState{}
class DeletePostSuccessState extends MyAdsState{}
class DeletePostErrorState extends MyAdsState{}

class GarbageState extends MyAdsState{}

class DeleteImagePostDeletedLoadingState extends MyAdsState{}
class DeleteImagePostDeletedSuccessState extends MyAdsState{}
class DeleteImagePostDeletedErrorState extends MyAdsState{}