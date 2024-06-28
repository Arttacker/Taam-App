import 'dart:async';
import 'dart:core';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taqam/modules/ta2m_Chats_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Chats_screen/cubit/states.dart';
import 'package:taqam/modules/ta2m_DetailsChat_screen/record.dart';
import '../../helper/date_helper.dart';
import '../../models/chat/messageModel.dart';
import '../../shared/component/componanets.dart';

import 'Audio_player.dart';
import 'ConfirmImagChat_screen.dart';
import 'NoMessage_screen.dart';
import 'openImageChat.dart';

class DetailsChatScreen extends StatefulWidget {

  DetailsChatScreen({super.key});

  static Map<String, AudioPlayer> audios = {};

  bool getMess = false;


  @override
  State<DetailsChatScreen> createState() => _DetailsChatScreenState();
}

class _DetailsChatScreenState extends State<DetailsChatScreen> {
  final _messageController = TextEditingController();
  late StreamSubscription<void>? playerCompleteListener;

  var formkey = GlobalKey<FormState>();

  bool reverse = false;

  bool flagSchroll = true;
  List<ChatModel>messages=[];
  String isme='1';

  //showEmoji -- for storing value of showing or hiding emoji
  bool _showEmoji = false, _isUploading = false;
  @override
  Widget build(BuildContext context) {
    var height2 = MediaQuery.of(context).size.height - 56 - 66;
    double height = 0;
    int counter = 0;
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
      },
      builder: (context, state) {
        var cubit = ChatCubit.get(context);
        return SafeArea(
          child: WillPopScope(
            onWillPop: () {
              cubit.recorder?.closeRecorder();
              cubit.changeFlutterSoundRecorder(null);
              cubit.timer?.cancel();
              cubit.isRecording = false;
              cubit.recordingDuration = Duration.zero;
              DetailsChatScreen.audios.clear();
              Audio_player.currentAudioUrl = null;
              FocusScope.of(context).unfocus();
              return Future(() => true);
            },
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                flexibleSpace: _appBar(),
              ),
              body: Form(
                key: formkey,
                child: Column(
                  children: [
                    messages.isNotEmpty?Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          reverse: reverse,
                          child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                height: 15,
                              );
                            },
                            itemCount: 0,
                          ),
                        ),
                      ),
                    ):
                    const Expanded(child: NoMessageScreen()),
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          cubit.isRecording
                              ? const Recording()
                              : AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: cubit.isRecording ? 0 : null,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          constraints: const BoxConstraints(
                                              maxHeight: 100),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10.0),
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 1.0,
                                              ),

                                              color: Colors.white),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: TextFormField(
                                              controller: _messageController,
                                              keyboardType: TextInputType.emailAddress,
                                              onChanged: (String value) {
                                                if (value.isNotEmpty) {
                                                  cubit
                                                      .changeIsrecord(true);
                                                } else {
                                                  cubit.changeIsrecord(
                                                      false);
                                                }
                                              },
                                              maxLines: null,

                                              decoration: InputDecoration(
                                                prefixIcon: IconButton(
                                                  onPressed: () async {

                                                  },
                                                  icon: Icon(Icons.emoji_emotions,color: Theme.of(context).primaryColor,size: 30,),
                                                ),
                                                suffixIcon: IconButton(
                                                  onPressed: () async {
                                                    await showOptionsDialog(context);
                                                  },
                                                  icon: Icon(Icons.camera_alt_rounded,color: Theme.of(context).primaryColor,size: 30,),
                                                ),
                                                hintText: 'Type Something...',

                                                hintStyle: TextStyle(
                                                    color: Theme.of(context).colorScheme.secondary),
                                                enabledBorder: const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors
                                                          .white), // Set the border color to white
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColor), // Set the border color when focused
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'message must not be empty';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8,),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: IconButton(
                                            onPressed:  cubit.isrecord
                                                ? () async {
                                              if (formkey.currentState!
                                                  .validate()) {
                                                await _playSound(
                                                    'whatsapp.mp3');
                                                _messageController.clear();
                                                cubit.changeIsrecord(false);
                                              }
                                            }
                                                : () async {
                                              _playSound('openMic.mp3')
                                                  .then((value) async {
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 300),
                                                        () async {
                                                      cubit.changeFlutterSoundRecorder(
                                                          FlutterSoundRecorder());
                                                      cubit.changeIsrecord2(
                                                          true);

                                                      cubit.timer =
                                                          Timer.periodic(
                                                              const Duration(
                                                                  seconds: 1),
                                                                  (timer) {
                                                                cubit.changeRecordingDuration(
                                                                    Duration(
                                                                        seconds: timer
                                                                            .tick));
                                                              });

                                                      await cubit
                                                          .initRecorder(context)
                                                          .then((value) async {
                                                        await cubit
                                                            .startRecording(
                                                            context);
                                                      });
                                                    });
                                              });
                                            },
                                            icon:  Icon(cubit.isrecord
                                                ? Icons.send:Icons.mic,color: Colors.white,)
                                        ),
                                      )

                                    ],
                                  ),
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

  Future<void> _playSound(String soundFileName) async {
    AudioPlayer audioPlayer = AudioPlayer();

    await audioPlayer.play(AssetSource(soundFileName),
        mode: PlayerMode.lowLatency);
    playerCompleteListener = audioPlayer.onPlayerComplete.listen((event) {
      playerCompleteListener?.cancel();
      audioPlayer.dispose();
    });
  }
  Widget _appBar() {
    var cubit = ChatCubit.get(context);
    var mq = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: InkWell(
          onTap: () {
            if (Audio_player.currentAudioUrl != null) {
              DetailsChatScreen.audios[Audio_player.currentAudioUrl!]!.pause();
            }

          },
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  cubit.recorder?.closeRecorder();
                  cubit.changeFlutterSoundRecorder(null);
                  cubit.timer?.cancel();
                  cubit.isRecording = false;
                  cubit.recordingDuration = Duration.zero;
                  DetailsChatScreen.audios.clear();
                  Audio_player.currentAudioUrl = null;
                  //cubit.messages = [];
                  FocusScope.of(context).unfocus();
                  Navigator.pop(context);
                },
              ),

              //user profile picture
              const CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage('assets/images/zezo.jpeg'),
              ),

              //for adding some space
              const SizedBox(width: 10),

              //user name & last seen time
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //user name
                  Text('Zezo Hossam',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500)),

                  SizedBox(height: 2),

                  //last seen time of user
                  Text('Online',
                      style: TextStyle(
                          fontSize: 13, color: Colors.black54)),
                ],
              )
            ],
          ),
      ),
    );
  }
  Future<void>showOptionsDialog(BuildContext context) {
    var cubit= ChatCubit.get(context);
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        //alignment: const Alignment(0,0.7),
        children: [
          SimpleDialogOption(
            onPressed: () async {
              await cubit.pickImageChat(ImageSource.camera).then((value) {
                Navigator.pop(context);
                Navaigateto(context,  ConfirmImageChatScreen(image: cubit.chatImage!,));
              });
            },
            child: Row(
              children: [
                Icon(Icons.camera_alt_rounded,color: Theme.of(context).primaryColor,size: 30,),
                const Padding(
                  padding: EdgeInsets.all(7.0),
                  child: Text(
                    'Camera',
                    //style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          SimpleDialogOption(
            onPressed: () async {
              await cubit.pickImageChat(ImageSource.gallery).then((value) {
                Navigator.pop(context);
                Navaigateto(context,  ConfirmImageChatScreen(image: cubit.chatImage!,));
              });
            },
            child: Row(
              children: [
                Icon(Icons.image,color: Theme.of(context).primaryColor,size: 30,),
                const Padding(
                  padding: EdgeInsets.all(7.0),
                  child: Text(
                    'Gallery',
                    //style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
