import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taqam/models/structModels/post_and_user/post_and_userModel.dart';
import 'package:taqam/modules/ta2m_Search_screen/cubit/states.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../../../shared/component/constans.dart';



class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(IntialSearchState());

  static SearchCubit get(context) {
    return BlocProvider.of(context);
  }

  File? searchImage;
  String searchImageUrl = '';
  var picker =  ImagePicker();

  Future<void> pickImageSearch(ImageSource imageSource) async {
    final pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      searchImage =  File(pickedFile.path);
      emit(SucsessPickImageSearchStates());
    } else {
      emit(ErorrPickImageSearchStates());
    }
  }

  Future uploadImageToSearch() async {
    emit(UploadSearchImageLoadingState());
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      emit(SearchConnectivityErrorState());
      return;
    }
    await firebase_storage.FirebaseStorage.instance
        .ref()
        .child('search/${Uri.file(searchImage!.path).pathSegments.last}')
        .putFile(searchImage!)
        .then((value) async {
      await value.ref.getDownloadURL().then((value) {
        searchImageUrl = value;
        emit(UploadSearchImageSuccessState());
      }).catchError((error) {
        emit(UploadSearchImageErrorState());
      });
    }).catchError((error) {
      emit(UploadSearchImageErrorState());
    });
  }


  bool? qualityResultToSearch;
  Future<void> fetchQualityToSearch(String imageUrl) async {
    try {
      // POST request for quality
      var qualityResponse = await http.post(
        Uri.parse('http://$APIServerIP:$APIServerPort:8000/quality'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode({"url": imageUrl}),
      );
      // Check if the request was successful (status code 200)
      if (qualityResponse.statusCode == 200) {
        Map<String, dynamic> qualityData = jsonDecode(qualityResponse.body);
        print(qualityData.values);
        qualityResultToSearch = qualityData['quality'];
      } else if (qualityResponse.statusCode == 422) {
        Map<String, dynamic> qualityData = jsonDecode(qualityResponse.body);
        print(qualityData);
        qualityResultToSearch=false;
      }
    } catch (e) {
      qualityResultToSearch = false;
      print(e.toString());
    }
  }

  List<String> imagesFromSearch = [];
  bool? isSearchSuccess;
  Future<void> fetchImagesFromSearch(String imageUrl) async {
    try {
      // POST request for search
      var searchResponse = await http.post(
        Uri.parse('http://$APIServerIP:$APIServerPort/search'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode({"url": imageUrl}),
      );
      // Check if the request was successful (status code 200)
      if (searchResponse.statusCode == 200) {
        Map<String, dynamic> searchData = jsonDecode(searchResponse.body);
        print(searchData.values);
        List<dynamic> nearestImagesData = searchData['nearest_images'];
        nearestImagesData.forEach((imageData) {
          imagesFromSearch.add(imageData['url']);
        });
        isSearchSuccess=true;
        print(searchData['nearest_images']);
      } else if (searchResponse.statusCode == 422) {
        Map<String, dynamic> searchData = jsonDecode(searchResponse.body);
        isSearchSuccess=false;
      }
    } catch (e) {
      isSearchSuccess=false;
      print(e.toString());
    }
  }

  List<PostAndUserModel> allPostsFromSearch = [];
  Future<void> searchPostsByImages(List<PostAndUserModel> allPostOfUsersModel)async{
    emit(SearchLoadingState());
    for (var postUserModel in allPostOfUsersModel) {
      // Check if any of the images in the post match any of the images in the provided list
      bool hasMatchingImage =await postUserModel.postModel!.image != null && imagesFromSearch.contains(postUserModel.postModel!.image!);
      if (hasMatchingImage) {
        allPostsFromSearch.add(postUserModel);
        emit(SearchSuccessState());
      }
    }
    emit(SearchSuccessState());
  }

}

