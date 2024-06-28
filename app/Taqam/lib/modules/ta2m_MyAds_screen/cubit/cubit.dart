import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taqam/models/posture/postModel.dart';
import 'package:taqam/modules/ta2m_MyAds_screen/cubit/states.dart';
import 'package:taqam/shared/component/componanets.dart';

class MyAdsCubit extends Cubit<MyAdsState> {
  MyAdsCubit() : super(InitialOtherProfileStateState());

  static MyAdsCubit get(context) {
    return BlocProvider.of(context);
  }

  List<PostModel> allMyPosts = [];

  Future<void> getAllMyPosts() async {
    emit(GetAllMyPostsLoadingState());
    allMyPosts.clear();
    if (allMyPosts.length == 0) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(UidTokenSave)
          .collection('posts')
          .orderBy('postDate', descending: true)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          allMyPosts.add(PostModel.fromJson(element.data()));
        });
        emit(GetAllMyPostsSuccessState());
      }).catchError((error) {
        emit(GetAllMyPostsErrorState(error.toString()));
      });
    }
  }

  Future<void> renewPost({
    required String userId,
    required String postId,
  }) async {
    emit(RenewPostLoadingState());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('posts')
        .doc(postId)
        .update({
      'postDate': Timestamp.now(),
    }).then((value) {
      emit(RenewPostSuccessState());
    }).catchError((error) {
      emit(RenewPostErrorState());
    });
  }


  Future<void> deletePost({
    required String userId,
    required String postId,
  }) async {
    emit(DeletePostLoadingState());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('posts')
        .doc(postId)
        .delete()
        .then((value) {
      emit(DeletePostSuccessState());
    }).catchError((error) {
      emit(DeletePostErrorState());
    });
  }

  Future<void> deleteImagePostDeleted({
    required String image,
  }) async {
    emit(DeleteImagePostDeletedLoadingState());
    String pathImageInStorage = extractPathFromUrl(image);
    print(pathImageInStorage);
    await FirebaseStorage.instance.ref().child(pathImageInStorage).delete().then((value){
      emit(DeleteImagePostDeletedSuccessState());
    }).catchError((error){
      emit(DeleteImagePostDeletedErrorState());
    });
  }
}
