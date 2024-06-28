import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taqam/modules/ta2m_EditPost_screen/EditPost_Screen.dart';
import 'package:taqam/modules/ta2m_EditPost_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_EditPost_screen/cubit/states.dart';
import 'package:taqam/shared/style/color.dart';

import '../../models/posture/postModel.dart';
import '../../shared/component/componanets.dart';

class ConfirmImageUpdatedScreen_Edit extends StatefulWidget {
  final PostModel postModel;
  final int index;
  ConfirmImageUpdatedScreen_Edit(this.postModel,this.index);

  @override
  State<ConfirmImageUpdatedScreen_Edit> createState() => _ConfirmImageUpdatedScreen_EditState();
}

class _ConfirmImageUpdatedScreen_EditState extends State<ConfirmImageUpdatedScreen_Edit> {
  bool loadingFlag= true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadingFlag=true;
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditPostCubit, EditPostState>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = EditPostCubit.get(context);
          return Scaffold(
            appBar: AppBar(
              backgroundColor: ColorsManager.mainBackgroundColor,
              leading: IconButton(
                onPressed: () {
                  cubit.editPostImage=null;
                  Navaigatetofinsh(
                      context, EditPostScreen(widget.postModel,widget.index));
                },
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.only(right: 16, top: 10, left: 16,bottom: 10,),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      height: MediaQuery.sizeOf(context).height*0.7,
                      width: double.infinity,child: Image.file(cubit.editPostImage!)),
                  Spacer(),
                  ConditionalBuilder(
                      condition: loadingFlag,
                      builder: (context){
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
                                await cubit.uploadPostImage();
                                await cubit.fetchQualityToUpdated(cubit.editPostImageUrl!);
                                print(cubit.qualityResultToUpdated);
                                if(cubit.qualityResultToUpdated == true){
                                  await cubit.fetchProcessImageToUpdated(cubit.editPostImageUrl!);
                                  if(cubit.isFetchProcessImageToUpdated == true){
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
                                        widget.postModel.category = cubit.categoryToUpdated;
                                        widget.postModel.gender = cubit.genderToUpdated;
                                        widget.postModel.season = cubit.seasonToUpdated;
                                        widget.postModel.size = cubit.sizeToUpdated;
                                        widget.postModel.color = cubit.colorToUpdated;
                                        widget.postModel.productWidth = cubit.widthToUpdated;
                                        widget.postModel.productHeight = cubit.heightToUpdated;
                                        Navaigatetofinsh(
                                            context, EditPostScreen(widget.postModel,widget.index));                                 },
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
                                      "Failed to process your image please specify the image properties yourself.",
                                      btnOkOnPress: () {
                                        Navaigatetofinsh(
                                            context, EditPostScreen(widget.postModel,widget.index));                                },
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
                                      cubit.editPostImage=null;
                                      Navaigatetofinsh(
                                          context, EditPostScreen(widget.postModel,widget.index));
                                    },
                                    btnOkIcon: Icons.check_circle,
                                    onDismissCallback: (type) {
                                      debugPrint('Dialog Dissmiss from callback $type');
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
                      fallback: (context) =>
                          Center(child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ColorsManager.mainColor,
                            ),
                          )),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
