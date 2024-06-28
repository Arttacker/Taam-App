import 'dart:async';


import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:icon_broken/icon_broken.dart';
import 'package:taqam/modules/ta2m_Chats_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Chats_screen/cubit/states.dart';



class Recording extends StatefulWidget {


  const Recording({super.key, });

  @override
  State<Recording> createState() => _RecordingState();
}
String twoDigits(int n) {
  return n.toString().padLeft(2, '0');
}

class _RecordingState extends State<Recording> {

  late ChatCubit cubit;
  @override
  void initState() {
    super.initState();
    cubit = ChatCubit.get(context);
    //cubit.initRecorder(context);
  }
   @override
   void didChangeDependencies() {
     super.didChangeDependencies();
     //cubit = ChatCubit.get(context);
   }
  @override
  void dispose() {
    cubit.recorder?.closeRecorder();
    cubit.changeFlutterSoundRecorder(null);
    cubit.timer!.cancel();
    super.dispose();
  }

  late StreamSubscription<void> ?playerCompleteListener;
  Future<void> _playSound(String soundFileName) async {
    AudioPlayer audioPlayer = AudioPlayer();


    await audioPlayer.play(AssetSource(soundFileName));
    playerCompleteListener = audioPlayer.onPlayerComplete.listen((event) {
      playerCompleteListener?.cancel();
      audioPlayer.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit=ChatCubit.get(context);

        return AnimatedContainer(
          duration:  const Duration(milliseconds: 300),
          width: cubit.isRecording ? null : 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // Set background color
                    borderRadius: BorderRadius.circular(25), // Adjust border radius
                  ),
                  constraints: const BoxConstraints(maxHeight: 100),
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.end,

                    children: [
                      const SizedBox(
                        width: 2,
                      ),
                       Icon(
                        Icons.mic,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      Text(
                        '${twoDigits(cubit.recordingDuration.inMinutes)}:${twoDigits(cubit.recordingDuration.inSeconds.remainder(60))}',
                        style:  TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                       Icon(
                        IconBroken.Arrow___Left_2,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Text('Drag to cancel'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 2,
              ),

              Dismissible(
                direction: DismissDirection.horizontal,
                key: const ValueKey('lol'),
                onDismissed: (_) async {
                  await _playSound('dismissMic.mp3');
                  cubit.changeIsrecord2(false) ;
                  cubit.changeRecordingDuration(Duration.zero)  ;
                  cubit.timer!.cancel();
                  await cubit.recorder?.stopRecorder();
                  cubit.recorder?.closeRecorder();
                  cubit.changeFlutterSoundRecorder(null);
                },

                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                      onPressed: (){
                        cubit.changeIsrecord2(false) ;
                        _playSound('whatsapp.mp3');
                        cubit.changeRecordingDuration(Duration.zero)  ;
                        cubit.timer!.cancel();
                      },
                      icon: const Icon(Icons.send,color: Colors.white,)
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
