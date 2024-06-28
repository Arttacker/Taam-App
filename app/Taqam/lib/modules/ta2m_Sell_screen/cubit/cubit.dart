
import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taqam/modules/ta2m_Sell_screen/cubit/states.dart';
import 'package:taqam/shared/component/componanets.dart';
import 'package:http/http.dart' as http;


import '../../../models/posture/postModel.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SellCubit extends Cubit<SellState> {
  SellCubit() : super(IntialSellState());

  static SellCubit get(context) {
    return BlocProvider.of(context);
  }

  int postId = 0;
  String? selectedItemCategory = 'Top';

  void changeComboBoxCategory(value) {
    selectedItemCategory = value;
    emit(ChangeComboBoxCategory());
  }

  String? selectedItemGender = 'male';

  void changeComboBoxGender(value) {
    selectedItemGender = value;
    emit(ChangeComboBoxGender());
  }

  String? selectedItemSeason = 'summer';

  void changeComboBoxSeason(value) {
    selectedItemSeason = value;
    emit(ChangeComboBoxSeason());
  }

  String? selectedItemCondition = 'Used';

  void changeComboBoxCondition(value) {
    selectedItemCondition = value;
    emit(ChangeComboBoxCondition());
  }

  String? selectedItemSize = 'M';

  void changeComboBoxSize(value) {
    selectedItemSize = value;
    emit(ChangeComboBoxSize());
  }

  Color? selectedColorSell;

  void changeSelectedColorSell(val) {
    selectedColorSell = val;
    emit(ChangeSelectedColorSellSuccessStates());
  }

  PostModel? postModel;

  Future createNewPost({
    required String postId,
    required String userId,
    required double price,
    required String color,
    required String image,
    required String season,
    required Timestamp postDate,
    required String condition,
    required String gender,
    required bool isSold,
    required String category,
    required double productHeight,
    required double productWidth,
    required String size,
    required String description,
    required String colorName,
  }) async {
    emit(CreateNewPostLoadingState());

    postModel = PostModel(
      postId: postId,
      userId: userId,
      price: price,
      color: color,
      image: image,
      season: season,
      postDate: postDate,
      condition: condition,
      gender: gender,
      isSold: isSold,
      category: category,
      productHeight: productHeight,
      productWidth: productWidth,
      size: size,
      description: description,
      coloredName: colorName,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('posts')
        .doc(postId)
        .set(postModel!.toMap())
        .then((value) {
      emit(CreateNewPostSuccessState());
    }).catchError((error) {
      emit(CreateNewPostErrorState(error.toString()));
    });
  }

  File? sellImage;
  String? sellImageUrl;

  Future uploadPostImage() async {
    emit(UploadSellImageLoadingState());
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      emit(SellConnectivityErrorState());
      return;
    }
    var date = DateTime.now();
    try {
      var uploadTask = await firebase_storage.FirebaseStorage.instance
          .ref()
          .child('posts/${Uri.file(sellImage!.path).pathSegments.last}')
          .putFile(sellImage!);
      sellImageUrl = await uploadTask.ref.getDownloadURL();
      emit(UploadSellImageSuccessState());
    } catch (error) {
      emit(UploadSellImageErrorState());
    }
  }

  Future updatePost({
    double? price,
    String? color,
    String? image,
    String? season,
    Timestamp? postDate,
    String? condition,
    String? gender,
    bool? isSold,
    String? category,
    double? productLength,
    double? productWidth,
    String? size,
    String? description,
    String? colorName,
  }) async {
    emit(UpdatePostLoadingState());
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      emit(SellConnectivityErrorState());
      return;
    }
    if (sellImageUrl != null) {
      image = sellImageUrl;
    }
    PostModel model = PostModel(
      price: price ?? postModel!.price,
      color: color ?? postModel!.color,
      image: image ?? postModel!.image,
      season: season ?? postModel!.season,
      postDate: Timestamp.now(),
      condition: condition ?? postModel!.condition,
      gender: gender ?? postModel!.gender,
      isSold: isSold ?? postModel!.isSold,
      category: category ?? postModel!.category,
      productHeight: productLength ?? postModel!.productHeight,
      productWidth: productWidth ?? postModel!.productWidth,
      size: size ?? postModel!.size,
      description: description ?? postModel!.description,
      coloredName: colorName ?? postModel!.coloredName,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(postModel!.userId)
        .collection('posts')
        .doc(postModel!.postId)
        .update(model.toMap())
        .then((value) {
      emit(UpdatePostSuccessState());
    }).catchError((error) {
      emit(UpdatePostErrorState());
    });
  }

  Future<void> getNumberOfPosts() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(UidTokenSave)
        .collection('posts')
        .get()
        .then((value) {
      postId = value.size;
    }).catchError((error) {
      print(error.toString());
    });
  }

  Future<void> deleteImagePostSell({
    required String image,
  }) async {
    emit(DeleteImagePostSellLoadingState());
    String pathImageInStorage = extractPathFromUrl(image);
    print(pathImageInStorage);
    await FirebaseStorage.instance.ref().child(pathImageInStorage).delete().then((value){
      emit(DeleteImagePostSellSuccessState());
    }).catchError((error){
      emit(DeleteImagePostSellErrorState());
    });
  }



}
