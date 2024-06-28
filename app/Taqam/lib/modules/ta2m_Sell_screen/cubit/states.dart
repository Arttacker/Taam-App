abstract class SellState{}
class IntialSellState extends SellState{}
class SuccessPickImageSellStates extends SellState{}
class ErrorPickImageSellStates extends SellState{}

class ChangeComboBoxCategory extends SellState{}
class ChangeComboBoxGender extends SellState{}
class ChangeComboBoxSeason extends SellState{}
class ChangeComboBoxCondition extends SellState{}
class ChangeComboBoxSize extends SellState{}

class ChangeSelectedColorSellSuccessStates extends SellState{}

class CreateNewPostLoadingState extends SellState{}
class CreateNewPostSuccessState extends SellState{}
class CreateNewPostErrorState extends SellState{
  final String error;
  CreateNewPostErrorState(this.error);
}

class UploadSellImageLoadingState extends SellState{}
class UploadSellImageSuccessState extends SellState{}
class UploadSellImageErrorState extends SellState{}

class UpdatePostLoadingState extends SellState{}
class UpdatePostSuccessState extends SellState{}
class UpdatePostErrorState extends SellState{}

class SellConnectivityErrorState extends SellState{}

class DeleteImagePostSellLoadingState extends SellState{}
class DeleteImagePostSellSuccessState extends SellState{}
class DeleteImagePostSellErrorState extends SellState{}



