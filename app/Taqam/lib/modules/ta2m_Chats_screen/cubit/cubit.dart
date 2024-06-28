import 'dart:io';
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taqam/models/chat/messageModel.dart';
import 'package:taqam/modules/ta2m_Chats_screen/cubit/states.dart';
import 'package:taqam/shared/component/componanets.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(IntialChatState());

  static ChatCubit get(context) {
    return BlocProvider.of(context);
  }

  File? chatImage;
  String chatImageUrl = '';
  var picker =  ImagePicker();

  Future<void> pickImageChat(ImageSource imageSource) async {
    final pickedFile = await picker.pickImage(source: imageSource,imageQuality: 50);
    if (pickedFile != null) {
      chatImage =  File(pickedFile.path);
      emit(SuccessPickImageChatStates());
    } else {
      emit(ErrorPickImageChatStates());
    }
  }


//recorder
  bool isrecord = false;

  changeIsrecord(val) {
    isrecord = val;
    emit(IsrecordStates());
  }

  bool isRecording = false;
  Timer? timer;
  Duration recordingDuration = Duration.zero;

  changeIsrecord2(val) {
    isRecording = val;
    emit(IsrecordStates2());
  }

  changeRecordingDuration(val) {
    recordingDuration = val;
    emit(RecordingDurationStates());
  }

  FlutterSoundRecorder? recorder;

  changeFlutterSoundRecorder(val) {
    recorder = val;
    emit(FlutterSoundRecorderStates());
  }

  Future<void> startRecording(context) async {
    try {
      await recorder!.startRecorder(toFile: 'audio');
    } catch (e) {
      showErrorDialog("Error starting recording: $e", context);
    }
  }

  Future<void> stopRecording(context) async {
    try {
      final path = await recorder!.stopRecorder();

      final audioFile = File(path!);
      //print('recod audio $audioFile');
    } catch (e) {
      showErrorDialog("Error stopping recording: $e", context);
    }
  }

  Future<void> initRecorder(context) async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      showErrorDialog("Microphone permission not granted", context);
      return;
    }
    await recorder!.openRecorder();
  }

  Future<void> showErrorDialog(String message, context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Future<void> sendMessage({
  //   required String receiverId,
  //   required String time,
  //   required String content,
  //   required String type,
  //   required bool read,
  // }) async{
  //   ChatModel model = ChatModel(
  //     UidTokenSave,
  //     userIdReceiver: receiverId,
  //     content: content,
  //     type: type,
  //     time: Timestamp.now(),
  //     read: false,
  //   );
  //   emit(SendMessageLoadingState());
  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(UidTokenSave)
  //       .collection('chats')
  //       .doc(receiverId)
  //       .collection('messages')
  //       .add(model.toMap())
  //       .then((value) {
  //     emit(SendMessageSuccessState());
  //   }).catchError((error) {
  //     emit(SendMessageErrorState());
  //   });
  //
  //   emit(SendMessageLoadingState());
  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(receiverId)
  //       .collection('chats')
  //       .doc(UidTokenSave)
  //       .collection('messages')
  //       .add(model.toMap())
  //       .then((value) {
  //     emit(SendMessageSuccessState());
  //   }).catchError((error) {
  //     emit(SendMessageErrorState());
  //   });
  // }


}