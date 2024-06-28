import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taqam/modules/ta2m_Chats_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Chats_screen/cubit/states.dart';

import '../../helper/date_helper.dart';
import '../../models/chat/messageModel.dart';
import '../../shared/component/componanets.dart';
import '../ta2m_DetailsChat_screen/DetailsChat_screen.dart';

class ChatsScreen extends StatefulWidget {
  ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ChatModel _message = ChatModel(UIdSender: '2', UIdReciver: '1', message: '', dateTime: '1707778998452', image: '', audio: 'ss', id: '', read: true);
  String isMe='1';

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    var cubit = ChatCubit.get(context);
    return BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {},
        builder: (context, state) {
          return SafeArea(
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.only(top: 30,right: 30,left: 30,bottom: 5),
                child: Column(
                  children: [
                    Text('Chats',style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 24,fontWeight: FontWeight.bold),),
                    const SizedBox(height: 20,),
                    Expanded(
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navaigateto(context, DetailsChatScreen());
                            },
                            child: ListTile(
                              leading: const CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage('assets/images/zezo.jpeg'),
                              ),
                              title: const Text('Zezo Hossam'),
                              subtitle: Row(
                                children: [
                                  _message != null
                                      ? _message!.image != ''
                                      ? Icon(
                                    Icons.image,
                                    size: 15,
                                    color: _message!
                                        .read!
                                        ? Colors
                                        .greenAccent
                                        : Colors
                                        .grey,
                                  )
                                      : _message!.audio !=
                                      null
                                      ? Icon(
                                    Icons.mic,
                                    size: 15,
                                    color: _message!.read!
                                        ? Colors
                                        .greenAccent
                                        : Colors
                                        .grey,
                                  )
                                      : _message!.UIdSender == isMe

                                      ? Icon(
                                    Icons
                                        .done_all_outlined,
                                    size:
                                    15,
                                    color: _message!.read!
                                        ? Colors.greenAccent
                                        : Colors.grey,
                                  )
                                      : const SizedBox()
                                      : const SizedBox(),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Expanded(
                                    child: Text(
                                      _message != null
                                          ? _message!.image !=
                                          ''
                                          ? 'image'
                                          : _message!.audio !=
                                          null
                                          ? 'Record'
                                          : _message!
                                          .message ??
                                          ''
                                          : '',
                                      maxLines: 1,
                                      style: const TextStyle(
                                          overflow: TextOverflow
                                              .ellipsis),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: _message == null
                                  ? null //show nothing when no message is sent
                                  : _message!.read == false &&
                                  _message!
                                      .UIdSender !=
                                      isMe
                                  ?
                              // show for unread message
                              Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                    color:
                                    Theme.of(context).primaryColor,
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                        10)),
                              )
                                  :
                              //message sent time
                              Text(
                                MyDateUtil.getLastMessageTime(
                                  context:
                                  context,
                                  time: _message!
                                      .dateTime!,),
                                style: const TextStyle(
                                  color: Colors
                                      .black54,),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsetsDirectional.only(
                                start: 20.0),
                            child: Container(
                              width: double.infinity,
                              height: 1,
                              color: Colors.white,
                            ),
                          );
                        },
                        itemCount: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}