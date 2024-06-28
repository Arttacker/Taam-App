import 'package:cached_network_image/cached_network_image.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taqam/models/posture/postModel.dart';
import 'package:taqam/modules/ta2m_Home_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Home_screen/cubit/states.dart';
import 'package:taqam/modules/ta2m_MyAds_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_chats_module/api/apis.dart';
import 'package:taqam/modules/ta2m_chats_module/helper/dialogs.dart';
import 'package:taqam/modules/ta2m_chats_module/screens/confirm_message_screen.dart';

import '../../models/user/userModel.dart';
import '../../shared/component/componanets.dart';
import '../../shared/style/color.dart';
import '../../shared/style/my_flutter_app_icons.dart';
import '../ta2m_ProductDetails_screen/ProductDetails_screen.dart';
import '../ta2m_Search_screen/Search_screen.dart';
import 'Filter_screen.dart';
import 'SortBy_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit,HomeState>(
      listener: (context, state){
      },
      builder: (context, state){
        var cubit = HomeCubit.get(context);
        if(!cubit.stateToUpdate && userModel != null){
          updateActiveStatus(true);
          cubit.stateToUpdate = true;
        }
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: ColorsManager.mainBackgroundColor,
            title: Text('Home',style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 30,fontWeight: FontWeight.bold),),
            actions: [
              //search user button
              IconButton(
                  onPressed: () {
                    Navaigateto(context, SearchScreen());
                  },
                  icon: Icon(Icons.search,color: ColorsManager.mainColor,size: 30,)),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(right: 15, top: 12, left: 15,),
              child: RefreshIndicator(
                onRefresh: ()async{
                  cubit.allPostsWithThemUsers.clear();
                  MyAdsCubit.get(context).allMyPosts.clear();
                  if(cubit.allPostsWithThemUsers.length==0&&MyAdsCubit.get(context).allMyPosts.length==0){
                    await cubit.getAllPosts();
                    await MyAdsCubit.get(context).getAllMyPosts();
                  }
                },
                child: CustomScrollView(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navaigateto(context,  FilterScreen());
                                },
                                child: Container(
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4, right: 8.0, top: 4, bottom: 4),
                                        child: Icon(
                                          MyFlutterApp.filter,
                                          color: Theme.of(context).primaryColor,
                                          size: 15,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 8, top: 4, bottom: 4),
                                        child: Text(
                                          'Filters',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.secondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: ()async{
                                  cubit.allPostsWithThemUsers.clear();
                                  MyAdsCubit.get(context).allMyPosts.clear();
                                  if(cubit.allPostsWithThemUsers.length==0&&MyAdsCubit.get(context).allMyPosts.length==0){
                                    await cubit.getAllPosts();
                                    await MyAdsCubit.get(context).getAllMyPosts();
                                  }
                                },
                                icon: Icon(
                                  Icons.refresh,
                                  color: ColorsManager.mainColor,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navaigateto(context, const SortByScreen());
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Sort By',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    // Add some spacing between text and icon
                                    Icon(
                                      MyFlutterApp.sort,
                                      color: Theme.of(context).primaryColor,
                                      size: 15,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ConditionalBuilder(
                            condition: cubit.allPostsWithThemUsers.length>0,
                            builder: (context) => GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: cubit.allPostsWithThemUsers.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.6,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemBuilder: (context, index){
                                return itemInHome(cubit.allPostsWithThemUsers[index].userModel!, cubit.allPostsWithThemUsers[index].postModel!, context);
                              },
                            ),
                            fallback: (context) => const Center(child: Text('No available data!',style: TextStyle(color: ColorsManager.mainColor,fontSize: 20),)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget itemInHome(UserModel userModel, PostModel postModel, BuildContext context){
    return InkWell(
      onTap: (){
        Navaigateto(context,
            ProductDetailsScreen(postModel, userModel));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          // border: Border.all(
          //   color: Colors.grey,
          //   width: 1.0,
          // ),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(9),
                      topRight: Radius.circular(9)),
                  child: SizedBox(
                    width: double.infinity,
                    height: 150,
                    child: CachedNetworkImage(
                      imageUrl: postModel.image!,
                      fit: BoxFit.fill,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ColorsManager.mainColor,
                            ),
                          )),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        postModel.description!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                        alignment: Alignment.centerRight,
                        onPressed: () async {
                          if (userModel.userId!.isNotEmpty) {
                            await addChatUser(userModel.userId!).then((value) {
                            });
                          }
                          await getUser(userModel.userId!);
                          Navaigateto(context, ConfirmMessageScreen(user: chatUser!, postImage: postModel.image!));
                          chatUser = null;
                        },
                        icon: Icon(
                          MyFlutterApp.chaticon,
                          size: 14,
                          color: Theme.of(context).primaryColor,
                        ))
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
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${postModel.price!} EGP',
                        style:
                        TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        formatDate(postModel.postDate!),
                        style: TextStyle(
                            color:
                            Theme.of(context).colorScheme.secondary,
                            fontSize: 10),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}
