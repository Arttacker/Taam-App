import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taqam/main.dart';
import 'package:taqam/shared/style/color.dart';

import '../api/apis.dart';
import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';

//home screen -- where all available contacts are shown
class MyChatsScreen extends StatefulWidget {
  const MyChatsScreen({super.key});

  @override
  State<MyChatsScreen> createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  // for storing all users
  List<ChatUser> _list = [];

  // for storing searched items
  final List<ChatUser> _searchList = [];
  // for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    getSelfInfo();

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
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard when a tap is detected on screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if search is on & back button is pressed then close search
        //or else simple close current screen on back button click
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          //app bar
          appBar: AppBar(
            backgroundColor: ColorsManager.mainBackgroundColor,
            automaticallyImplyLeading: false,
            title: _isSearching
                ? TextField(
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: 'Name, Email, ...'),
              autofocus: true,
              style: const TextStyle(fontSize: 20, letterSpacing: 0.5),
              //when search text changes then updated search list
              onChanged: (val) {
                //search logic
                _searchList.clear();

                for (var i in _list) {
                  if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                      i.email.toLowerCase().contains(val.toLowerCase())) {
                    _searchList.add(i);
                    setState(() {
                      _searchList;
                    });
                  }
                }
              },
            )
                : Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text('Chats',style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 30,fontWeight: FontWeight.bold),),
                ),
            actions: [
              //search user button
              Padding(
                padding: const EdgeInsets.only(top: 15,right: 15),
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(_isSearching
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search,color: ColorsManager.mainColor,size: 30,)),
              ),
            ],
          ),
          //body
          body: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: StreamBuilder(
              stream: getMyUsersId(),

              //get id of only known users
              builder: (context, AsyncSnapshot<QuerySnapshot>snapshot) {
                var ids=snapshot.data?.docs.map((e) => e.id).toList() ?? [];
                switch (snapshot.connectionState) {
                //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());

                //if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return ids.isNotEmpty?StreamBuilder(
                      stream: getAllUsers(
                          snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                      //get only those user, who's ids are provided
                      builder: (context, AsyncSnapshot<QuerySnapshot>snapshot) {
                        switch (snapshot.connectionState) {
                        //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                          return const Center(
                              child: CircularProgressIndicator()
                          );

                          //if some or all data is loaded then show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                           {
                             var data = snapshot.data!.docs;
                             data=reorderDocuments(data,ids);


                             return ListView.builder(
                                 itemCount: _isSearching
                                     ? _searchList.length
                                     : data.length,
                                 padding: EdgeInsets.only(top: mq.height * .01),
                                 physics: const BouncingScrollPhysics(),
                                 itemBuilder: (context, index) {
                                   return ChatUserCard(
                                       user: _isSearching
                                           ? _searchList[index]
                                           : ChatUser(image: data[index]['image'], about: data[index]['about'], name: data[index]['name'], createdAt: data[index]['created_at'], isOnline: data[index]['is_online'], id: data[index]['id'], lastActive: data[index]['last_active'], email: data[index]['email'], pushToken: data[index]['push_token'], lastMessage: data[index]['lastMessage']));
                                 });
                           }

                        }
                      },
                    ): const Center(child: Text('Start your first chat',style: TextStyle(fontSize: 25,color: ColorsManager.mainColor),));
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  List<QueryDocumentSnapshot<Object?>> reorderDocuments(
      List<QueryDocumentSnapshot<Object?>> documents,
      List<String> customOrderIds,
      ) {
    List<QueryDocumentSnapshot<Object?>> reorderedList = [];

    try {
      for (String id in customOrderIds) {
        QueryDocumentSnapshot<Object?> matchingDocument = documents.firstWhere(
              (doc) => doc.id == id,
          orElse: () => throw Exception("Document with ID $id not found."), // Throw an exception if no matching document is found
        );

        reorderedList.add(matchingDocument);
      }

      // Add any remaining documents that were not in the customOrderIds list
      for (QueryDocumentSnapshot<Object?> doc in documents) {
        if (!customOrderIds.contains(doc.id)) {
          reorderedList.add(doc);
        }
      }
    } catch (e) {
      // Handle the exception
      // You can choose to rethrow the exception if needed
      // rethrow;
    }

    return reorderedList;
  }
}
