import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taqam/models/posture/postModel.dart';
import 'package:taqam/models/user/userModel.dart';
import 'package:taqam/modules/ta2m_Search_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Search_screen/cubit/states.dart';
import 'package:taqam/modules/ta2m_chats_module/api/apis.dart';
import 'package:taqam/modules/ta2m_chats_module/helper/dialogs.dart';
import 'package:taqam/modules/ta2m_chats_module/screens/confirm_message_screen.dart';
import 'package:taqam/shared/style/color.dart';

import '../../shared/component/componanets.dart';
import '../../shared/style/my_flutter_app_icons.dart';
import '../ta2m_ProductDetails_screen/ProductDetails_screen.dart';
import 'NoResult_screen.dart';
import 'Search_screen.dart';

class ProductsSearchScreen extends StatefulWidget {
  ProductsSearchScreen({super.key});

  @override
  State<ProductsSearchScreen> createState() => _ProductsSearchScreenState();
}

class _ProductsSearchScreenState extends State<ProductsSearchScreen> {
  bool flag = true;

  @override
  Widget build(BuildContext context) {
    var cubit = SearchCubit.get(context);
    return BlocConsumer<SearchCubit, SearchState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
                appBar: AppBar(
                  backgroundColor: ColorsManager.mainBackgroundColor,
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: IconButton(
                      onPressed: () {
                        Navaigateto(context, SearchScreen());
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text('Products Search',style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 30,fontWeight: FontWeight.bold),),
                  ),
                ),
                body: cubit.allPostsFromSearch.length == 0
                    ? const NoResultScreen()
                    : Padding(
                        padding: const EdgeInsets.only(
                            right: 15, top: 20, left: 15
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  return itemsInSearch(
                                      cubit.allPostsFromSearch[index].userModel!, cubit.allPostsFromSearch[index].postModel!, context,index);
                                },
                                separatorBuilder: (context, index) {
                                  return const SizedBox(
                                    height: 10,
                                  );
                                },
                                itemCount: cubit.allPostsFromSearch.length,
                              ),
                            ),
                          ],
                        ),
                      ),
              );
      },
    );
  }

  Widget itemsInSearch(UserModel userModel, PostModel postModel, BuildContext context, int index) {
    var cubit = SearchCubit.get(context);
    return InkWell(
      onTap: (){
        Navaigateto(context,
            ProductDetailsScreen(postModel, userModel));
      },
      child: Container(
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                            children: [
                              IconButton(
                                  alignment: Alignment.centerRight,
                                  onPressed: () async {
                                    if (userModel.userId!.isNotEmpty) {
                                      await addChatUser(userModel.userId!).then((value) {
                                        if (!value) {
                                          Dialogs.showSnackbar(
                                            context, 'USER IS YOU',);
                                        }
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
      ),
    );
  }
}
