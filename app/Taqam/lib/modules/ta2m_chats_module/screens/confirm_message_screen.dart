import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taqam/layout/ta2m_layout_screen/ta2m_Layout_screen.dart';
import 'package:taqam/main.dart';
import 'package:taqam/modules/ta2m_Home_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Home_screen/cubit/states.dart';
import 'package:taqam/modules/ta2m_Sell_screen/Sell_screen.dart';
import 'package:taqam/modules/ta2m_Sell_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_chats_module/api/apis.dart';
import 'package:taqam/modules/ta2m_chats_module/models/chat_user.dart';
import 'package:taqam/modules/ta2m_chats_module/models/message.dart';
import 'package:taqam/modules/ta2m_chats_module/screens/chat_screen.dart';
import 'package:taqam/shared/component/componanets.dart';
import 'package:taqam/shared/style/color.dart';

class ConfirmMessageScreen extends StatefulWidget {
  final ChatUser user;
  final String postImage;

  const ConfirmMessageScreen(
      {super.key, required this.user, required this.postImage});

  @override
  State<ConfirmMessageScreen> createState() => _ConfirmMessageScreenState();
}

class _ConfirmMessageScreenState extends State<ConfirmMessageScreen> {
  bool loadingFlag = true;
  bool _showEmoji = false;
  final _textController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadingFlag = true;
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: Container(
                        height: MediaQuery.sizeOf(context).height*0.7,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: widget.postImage,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ColorsManager.mainColor,
                            ),
                          )),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),

                  _chatInput(),
                  if (_showEmoji)
                    SizedBox(
                      height: mq.height * .35,
                      child: EmojiPicker(
                        textEditingController: _textController,
                        config: Config(
                          bgColor: ColorsManager.mainBackgroundColor,
                          columns: 8,
                          emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                        ),
                      ),
                    )
                ],
              ),
            ),
          );
        });
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          //input field & buttons
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  //emoji button
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _showEmoji = !_showEmoji);
                      },
                      icon: const Icon(Icons.emoji_emotions,
                          color: ColorsManager.mainColor, size: 25)),

                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                    },
                    decoration: const InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: ColorsManager.mainColor),
                        border: InputBorder.none),
                  )),
                  //adding some space
                  SizedBox(width: mq.width * .02),
                ],
              ),
            ),
          ),

          //send message button
          ConditionalBuilder(
              condition: loadingFlag,
              builder: (context)=>MaterialButton(
                onPressed: () async{
                  setState(() {
                    loadingFlag = false;
                  });
                  if (_textController.text.isNotEmpty) {
                    String idChat = await getConversationID(widget.user.id);
                    bool isTrue = await searchConversationIdChat(idChat);
                    if(isTrue){
                      await sendMessage(widget.user, widget.postImage, Type.image);
                      await sendMessage(widget.user, _textController.text, Type.text);
                    }
                    else{
                      await sendFirstMessage(widget.user, widget.postImage, Type.image);
                      await sendMessage(widget.user, _textController.text, Type.text);
                    }
                    _textController.text = '';
                    Navaigatetofinsh(context, ChatScreen(user: widget.user));
                    chatUser = null;
                  } else {
                    setState(() {
                      loadingFlag = true;
                    });
                    showToast(
                        message: 'Can\'t send an empty message',
                        toast: ToastStates.Warning);
                  }
                },
                minWidth: 0,
                padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
                shape: const CircleBorder(),
                color: ColorsManager.mainColor,
                child: const Icon(Icons.send, color: Colors.white, size: 28),
              ),
              fallback: (context)=>const Center(child: CircularProgressIndicator(color: ColorsManager.mainColor,)),
          )
        ],
      ),
    );
  }
}
