
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taqam/modules/ta2m_Account_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Home_screen/ConfirmImageToSell_home_screen.dart';
import 'package:taqam/modules/ta2m_Home_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_MyAds_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_OtherProfile_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_chats_module/api/apis.dart';
import 'package:taqam/shared/style/color.dart';
import '../../modules/ta2m_Sell_screen/ConfirmImageUpdated_sell_screen.dart';
import '../../modules/ta2m_Sell_screen/cubit/cubit.dart';
import '../../shared/component/componanets.dart';
import '../../shared/maincubit/cubit.dart';
import '../../shared/maincubit/states.dart';

import '../../shared/style/my_flutter_app_icons.dart';



class Ta2mLayoutScreen extends StatefulWidget {
  const Ta2mLayoutScreen({super.key});

  @override
  State<Ta2mLayoutScreen> createState() => _Ta2mLayoutScreenState();
}

class _Ta2mLayoutScreenState extends State<Ta2mLayoutScreen> {

  @override
  void initState(){
    // AccountCubit.get(context).getUserData();
    // MyAdsCubit.get(context).getAllMyPosts();
    // AppCubit.get(context).getAllUsers();
    // HomeCubit.get(context).getAllPosts();
    getUserModel();
    AccountCubit.get(context).getUserData();

    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (userModel != null) {
        if (message.toString().contains('resume')) {
          updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppState>(
      listener: (context , state){},
      builder: (context , state){
        var cubit = AppCubit.get(context);
        return Scaffold(
          body: cubit.screens[cubit.curentindex],
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: cubit.curentindex,
            type: BottomNavigationBarType.fixed,
            unselectedItemColor: Colors.grey[800],
            selectedItemColor: ColorsManager.mainColor,
            iconSize: 50,
            unselectedFontSize: 0,
            selectedFontSize: 0,
            onTap: (index) {
              if (index == 2) {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    alignment: const Alignment(0,0.8),
                    children: [
                      SimpleDialogOption(
                        onPressed: () async {
                          SellCubit.get(context).sellImage=null;
                          final ImagePicker picker = ImagePicker();
                          // Pick an image
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera, imageQuality: 50);
                          if (image != null) {
                            SellCubit.get(context).sellImage = File(image.path);
                            Navaigateto(context, ConfirmImageToSellScreen());
                          }
                          else{
                          }
                        },
                        child: Row(
                          children: [
                            Icon(Icons.camera_alt_rounded,color: Theme.of(context).primaryColor,size: 30,),
                            const Padding(
                              padding: EdgeInsets.all(7.0),
                              child: Text(
                                'Camera',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      SimpleDialogOption(
                        onPressed: () async {
                          SellCubit.get(context).sellImage=null;
                          final ImagePicker picker = ImagePicker();
                          // Pick an image
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery, imageQuality: 50);
                          if (image != null) {
                            SellCubit.get(context).sellImage = File(image.path);
                            Navaigateto(context, ConfirmImageToSellScreen());
                          }
                          else{
                          }
                        },
                        child: Row(
                          children: [
                            Icon(Icons.image,color: Theme.of(context).primaryColor,size: 30,),
                            const Padding(
                              padding: EdgeInsets.all(7.0),
                              child: Text(
                                'Gallery',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                cubit.changNavBar(index);
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(MyFlutterApp.home), label: ''),
              BottomNavigationBarItem(icon: Icon(MyFlutterApp.chat), label: ''),
              BottomNavigationBarItem(icon: Icon(MyFlutterApp.sell), label: ''),
              BottomNavigationBarItem(icon: Icon(MyFlutterApp.ads), label: ''),
              BottomNavigationBarItem(icon: Icon(MyFlutterApp.profile), label: ''),
            ],
          ),
        );


      },

    );
  }
}

