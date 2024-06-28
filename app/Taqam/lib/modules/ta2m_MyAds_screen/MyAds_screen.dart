import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taqam/models/posture/postModel.dart';
import 'package:taqam/models/user/userModel.dart';
import 'package:taqam/modules/ta2m_Account_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Account_screen/cubit/states.dart';
import 'package:taqam/modules/ta2m_EditPost_screen/EditPost_Screen.dart';
import 'package:taqam/modules/ta2m_MyAds_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_MyAds_screen/cubit/states.dart';
import 'package:taqam/modules/ta2m_ProductDetails_screen/ProductDetails_screen.dart';

import '../../layout/ta2m_layout_screen/ta2m_Layout_screen.dart';
import '../../shared/component/componanets.dart';
import '../../shared/style/color.dart';

class MyAdsScreen extends StatelessWidget {
  const MyAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyAdsCubit, MyAdsState>(
      listener: (context, state) {
        if(state is ConnectivityErrorState){
          AwesomeDialog(
            context: context,
            animType: AnimType.leftSlide,
            headerAnimationLoop: false,
            dialogType: DialogType.error,
            showCloseIcon: true,
            title: 'Error',
            desc:
            'No internet connection',
            btnOkOnPress: () {
            },
            btnOkIcon: Icons.check_circle,
            onDismissCallback: (type) {
              debugPrint('Dialog Dissmiss from callback $type');
            },
            btnOkColor: ColorsManager.mainColor,
          ).show();
        }
        else if(state is DeletePostSuccessState){
          showToast(
              message: "Post deleted successfully!", toast: ToastStates.Sucsess);
        }
      },
      builder: (context, state) {
        var cubit = MyAdsCubit.get(context);
        var accountCubit = AccountCubit.get(context);
        return cubit.allMyPosts.length==0 ? Center(child: Text('No data available...',style: TextStyle(color: ColorsManager.mainColor,fontWeight: FontWeight.bold,fontSize: 20.0),)) : ConditionalBuilder(
          condition: !(state is GetAllMyPostsLoadingState),
          builder: (context) => SafeArea(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: ColorsManager.mainBackgroundColor,
                automaticallyImplyLeading: false,
                title: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text('My Ads',style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 30,fontWeight: FontWeight.bold),),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.only(
                    right: 15, top: 30, left: 15),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          return itemInMyAds(accountCubit.userModel!, cubit.allMyPosts[index], context, index);
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                        itemCount: cubit.allMyPosts.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          fallback: (context) => Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              ColorsManager.mainColor,
            ),
          )),
        );
      },
    );
  }

  Widget itemInMyAds(UserModel userModel, PostModel postModel, BuildContext context, int index) {
    var cubit = MyAdsCubit.get(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Colors.transparent,
          width: 0,
        ),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 0,
            fit: FlexFit.tight,
            child: SizedBox(
              width: 122,
              height: 124,
              child: CachedNetworkImage(
                imageUrl: postModel.image!,
                fit: BoxFit.fill,
                placeholder: (context, url) => Center(child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ColorsManager.mainColor,
                  ),
                )),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Text(
                          postModel.description!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton(
                        icon:  Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(
                            Icons.more_vert_rounded,
                            size: 24,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry>[
                          PopupMenuItem(
                            child: ListTile(
                              title: const Row(
                                children: [
                                  Text('View',style: TextStyle(color: Colors.white,fontSize: 12),),
                                  SizedBox(width: 30,),
                                  Icon(Icons.view_compact_rounded,color: Colors.white,)
                                ],
                              ),
                              onTap: () {
                                Navaigateto(context, ProductDetailsScreen(postModel,userModel));
                              },
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              title: const Row(
                                children: [
                                  Text('Edit',style: TextStyle(color: Colors.white,fontSize: 12),),
                                  SizedBox(width: 37,),
                                  Icon(Icons.edit,color: Colors.white,)
                                ],
                              ),
                              onTap: (){
                                Navaigateto(context, EditPostScreen(postModel,index));
                              },
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              title: const Row(
                                children: [
                                  Text('Renew',style: TextStyle(color: Colors.white,fontSize: 12),),
                                  SizedBox(width: 22,),
                                  Icon(Icons.autorenew,color: Colors.white,)
                                ],
                              ),
                              onTap: () async{
                                cubit.renewPost(userId: postModel.userId!, postId: postModel.postId!);
                                cubit.allMyPosts[index].postDate = Timestamp.now();
                                cubit.allMyPosts.insert(0, cubit.allMyPosts[index]);
                                cubit.allMyPosts.removeAt(index+1);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              title: const Row(
                                children: [
                                  Text('Delete',style: TextStyle(color: Colors.white,fontSize: 12),),
                                  SizedBox(width: 23,),
                                  Icon(Icons.delete,color: Colors.white,)
                                ],
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      actionsAlignment: MainAxisAlignment.spaceBetween,
                                      backgroundColor: Theme.of(context).primaryColor,
                                      content:  const Text(
                                        'Are you sure you want to delete this post?',style: TextStyle(color: Colors.white,fontSize: 16,),),
                                      actions: <Widget>[
                                        TextButton(
                                          child:  const Text('Yes',style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.bold),),
                                          onPressed: () async {
                                            await cubit.deletePost(userId: postModel.userId!, postId: postModel.postId!);
                                            await cubit.deleteImagePostDeleted(image: postModel.image!);
                                            cubit.allMyPosts.removeAt(index);
                                            Navigator.of(context).pop();
                                            Navaigatetofinsh(context, const Ta2mLayoutScreen());
                                          },
                                        ),

                                        TextButton(
                                          child:  const Text('No',style:TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.bold),),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30.0),
                            bottomRight: Radius.circular(30.0),
                            topLeft: Radius.circular(30.0),
                          ),
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      '${userModel.town}, ${userModel.city}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${postModel.price} EGP',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          formatDate(postModel.postDate!),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 10),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}