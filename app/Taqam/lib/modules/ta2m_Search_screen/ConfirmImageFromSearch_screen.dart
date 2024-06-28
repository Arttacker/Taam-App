import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:taqam/modules/ta2m_Home_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Search_screen/Search_screen.dart';
import 'package:taqam/modules/ta2m_Search_screen/cubit/cubit.dart';
import 'package:taqam/shared/style/color.dart';

import '../../shared/component/componanets.dart';
import 'ProductsSearch_screen.dart';

class ConfirmImageFromSearchScreen extends StatefulWidget {
  const ConfirmImageFromSearchScreen({super.key});

  @override
  State<ConfirmImageFromSearchScreen> createState() => _ConfirmImageFromSearchScreenState();
}

class _ConfirmImageFromSearchScreenState extends State<ConfirmImageFromSearchScreen> {
  bool flagLoading=true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    flagLoading=true;
  }
  @override
  Widget build(BuildContext context) {
    var cubit = SearchCubit.get(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsManager.mainBackgroundColor,
        leading: IconButton(
          onPressed: () {
            cubit.searchImage=null;
            Navigator.pop(context);
          },
          icon:  Icon(Icons.close,color: Theme.of(context).primaryColor,size: 30,),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          right: 16,
          top: 10,
          left: 16,
          bottom: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
                height: MediaQuery.sizeOf(context).height*0.7,
                width: double.infinity,
                child: Image.file(cubit.searchImage!,fit: BoxFit.contain,)),
            Spacer(),
            flagLoading?Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                  onPressed: ()async{
                    setState(() {
                      flagLoading=false;
                    });
                    await cubit.uploadImageToSearch();
                    await cubit.fetchQualityToSearch(cubit.searchImageUrl);
                    if(cubit.qualityResultToSearch == true){
                      await cubit.fetchImagesFromSearch(cubit.searchImageUrl);
                      if(cubit.isSearchSuccess == true){
                        AwesomeDialog(
                          context: context,
                          animType: AnimType.leftSlide,
                          headerAnimationLoop: false,
                          dialogType: DialogType.success,
                          showCloseIcon: true,
                          title: 'Success',
                          desc:
                          "Search by your image successfully!",
                          btnOkOnPress: () async{
                            await cubit.searchPostsByImages(HomeCubit.get(context).allPostsWithThemUsers);
                            Navaigatetofinsh(context,ProductsSearchScreen());
                          },
                          btnOkIcon: Icons.check_circle,
                          onDismissCallback: (type) {
                            debugPrint('Dialog Dissmiss from callback $type');
                          },
                          btnOkColor: ColorsManager.mainColor,
                        ).show();
                      }
                      else{
                        AwesomeDialog(
                          context: context,
                          animType: AnimType.leftSlide,
                          headerAnimationLoop: false,
                          dialogType: DialogType.error,
                          showCloseIcon: true,
                          title: 'Error',
                          desc:
                          "Failed to search please try again.",
                          btnOkOnPress: () {
                            Navaigatetofinsh(context,SearchScreen());
                          },
                          btnOkIcon: Icons.check_circle,
                          onDismissCallback: (type) {
                            debugPrint('Dialog Dissmiss from callback $type');
                          },
                          btnOkColor: ColorsManager.mainColor,
                        ).show();
                      }
                    }
                    else{
                      AwesomeDialog(
                        context: context,
                        animType: AnimType.leftSlide,
                        headerAnimationLoop: false,
                        dialogType: DialogType.error,
                        showCloseIcon: true,
                        title: 'Error',
                        desc:
                        "Quality not suitable please change this image.",
                        btnOkOnPress: () {
                          Navaigatetofinsh(context,SearchScreen());
                        },
                        btnOkIcon: Icons.check_circle,
                        onDismissCallback: (type) {
                          debugPrint('Dialog Dissmiss from callback $type');
                        },
                        btnOkColor: ColorsManager.mainColor,
                      ).show();

                    }
                  },
                  icon: const Icon(Icons.send,color: Colors.white,)
              ),
            ):
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: const Center(child: CircularProgressIndicator(color: ColorsManager.mainColor,),),
            ),
          ],
        ),
      ),
    );
  }
}
