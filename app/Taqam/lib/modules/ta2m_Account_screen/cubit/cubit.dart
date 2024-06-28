import 'dart:io';
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taqam/modules/ta2m_Account_screen/cubit/states.dart';

import '../../../models/user/userModel.dart';
import '../../../shared/component/componanets.dart';
import '../../../shared/network/local/Cash_helper.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class AccountCubit extends Cubit<AccountState> {
  AccountCubit() : super(IntialAccountState());

  static AccountCubit get(context) => BlocProvider.of(context);



  String ? selectedItemGenderProfile='Male';
  void changeComboBoxGenderProfile(value)
  {
    selectedItemGenderProfile = value;
  }

  Future SignOut({
    required String key,
    required BuildContext context,
    required Widget widget,
  })async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      emit(ConnectivityErrorState());
      return;
    }
    await FirebaseAuth.instance.signOut().then((value){
      CashHelper.cleardata(key: key).then((value){
        if(value!){
          Navaigatetofinsh(context, widget);
        }
      });
      profileImage = null;
      profileImageURL = null;
      emit(SignOutSuccessState());
    }).catchError((error){
      emit(SignOutErrorState(error.toString()));
    });
    await GoogleSignIn().signOut().then((value){
      emit(GoogleSignOutSuccessState());
    }).catchError((error){
      emit(GoogleSignOutErrorState(error.toString()));
    });
  }

  UserModel? userModel;
  Future getUserData() async {
    emit(GetUserLoadingState());
    await FirebaseFirestore.instance.collection('users').doc(UidTokenSave).collection('profile').doc(UidTokenSave)
        .get()
        .then((value){
        userModel = UserModel.fromJson(value.data()!);
        emit(GetUserSuccessState());
    }).catchError((error) {
      emit(GetUserErrorState(error));
    });
  }

  String? profileImageURL;
  Future updateUser({
    String? fName,
    String? lName,
    String? gender,
    String? image,
    int? age,
    double? height,
    double? weight,
    int? NFollowers,
    String? phone,
    String? town,
    String? city,
    bool? isAdmin,
  })async{
    emit(UpdateUserLoadingState());
    // Check internet connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      emit(ConnectivityErrorState());
      return;
    }
    if(profileImageURL != null){
      image = profileImageURL;
    }
    UserModel model = UserModel(
        fName: fName ?? userModel!.fName,
        lName: lName ?? userModel!.lName,
        gender: gender ?? userModel!.gender,
        image: image ?? userModel!.image,
        age: age ?? userModel!.age,
        height: height ?? userModel!.height,
        weight: weight ?? userModel!.weight,
        NFollowers: NFollowers ?? userModel!.NFollowers,
        phone: phone ?? userModel!.phone,
        town: town ?? userModel!.town,
        city: city ?? userModel!.city,
        isAdmin: isAdmin ?? userModel!.isAdmin,
        registrationDate: userModel!.registrationDate,
        lastSeen: Timestamp.now(),
        email: userModel!.email,
        password: userModel!.password,
        userId: userModel!.userId,
        );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.userId).collection('profile').doc(userModel!.userId)
        .update(model.toMap())
        .then((value) {
      getUserData();
      emit(UpdateUserSuccessState());
    }).catchError((error) {
      emit(UpdateUserErrorState());
    });
  }

  Timestamp? lastSeen;
  Future updateLastSeen()async{
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.userId).collection('profile').doc(userModel!.userId)
        .update({'lastSeen' : Timestamp.now()})
        .then((value) {
          lastSeen = Timestamp.now();
      emit(UpdateLastSeenSuccessState());
    }).catchError((error) {
      emit(UpdateLastSeenErrorState());
    });
  }



  File? profileImage;
  Future uploadProfileImage() async{
    emit(UploadProfileImageLoadingState());
    await firebase_storage.FirebaseStorage.instance
        .ref()
        .child('users/${Uri
        .file(profileImage!.path)
        .pathSegments
        .last}')
        .putFile(profileImage!)
        .then((value) async{
      await value.ref.getDownloadURL().then((value) {
        profileImageURL = value;
        emit(UploadProfileImageSuccessState());
      }).catchError((error) {
        emit(UploadProfileImageErrorState());
      });
    }).catchError((error) {
      emit(UploadProfileImageErrorState());
    });
  }




}