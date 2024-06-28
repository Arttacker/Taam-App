
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taqam/models/user/userModel.dart';
// import 'package:taqam/modules/chat_module/screens/splash_screen.dart';
import 'package:taqam/modules/ta2m_Account_screen/Account_screen.dart';
import 'package:taqam/modules/ta2m_Chats_screen/Chats_screen.dart';
import 'package:taqam/modules/ta2m_Home_screen/Home_screen.dart';
import 'package:taqam/modules/ta2m_MyAds_screen/MyAds_screen.dart';
import 'package:taqam/modules/ta2m_Sell_screen/Sell_screen.dart';
import 'package:taqam/modules/ta2m_chats_module/screens/my_chats_screen.dart';
import 'package:taqam/shared/maincubit/states.dart';

import '../network/local/Cash_helper.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(IntialAppState());

  static AppCubit get(context) => BlocProvider.of(context);

  int curentindex = 0;

  List<Widget> screens = [
   const HomeScreen(),
    MyChatsScreen(),
     SellScreen(),
    const MyAdsScreen(),
     AccountScreen(),
  ];

  void changNavBar(index) {
    curentindex = index;
    emit(ChangeNavBarSuccessStates());
  }

}
