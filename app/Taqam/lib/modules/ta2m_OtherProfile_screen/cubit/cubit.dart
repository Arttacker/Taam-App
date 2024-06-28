import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taqam/models/posture/postModel.dart';
import 'package:taqam/modules/ta2m_OtherProfile_screen/cubit/states.dart';
import 'package:taqam/shared/component/componanets.dart';

class OtherProfileCubit extends Cubit<OtherProfileState> {
  OtherProfileCubit() : super(IntialOtherProfileStateState());

  static OtherProfileCubit get(context) {
    return BlocProvider.of(context);
  }

  List<PostModel> userPosts = [];

  Future<void> getUserPosts({
    required String userId,
  }) async {
    emit(GetUserPostsLoadingState());
    userPosts.clear();
    if (userPosts.length == 0) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('posts')
          .orderBy('postDate', descending: true)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          userPosts.add(PostModel.fromJson(element.data()));
        });
        emit(GetUserPostsSuccessState());
      }).catchError((error) {
        emit(GetUserPostsErrorState(error.toString()));
      });
    }
  }

  Future<void> followUser({
    required String userId,
    required int nFollowers,
  }) async {
    emit(UserFollowingLoadingState());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(UidTokenSave)
        .collection('following')
        .doc(userId)
        .set({
      'follow': true,
    }).then((value) {
      nFollowers++;
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc(userId)
          .update({'NFollowers': nFollowers});
      emit(UserFollowingSuccessState());
    }).catchError((error) {
      emit(UserFollowingErrorState(error.toString()));
    });
  }

  bool isFollowingFlag = false;
  Future<void> followingSearch({
    required String userId,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(UidTokenSave)
        .collection('following')
        .doc(userId)
        .get()
        .then((value) {
          isFollowingFlag = value.get('follow');
      emit(UserFollowingSuccessState());
    }).catchError((error) {
      isFollowingFlag = false;
      emit(UserFollowingErrorState(error.toString()));
    });
  }
}
