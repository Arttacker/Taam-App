import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taqam/models/posture/postModel.dart';
import 'package:taqam/models/structModels/post_and_user/post_and_userModel.dart';
import 'package:taqam/modules/ta2m_Home_screen/cubit/states.dart';
import 'package:http/http.dart' as http;

import '../../../models/user/userModel.dart';
import '../../../shared/component/constans.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(IntialHomeState());

  static HomeCubit get(context) {
    return BlocProvider.of(context);
  }

  bool stateToUpdate = false;

  String? selectedItemCategoryFilter;

  void changeComboBoxCategory(value) {
    selectedItemCategoryFilter = value;
    emit(ChangeComboBoxCategory());
  }

  String? selectedItemGenderFilter;

  void changeComboBoxGender(value) {
    selectedItemGenderFilter = value;
    emit(ChangeComboBoxGender());
  }

  String? selectedItemSeasonFilter;

  void changeComboBoxSeason(value) {
    selectedItemSeasonFilter = value;
    emit(ChangeComboBoxSeason());
  }

  String? selectedItemConditionFilter;

  void changeComboBoxCondition(value) {
    selectedItemConditionFilter = value;
    emit(ChangeComboBoxCondition());
  }

  String? selectedItemSizeFilter;

  void changeComboBoxSize(value) {
    selectedItemSizeFilter = value;
    emit(ChangeComboBoxSize());
  }

  bool selectedLocationFilter = false;

  void changeSelectedLocationFilter() {
    selectedLocationFilter = !selectedLocationFilter;

    emit(ChangeSelectedLocationFilterSuccessStates());
  }

  Color? selectedColorFilter;

  void changeSelectedColorFilter(val) {
    selectedColorFilter = val;

    emit(ChangeSelectedColorFilterSuccessStates());
  }

  int selectedSortByIndex = 0;

  void onSortBySelected(int index) {
    selectedSortByIndex = index;
    emit(ChangeSelectedSortByIndexSuccessStates());
  }

  // Backend (Firebase Storage)
  List<PostAndUserModel> allPostsWithThemUsers = [];
  Map<int, String> sortBy = {
    0: 'category',
    1: 'postDate',
    2: 'price',
    3: 'price',
  };

  Future<void> getAllPosts() async {
    emit(GetAllPostsLoadingState());
    allPostsWithThemUsers.clear();
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((documents) {
      print(documents.size);
      if (documents.size != 0) {
        documents.docs.forEach((user) async {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.id)
              .collection('posts')
              .orderBy('postDate', descending: true)
              .get()
              .then((posts) {
            posts.docs.forEach((post) async {
              await getUserOfPost(postModel: PostModel.fromJson(post.data()));
            });
          }).catchError((error) {
            emit(GetAllPostsErrorState(error.toString()));
          });
        });
      }
      emit(GetAllPostsSuccessState());
    }).catchError((error) {
      emit(GetAllPostsErrorState(error));
    });
  }

  Future<void> sortAllPostsWithThemUsersList() async {
    emit(SortAllPostsWithThemUsersListLoadingState());
    allPostsWithThemUsers.sort((a, b) {
      // Assuming 'category' is a string that can be directly compared
      return b.postModel!.postDate!.compareTo(a.postModel!.postDate!);
    });
    emit(SortAllPostsWithThemUsersListSuccessState());
  }

  Future<void> getUserOfPost({
    required PostModel postModel,
  }) async {
    emit(GetProfileOfPostLoadingState());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(postModel.userId)
        .collection('profile')
        .doc(postModel.userId)
        .get()
        .then((value) {
      UserModel userModel = UserModel.fromJson(value.data()!);
      PostAndUserModel postAndUserModel =
      PostAndUserModel(userModel: userModel, postModel: postModel);
      allPostsWithThemUsers.add(postAndUserModel);
      sortAllPostsWithThemUsersList();
      emit(GetProfileOfPostSuccessState());
    }).catchError((error) {
      emit(GetProfileOfPostErrorState(error));
    });
  }

  Future sortPosts(int index) async {
    emit(SortByLoadingState());
    switch (index) {
      case 0: // Sort by category
        allPostsWithThemUsers.sort((a, b) {
          // Assuming 'category' is a string that can be directly compared
          return a.postModel!.category!.compareTo(b.postModel!.category!);
        });
        emit(SortBySuccessState());
        break;
      case 1: // Sort by post date (newly listed first)
        allPostsWithThemUsers.sort((a, b) {
          // Compare by postDate, assuming it's a Timestamp
          return b.postModel!.postDate!.compareTo(a.postModel!.postDate!);
        });
        emit(SortBySuccessState());
        break;
      case 2: // Sort by lowest price
        allPostsWithThemUsers.sort((a, b) {
          // Compare by price, assuming it's a double
          return a.postModel!.price!.compareTo(b.postModel!.price!);
        });
        emit(SortBySuccessState());
        break;
      case 3: // Sort by highest price
        allPostsWithThemUsers.sort((a, b) {
          // Compare by price, but reverse the order for highest price
          return b.postModel!.price!.compareTo(a.postModel!.price!);
        });
        emit(SortBySuccessState());
        break;
      default:
        print('Invalid index for sorting');
        emit(SortByErrorState());
    }
  }

  Future<void> filterPostAndUserModels({
    String? category,
    String? gender,
    String? season,
    String? condition,
    String? size,
    String? colorName,
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
    double? minPrice,
    double? maxPrice,
  }) async {
    emit(ApplyFilterLoadingState());
    allPostsWithThemUsers.removeWhere((postAndUserModel) {
      bool matchesCategory =
          category == null || postAndUserModel.postModel?.category == category;
      bool matchesGender =
          gender == null || postAndUserModel.postModel?.gender == gender;
      bool matchesSeason =
          season == null || postAndUserModel.postModel?.season == season;
      bool matchesCondition = condition == null ||
          postAndUserModel.postModel?.condition == condition;
      bool matchesSize =
          size == null || postAndUserModel.postModel?.size == size;
      bool matchesColorName =
          colorName == null || postAndUserModel.postModel?.coloredName == colorName;
      bool matchesWidth = (minWidth == null || maxWidth == null) ||
          (postAndUserModel.postModel!.productWidth! >= minWidth &&
              postAndUserModel.postModel!.productWidth! <= maxWidth);
      bool matchesHeight = (minHeight == null || maxHeight == null) ||
          (postAndUserModel.postModel!.productHeight! >= minHeight &&
              postAndUserModel.postModel!.productHeight! <= maxHeight);
      bool matchesPrice = (minPrice == null || maxPrice == null) ||
          (postAndUserModel.postModel!.price! >= minPrice &&
              postAndUserModel.postModel!.price! <= maxPrice);

      return !(matchesCategory &&
          matchesGender &&
          matchesSeason &&
          matchesCondition &&
          matchesSize &&
          matchesColorName &&
          matchesWidth &&
          matchesHeight &&
          matchesPrice);
    });
    emit(ApplyFilterSuccessState());
  }

  bool? qualityResultToSell;
  Future<void> fetchQualityToSell(String imageUrl) async {
    emit(FetchQualityToSellLoadingState());
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
        qualityResultToSell = qualityData['quality'];
      } else if (qualityResponse.statusCode == 422) {
        Map<String, dynamic> qualityData = jsonDecode(qualityResponse.body);
        print(qualityData);
        qualityResultToSell=false;
      }
      emit(FetchQualityToSellSuccessState());
    } catch (e) {
      qualityResultToSell = false;
      print(e.toString());
      emit(FetchQualityToSellErrorState());
    }
  }

// Declare variables outside the function
  String? colorToSell;
  String? colorNameToSell;
  double? widthToSell;
  double? heightToSell;
  String? sizeToSell;
  String? categoryToSell;
  String? genderToSell;
  String? seasonToSell;
  bool isFetchProcessImageToSell = false;
  Future<void> fetchProcessImageToSell(String imageUrl) async {
    emit(FetchProcessImageToSellLoadingState());
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
        colorToSell = processImageData['color'];
        categoryToSell = processImageData['category'];
        genderToSell = processImageData['gender'];
        seasonToSell = processImageData['season'];
        widthToSell = processImageData['width'];
        heightToSell = processImageData['height'];
        sizeToSell = processImageData['size'];
        // Now you can use these variables as needed
        isFetchProcessImageToSell = true;
      } else if (processImageResponse.statusCode == 400) {
        isFetchProcessImageToSell = false;
      }
      emit(FetchProcessImageToSellSuccessState());
    } catch (e) {
      isFetchProcessImageToSell = false;
      print(e.toString());
      emit(FetchProcessImageToSellErrorState());
    }
  }

  Future<void> putSaveImageToSellPost(String imageUrl) async {
    emit(PutSaveImageToSellLoadingState());
    try {
      var putSaveImageResponse = await http.put(
        Uri.parse('http://$APIServerIP:$APIServerPort/save-image'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode({"url": imageUrl,"category": categoryToSell}),
      );

      if (putSaveImageResponse.statusCode == 201) {
        // Request was successful, handle the response data here
        emit(PutSaveImageToSellSuccessState());
      } else {
        emit(PutSaveImageToSellErrorState());
      }
    } catch (e) {
      // An error occurred while making the request, handle it here
      print('Error: $e');
      emit(PutSaveImageToSellErrorState());
    }
  }

}