import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taqam/modules/ta2m_EditPost_screen/cubit/states.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:taqam/shared/component/componanets.dart';
import 'package:http/http.dart' as http;

import '../../../models/posture/postModel.dart';
import '../../../shared/component/constans.dart';


class EditPostCubit extends Cubit<EditPostState> {
  EditPostCubit() : super(InitialEditPostState());

  static EditPostCubit get(context) {
    return BlocProvider.of(context);
  }

  Color? selectedColorEdit;
  void changeSelectedColorSell(val){
    selectedColorEdit=val;
    emit(ChangeSelectedColorEditSuccessStates());
  }

  File? editPostImage;
  String? editPostImageUrl;

  Future uploadPostImage() async{
    emit(UploadPostImageLoadingState());
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      emit(EditPostConnectivityErrorState());
      return;
    }
    await firebase_storage.FirebaseStorage.instance
        .ref()
        .child('posts/${Uri
        .file(editPostImage!.path)
        .pathSegments
        .last}')
        .putFile(editPostImage!)
        .then((value) async{
      await value.ref.getDownloadURL().then((value) {
        editPostImageUrl = value;
        emit(UploadPostImageSuccessState());
      }).catchError((error) {
        emit(UploadPostImageErrorState());
      });
    }).catchError((error) {
      emit(UploadPostImageErrorState());
    });
  }
  PostModel? postModel;
  Future editPost({
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
    required String coloredName,
  })async{
    emit(EditPostLoadingState());
    // Check internet connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      emit(EditPostConnectivityErrorState());
      return;
    }
    if(editPostImageUrl != null){
      image = editPostImageUrl!;
    }
    postModel = PostModel(
      postId: postId,
      userId: userId,
      price: price,
      color: color,
      image: image,
      season: season,
      postDate: Timestamp.now(),
      condition: condition,
      gender: gender,
      isSold: isSold,
      category: category,
      productHeight: productHeight,
      productWidth: productWidth,
      size: size,
      description: description,
      coloredName: coloredName,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId).collection('posts').doc(postId)
        .update(postModel!.toMap())
        .then((value) {
      emit(EditPostSuccessState());
    }).catchError((error) {
      emit(EditPostErrorState());
    });
  }

  Future<void> deleteImagePostUpdated({
    required String image,
  }) async {
    emit(DeleteImagePostUpdatedLoadingState());
    String pathImageInStorage = extractPathFromUrl(image);
    print(pathImageInStorage);
    await FirebaseStorage.instance.ref().child(pathImageInStorage).delete().then((value){
      emit(DeleteImagePostUpdatedSuccessState());
    }).catchError((error){
      emit(DeleteImagePostUpdatedErrorState());
    });
  }

  bool? qualityResultToUpdated;
  Future<void> fetchQualityToUpdated(String imageUrl) async {
    emit(FetchQualityToUpdatedLoadingState());
    try {
      // POST request for quality
      var qualityResponse = await http.post(
        Uri.parse('http://$APIServerIP:$APIServerPort/quality'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode({"url": imageUrl}),
      );
      // Check if the request was successful (status code 200)
      if (qualityResponse.statusCode == 200) {
        Map<String, dynamic> qualityData = jsonDecode(qualityResponse.body);
        print(qualityData.values);
        qualityResultToUpdated = qualityData['quality'];
        emit(FetchQualityToUpdatedSuccessState());
      } else if (qualityResponse.statusCode == 400) {
        qualityResultToUpdated=false;
        emit(FetchQualityToUpdatedErrorState());
      }
    } catch (e) {
      qualityResultToUpdated = false;
      print(e.toString());
      emit(FetchQualityToUpdatedErrorState());
    }
  }

// Declare variables outside the function
  String? colorToUpdated;
  String? colorNameToUpdated;
  double? widthToUpdated;
  double? heightToUpdated;
  String? sizeToUpdated;
  String? categoryToUpdated;
  String? genderToUpdated;
  String? seasonToUpdated;
  bool isFetchProcessImageToUpdated = false;
  Future<void> fetchProcessImageToUpdated(String imageUrl) async {
    emit(FetchProcessImageToUpdatedLoadingState());
    try {
      // POST request for process image
      var processImageResponse = await http.post(
        Uri.parse('http://$APIServerIP:$APIServerPort/process-image'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode({"url": imageUrl}),
      );
      // Check if the request was successful (status code 200)
      if (processImageResponse.statusCode == 200) {
        Map<String, dynamic> processImageData = jsonDecode(processImageResponse.body);
        // Assign values to the variables
        colorToUpdated = processImageData['color'];
        categoryToUpdated = processImageData['category'];
        genderToUpdated = processImageData['gender'];
        seasonToUpdated = processImageData['season'];
        widthToUpdated = processImageData['width'];
        heightToUpdated = processImageData['height'];
        sizeToUpdated = processImageData['size'];
        isFetchProcessImageToUpdated = true;
        emit(FetchProcessImageToUpdatedSuccessState());
      } else if (processImageResponse.statusCode == 400) {
        isFetchProcessImageToUpdated = false;
        emit(FetchProcessImageToUpdatedErrorState());
      }
    } catch (e) {
      isFetchProcessImageToUpdated = false;
      print(e.toString());
      emit(FetchProcessImageToUpdatedErrorState());
    }
  }

  Future<void> putSaveImageToUpdatedPost(String imageUrl) async {
    emit(PutSaveImageToUpdatedLoadingState());
    try {
      var putSaveImageResponse = await http.post(

        Uri.parse('http://$APIServerIP:$APIServerPort/save-image'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode({"url": imageUrl,"category": categoryToUpdated}),
      );

      if (putSaveImageResponse.statusCode == 201) {
        // Request was successful, handle the response data here
        emit(PutSaveImageToUpdatedSuccessState());
      } else {
        emit(PutSaveImageToUpdatedErrorState());
      }
    } catch (e) {
      // An error occurred while making the request, handle it here
      print('Error: $e');
      emit(PutSaveImageToUpdatedErrorState());
    }
  }

}