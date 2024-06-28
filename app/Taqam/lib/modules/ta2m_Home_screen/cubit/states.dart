abstract class HomeState{}
class IntialHomeState extends HomeState{}

class ChangeComboBoxCategory extends HomeState{}
class ChangeComboBoxGender extends HomeState{}
class ChangeComboBoxSeason extends HomeState{}
class ChangeComboBoxCondition extends HomeState{}
class ChangeComboBoxSize extends HomeState{}
class ChangeSelectedLocationFilterSuccessStates extends HomeState{}
class ChangeSelectedColorFilterSuccessStates extends HomeState{}
class ChangeSelectedSortByIndexSuccessStates extends HomeState{}

class GetAllPostsLoadingState extends HomeState{}
class GetAllPostsSuccessState extends HomeState{}
class GetAllPostsErrorState extends HomeState{
  final String error;
  GetAllPostsErrorState(this.error);
}

class GetPostSuccessState extends HomeState{}
class GetUsersErrorState extends HomeState{
  final String error;
  GetUsersErrorState(this.error);
}


class GetProfileOfPostLoadingState extends HomeState{}
class GetProfileOfPostSuccessState extends HomeState{}
class GetProfileOfPostErrorState extends HomeState{
  final String error;
  GetProfileOfPostErrorState(this.error);
}

class SortAllPostsWithThemUsersListLoadingState extends HomeState{}
class SortAllPostsWithThemUsersListSuccessState extends HomeState{}

class SortByLoadingState extends HomeState{}
class SortBySuccessState extends HomeState{}
class SortByErrorState extends HomeState{}

class ApplyFilterLoadingState extends HomeState{}
class ApplyFilterSuccessState extends HomeState{}

class FetchQualityToSellLoadingState extends HomeState{}
class FetchQualityToSellSuccessState extends HomeState{}
class FetchQualityToSellErrorState extends HomeState{}

class FetchProcessImageToSellLoadingState extends HomeState{}
class FetchProcessImageToSellSuccessState extends HomeState{}
class FetchProcessImageToSellErrorState extends HomeState{}

class FetchSizeToSellLoadingState extends HomeState{}
class FetchSizeToSellSuccessState extends HomeState{}
class FetchSizeToSellErrorState extends HomeState{}

class PutSaveImageToSellLoadingState extends HomeState{}
class PutSaveImageToSellSuccessState extends HomeState{}
class PutSaveImageToSellErrorState extends HomeState{}

