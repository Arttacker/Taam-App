import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taqam/layout/ta2m_layout_screen/ta2m_Layout_screen.dart';
import 'package:taqam/modules/ta2m_Home_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Home_screen/cubit/states.dart';
import 'package:taqam/modules/ta2m_Sell_screen/Sell_screen.dart';
import 'package:taqam/modules/ta2m_Sell_screen/cubit/cubit.dart';
import 'package:taqam/shared/style/color.dart';

import '../../shared/component/componanets.dart';

class ConfirmImageToSellScreen extends StatefulWidget {
  @override
  State<ConfirmImageToSellScreen> createState() => _ConfirmImageToSellScreenState();
}

class _ConfirmImageToSellScreenState extends State<ConfirmImageToSellScreen> {
  bool loadingFlag= true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadingFlag=true;
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = HomeCubit.get(context);
          return Scaffold(
            appBar: AppBar(
              backgroundColor: ColorsManager.mainBackgroundColor,
              leading: IconButton(
                onPressed: () {
                  SellCubit.get(context).sellImage = null;
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
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
                      child: Image.file(SellCubit.get(context).sellImage!,fit: BoxFit.contain,
                      )),
                  Spacer(),
                  ConditionalBuilder(
                    condition: loadingFlag,
                    builder: (context) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                            onPressed: () async{
                              setState(() {
                                loadingFlag=false;
                              });
                              await SellCubit.get(context).uploadPostImage();
                              await cubit.fetchQualityToSell(
                                  SellCubit.get(context).sellImageUrl!);
                              if (cubit.qualityResultToSell == true) {
                                await cubit.fetchProcessImageToSell(
                                    SellCubit.get(context).sellImageUrl!);
                                if (cubit.isFetchProcessImageToSell == true) {
                                  AwesomeDialog(
                                    context: context,
                                    animType: AnimType.leftSlide,
                                    headerAnimationLoop: false,
                                    dialogType: DialogType.success,
                                    showCloseIcon: true,
                                    title: 'Success',
                                    desc:
                                    "Image properties selected successfully!",
                                    btnOkOnPress: () {
                                      Navaigatetofinsh(context, SellScreen());
                                    },
                                    btnOkIcon: Icons.check_circle,
                                    onDismissCallback: (type) {
                                      debugPrint(
                                          'Dialog Dissmiss from callback $type');
                                    },
                                    btnOkColor: ColorsManager.mainColor,
                                  ).show();
                                } else {
                                  AwesomeDialog(
                                    context: context,
                                    animType: AnimType.leftSlide,
                                    headerAnimationLoop: false,
                                    dialogType: DialogType.error,
                                    showCloseIcon: true,
                                    title: 'Error',
                                    desc:
                                        "Failed to process your image please specify the image properties yourself.",
                                    btnOkOnPress: () {
                                      Navaigatetofinsh(context, SellScreen());
                                    },
                                    btnOkIcon: Icons.check_circle,
                                    onDismissCallback: (type) {
                                      debugPrint(
                                          'Dialog Dissmiss from callback $type');
                                    },
                                    btnOkColor: ColorsManager.mainColor,
                                  ).show();
                                }
                              } else {
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
                                    Navaigatetofinsh(
                                        context, Ta2mLayoutScreen());
                                  },
                                  btnOkIcon: Icons.check_circle,
                                  onDismissCallback: (type) {
                                    debugPrint(
                                        'Dialog Dissmiss from callback $type');
                                  },
                                  btnOkColor: ColorsManager.mainColor,
                                ).show();
                              }
                            },
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                            )),
                      );
                    },
                    fallback: (context) => Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Center(
                          child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ColorsManager.mainColor,
                        ),
                      )),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
