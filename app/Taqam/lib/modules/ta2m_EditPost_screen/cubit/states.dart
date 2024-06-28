abstract class EditPostState {}

class InitialEditPostState extends EditPostState{}

class ChangeSelectedColorEditSuccessStates extends EditPostState{}

class SuccessPickImageEditPostStates extends EditPostState{}
class ErrorPickImageEditPostStates extends EditPostState{}

class UploadPostImageLoadingState extends EditPostState{}
class UploadPostImageSuccessState extends EditPostState{}
class UploadPostImageErrorState extends EditPostState{}

class EditPostLoadingState extends EditPostState{}
class EditPostSuccessState extends EditPostState{}
class EditPostErrorState extends EditPostState{}

class EditPostConnectivityErrorState extends EditPostState{}

class DeleteImagePostUpdatedLoadingState extends EditPostState{}
class DeleteImagePostUpdatedSuccessState extends EditPostState{}
class DeleteImagePostUpdatedErrorState extends EditPostState{}

class FetchQualityToUpdatedLoadingState extends EditPostState{}
class FetchQualityToUpdatedSuccessState extends EditPostState{}
class FetchQualityToUpdatedErrorState extends EditPostState{}
class FetchProcessImageToUpdatedLoadingState extends EditPostState{}
class FetchProcessImageToUpdatedSuccessState extends EditPostState{}
class FetchProcessImageToUpdatedErrorState extends EditPostState{}
class FetchSizeToUpdatedLoadingState extends EditPostState{}
class FetchSizeToUpdatedSuccessState extends EditPostState{}
class FetchSizeToUpdatedErrorState extends EditPostState{}


class PutSaveImageToUpdatedLoadingState extends EditPostState{}
class PutSaveImageToUpdatedSuccessState extends EditPostState{}
class PutSaveImageToUpdatedErrorState extends EditPostState{}
