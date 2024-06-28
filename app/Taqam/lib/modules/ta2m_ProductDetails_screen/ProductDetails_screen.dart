import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taqam/main.dart';
import 'package:taqam/models/posture/postModel.dart';
import 'package:taqam/models/user/userModel.dart';
import 'package:taqam/modules/ta2m_OtherProfile_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_ProductDetails_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_ProductDetails_screen/cubit/states.dart';
import 'package:taqam/modules/ta2m_chats_module/api/apis.dart';
import 'package:taqam/modules/ta2m_chats_module/helper/dialogs.dart';
import 'package:taqam/modules/ta2m_chats_module/screens/chat_screen.dart';
import 'package:taqam/modules/ta2m_chats_module/screens/confirm_message_screen.dart';
import 'package:taqam/shared/style/color.dart';
import 'package:taqam/shared/style/my_flutter_app_icons.dart';
import '../../shared/component/componanets.dart';
import '../ta2m_OtherProfile_screen/OtherProfile_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final PostModel postModel;
  final UserModel userModel;

  ProductDetailsScreen(this.postModel, this.userModel);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    var cubit = ProductCubit.get(context);
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {},
      builder: (context, state) {
        var otherProfileCubit=OtherProfileCubit.get(context);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: ColorsManager.mainBackgroundColor,
            leading: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(right: 30, left: 30),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 278,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CachedNetworkImage(
                              imageUrl: widget.postModel.image!,
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/default_profile_image.jpg',
                              ),
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          width: double.infinity, // Full width
                          height: double.infinity, // Full height
                          child: CachedNetworkImage(
                            imageUrl: widget.postModel.image!,
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
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    widget.postModel.description!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    '${widget.postModel.price} EGP',
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                      Expanded(
                        child: Text(
                          '${widget.userModel.town}, ${widget.userModel.city}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        formatDate(widget.postModel.postDate!),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 16),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    'Details:',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    widget.postModel.category!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 2,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    widget.postModel.gender!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 2,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    widget.postModel.season!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 2,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        color: hexToColor(widget.postModel.color!),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        widget.postModel.coloredName!,
                        style: TextStyle(
                          color: hexToColor(widget.postModel.color!),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 2,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    widget.postModel.condition!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 2,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Text(
                        widget.postModel.size!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 12),
                      ),
                      const Spacer(),
                      IconButton(
                          onPressed: () {
                            cubit.changsizeProductDetailsFlag();
                          },
                          icon: Icon(
                            cubit.sizeProductDetailsFlag
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: Colors.white,
                            size: 30,
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 2,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                  Visibility(
                    visible: !cubit.sizeProductDetailsFlag,
                    child: Container(
                      height: 40,
                      width: double.infinity,
                      color: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Width: ${widget.postModel.productWidth} cm',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !cubit.sizeProductDetailsFlag,
                    child: SizedBox(
                      width: double.infinity,
                      height: 2,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !cubit.sizeProductDetailsFlag,
                    child: Container(
                      height: 40,
                      width: double.infinity,
                      color: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Height: ${widget.postModel.productHeight} cm',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: CachedNetworkImageProvider(
                          widget.userModel.image!,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              concatName(widget.userModel.fName!,
                                  widget.userModel.lName!),
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: TextButton(
                                    onPressed: () async{
                                      await otherProfileCubit.getUserPosts(userId: widget.userModel.userId!);
                                      await otherProfileCubit.followingSearch(userId: widget.userModel.userId!);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OtherProfileScreen(widget.userModel,otherProfileCubit.userPosts,otherProfileCubit.isFollowingFlag)),
                                      );
                                    },
                                    child: Text(
                                      'View Profile',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await otherProfileCubit.getUserPosts(userId: widget.userModel.userId!);
                                    await otherProfileCubit.followingSearch(userId: widget.userModel.userId!);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              OtherProfileScreen(widget.userModel,otherProfileCubit.userPosts,otherProfileCubit.isFollowingFlag)),
                                    );
                                    OtherProfileCubit.get(context).isFollowingFlag=false;
                                  },
                                  icon: Icon(
                                    Icons.keyboard_arrow_right,
                                    color: Theme.of(context).primaryColor,
                                    size: 24,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (widget.userModel.userId == userModel!.userId) {
                            await addChatUser(userModel!.userId!).then((value) {
                              if (!value) {
                                Dialogs.showSnackbar(
                                  context, 'USER IS YOU',);
                              }
                            });
                          }
                          await getUser(widget.userModel.userId!);
                          Navaigateto(context, ConfirmMessageScreen(user: chatUser!, postImage: widget.postModel.image!));
                          chatUser = null;
                        },
                        icon: Icon(
                          MyFlutterApp.chaticon,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _appBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          // User profile picture
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CachedNetworkImage(
                    imageUrl: widget.userModel.image!,
                    errorWidget: (context, url, error) => CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .03),
              child: CachedNetworkImage(
                width: mq.height * .05,
                height: mq.height * .05,
                imageUrl: widget.userModel.image!,
                errorWidget: (context, url, error) => CircleAvatar(
                  child: Icon(CupertinoIcons.person),
                ),
              ),
            ),
          ),
          // Add space
          SizedBox(width: 10),
          // User name & last seen time
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name
                Text(
                  concatName(widget.userModel.fName!,widget.userModel.lName!),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            onPressed: () async {
              if (widget.userModel.userId == userModel!.userId) {
                await addChatUser(userModel!.userId!).then((value) {
                  if (!value) {
                    Dialogs.showSnackbar(
                      context, 'USER IS YOU',);
                  }
                });
              }
              await getUser(widget.userModel.userId!);
              Navaigateto(context, ChatScreen(user: chatUser!));
              chatUser = null;
            },
            icon: Icon(
              MyFlutterApp.chaticon,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

}
