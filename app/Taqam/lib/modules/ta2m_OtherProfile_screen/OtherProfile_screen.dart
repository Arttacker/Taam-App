

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taqam/main.dart';
import 'package:taqam/models/posture/postModel.dart';
import 'package:taqam/models/user/userModel.dart';
import 'package:taqam/modules/ta2m_OtherProfile_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_OtherProfile_screen/cubit/states.dart';

import '../../shared/component/componanets.dart';
import '../../shared/style/color.dart';
import '../../shared/style/my_flutter_app_icons.dart';
import '../ta2m_DetailsChat_screen/DetailsChat_screen.dart';
import '../ta2m_ProductDetails_screen/ProductDetails_screen.dart';

class OtherProfileScreen extends StatefulWidget {
  UserModel userModel;
  final List<PostModel> postList;
  bool flag;
  OtherProfileScreen(this.userModel,this.postList,this.flag);

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  @override
  Widget build(BuildContext context) {

    return BlocConsumer<OtherProfileCubit, OtherProfileState>(
      listener: (context, state) {
      },
      builder: (context, state) {
        var cubit = OtherProfileCubit.get(context);
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 42),
                child: _appBar(context),
              ),
              toolbarHeight: MediaQuery.of(context).size.height*0.2,
            ),
            body: Padding(
              padding: const EdgeInsets.only(right: 12, top: 5, left: 12),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (context,index){
                        return itemSearch(widget.userModel,widget.postList[index],context,index);
                      },
                      separatorBuilder: (context,index){
                        return const SizedBox(
                          height: 10,
                        );
                      },
                      itemCount: widget.postList.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _appBar(context) {
    var cubit = OtherProfileCubit.get(context);
    var size=MediaQuery.of(context).size;
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 10),
            //user profile picture
            Align(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: InkWell(
                  onTap: (){
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
                  child: CircleAvatar(
                    radius: 50,
                    child: CachedNetworkImage(
                      imageUrl: widget.userModel.image!,
                      errorWidget: (context, url, error) => CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            //for adding some space
            const SizedBox(width: 10),
            //user name & last seen time
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text(
                      concatName(widget.userModel.fName!, widget.userModel.lName!),
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis
                      )
                  ),
                  const SizedBox(height: 15,),
                  Text('${widget.userModel.town}, ${widget.userModel.city}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,

                          overflow: TextOverflow.ellipsis
                      )
                  ),

                ],
              ),
            )
          ],
        ),
        Positioned(
          top:size.height*0.04 ,
          right:size.width*0.32 ,
          child: !widget.flag?IconButton(
              onPressed: ()async{
                await cubit.followUser(userId: widget.userModel.userId!, nFollowers: widget.userModel.NFollowers!);
                OtherProfileCubit.get(context).isFollowingFlag=false;
                setState(() {
                  widget.flag = true;
                  widget.userModel.NFollowers = widget.userModel.NFollowers! + 1;
                });
              },
              icon: Icon(Icons.add,color: Theme.of(context).primaryColor,size: 30,)
          ):Row(
            children: [
              Icon(
                Icons.people,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              SizedBox(width: 4),
              Text('${widget.userModel.NFollowers}',style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 20),),
            ],
          ),
        ),
      ],
    );
  }

  Widget itemSearch(UserModel userModel,PostModel postModel,BuildContext context,int index) {
    return InkWell(
      onTap: () {
        Navaigateto(context, ProductDetailsScreen(postModel,userModel));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          // border: Border.all(
          //   color: Colors.grey,
          //   width: 1.0,
          // ),
          color: ColorsManager.mainBackgroundColor,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
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
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${postModel.price} EGP',style: TextStyle(color: Colors.black,fontSize: 16),),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatDate(postModel.postDate!),style: TextStyle(color: Theme.of(context).colorScheme.secondary,fontSize: 13),)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}