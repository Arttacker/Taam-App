import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:taqam/models/user/userModel.dart';
import 'package:taqam/shared/component/componanets.dart';

import '../models/chat_user.dart';
import '../models/message.dart';

// for authentication
FirebaseAuth auth = FirebaseAuth.instance;
// for accessing cloud firestore database
FirebaseFirestore firestore = FirebaseFirestore.instance;

// for accessing firebase storage
FirebaseStorage storage = FirebaseStorage.instance;

// for storing self information
ChatUser me = ChatUser(
  id: userModel!.userId!,
  name: concatName(userModel!.fName!, userModel!.lName!),
  email: userModel!.email!,
  about: "Hey, I'm using Ta\'am!",
  image: userModel!.image!,
  createdAt: '',
  isOnline: false,
  lastActive: '',
  pushToken: '',
  lastMessage: '',
);

UserModel? userModel;

Future<void> getUserModel() async {
  print(UidTokenSave);
  await firestore
      .collection('users')
      .doc(UidTokenSave)
      .collection('profile')
      .doc(UidTokenSave)
      .get()
      .then((value) {
    userModel = UserModel.fromJson(value.data()!);
  }).catchError((error) {
    print(error.toString());
  });
}

// for accessing firebase messaging (Push Notification)
FirebaseMessaging fMessaging = FirebaseMessaging.instance;

// for getting firebase messaging token
Future<void> getFirebaseMessagingToken() async {
  await fMessaging.requestPermission();

  await fMessaging.getToken().then((t) {
    if (t != null) {
      me.pushToken = t;
      log('Push Token: $t');
    }
  });
  // for handling foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.data}');

    if (message.notification != null) {
      log('Message also contained a notification: ${message.notification}');
    }

    showToast(message: 'message', toast: ToastStates.Sucsess);
    return;
  });
}

// for sending push notification
Future<void> sendPushNotification(ChatUser chatUser, String msg) async {
  try {
    final body = {
      "to": chatUser.pushToken,
      "notification": {
        "title": me.name, //our name should be send
        "body": msg,
        "android_channel_id": "chats"
      },
      "data": {
        "some_data": "User ID: ${me.id}",
      },
    };

    var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              'key=AAAAXNeacsk:APA91bHCPwlnuIE4ZYMsh8O90drBvDZqjZyJvCbuOm0HRQBl40TgoK4nQoG_3aAAGUxrx3mimouAQ7tp2m0AgVOTnR-j7da8hCbFgsanSM6q95A_CWkBxmY_FPUblAGcBbsz6f-tH42a'
        },
        body: jsonEncode(body));
    log('Response status: ${res.statusCode}');
    log('Response body: ${res.body}');
  } catch (e) {
    log('\nsendPushNotificationE: $e');
  }
}

// for checking if user exists or not?
Future<bool> userExists() async {
  return (await firestore.collection('users_chat').doc(userModel!.userId).get())
      .exists;
}

// for adding an chat user for our conversation
Future<bool> addChatUser(String id) async {
  final data =
      await firestore.collection('users_chat').where('id', isEqualTo: id).get();

  log('data: ${data.docs}');

  if (data.docs.isNotEmpty && data.docs.first.id != userModel!.userId) {
    //user exists

    log('user exists: ${data.docs.first.data()}');

    firestore
        .collection('users_chat')
        .doc(userModel!.userId)
        .collection('my_users')
        .doc(data.docs.first.id)
        .set({});

    return true;
  } else {
    //user doesn't exists

    return false;
  }
}

// for getting current user info
Future<void> getSelfInfo() async {
  await firestore
      .collection('users_chat')
      .doc(userModel!.userId)
      .get()
      .then((user) async {
    if (user.exists) {
      me = ChatUser.fromJson(user.data()!);
      await getFirebaseMessagingToken();

      //for setting user status to active
      updateActiveStatus(true);
      log('My Data: ${user.data()}');
    } else {
      await createUser().then((value) => getSelfInfo());
    }
  });
}

// for creating a new user
Future<void> createUser() async {
  final time = DateTime.now().millisecondsSinceEpoch.toString();

  final chatUser = ChatUser(
    id: userModel!.userId!,
    name: concatName(userModel!.fName!, userModel!.lName!),
    email: userModel!.email!,
    about: "Hey, I'm using We Chat!",
    image: userModel!.image!,
    createdAt: time,
    isOnline: false,
    lastActive: time,
    pushToken: '',
    lastMessage: time,
  );

  return await firestore
      .collection('users_chat')
      .doc(userModel!.userId)
      .set(chatUser.toJson());
}

// for getting id's of known users from firestore database
Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
  return firestore
      .collection('users_chat')
      .doc(userModel!.userId)
      .collection('my_users')
      .orderBy('lastMessage',descending: true)
      .snapshots();
}

// for getting all users from firestore database
Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds) {
  log('\nUserIds: $userIds');
  return firestore
      .collection('users_chat')
      .where('id',
          whereIn: userIds.isEmpty
              ? ['']
              : userIds) //because empty list throws an error
      // .where('id', isNotEqualTo: user.uid)
      .snapshots();
}

// for updating user information
Future<void> updateUserInfo() async {
  await firestore.collection('users_chat').doc(userModel!.userId).update({
    'name': me.name,
    'about': me.about,
  });
}

// update profile picture of user
Future<void> updateProfilePicture(File file) async {
  //getting image file extension
  final ext = file.path.split('.').last;
  log('Extension: $ext');

  //storage file ref with path
  final ref = storage.ref().child('profile_pictures/${userModel!.userId}.$ext');

  //uploading image
  await ref
      .putFile(file, SettableMetadata(contentType: 'image/$ext'))
      .then((p0) {
    log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
  });

  //updating image in firestore database
  me.image = await ref.getDownloadURL();
  await firestore
      .collection('users_chat')
      .doc(userModel!.userId)
      .update({'image': me.image});
}

// for getting specific user info
Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUser chatUser) {
  return firestore
      .collection('users_chat')
      .where('id', isEqualTo: chatUser.id)
      .snapshots();
}

ChatUser? chatUser;

Future<void> getUser(String userId) async {
  await firestore.collection('users_chat').doc(userId).get().then((value) {
    chatUser = ChatUser.fromJson(value.data()!);
  }).catchError((error) {});
}

// update online or last active status of user
Future<void> updateActiveStatus(bool isOnline) async {
  firestore.collection('users_chat').doc(userModel!.userId).update({
    'is_online': isOnline,
    'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
    'push_token': me.pushToken,
  });
}

///************** Chat Screen Related APIs **************

// chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

// useful for getting conversation id
String getConversationID(String id) => userModel!.userId.hashCode <= id.hashCode
    ? '${userModel!.userId}_$id'
    : '${id}_${userModel!.userId}';

// for getting all messages of a specific conversation from firestore database
Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
  // return firestore.collection('chats').doc(user.id).collection('messages').orderBy('sent',descending: true).snapshots();
  return firestore
      .collection('chats/${getConversationID(user.id)}/messages/')
      .orderBy('sent', descending: true)
      .snapshots();
}

// for adding an user to my user when first message is send
Future<void> sendFirstMessage(ChatUser chatUser, String msg, Type type) async {
  await firestore
      .collection('users_chat')
      .doc(chatUser.id)
      .collection('my_users')
      .doc(userModel!.userId)
      .set({}).then((value) => sendMessage(chatUser, msg, type));

}

// for sending message
Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
  //message sending time (also used as id)
  final time = DateTime.now().millisecondsSinceEpoch.toString();
  final timestamp = FieldValue.serverTimestamp();
  //message to send
  final Message message = Message(
      toId: chatUser.id,
      msg: msg,
      read: '',
      type: type,
      fromId: userModel!.userId!,
      sent: time,
      timestamp: timestamp
  );
  final ref =
      firestore.collection('chats/${getConversationID(chatUser.id)}/messages/');
  await ref.doc(time).set(message.toJson()).then((value) =>
      sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  await firestore
      .collection('users_chat')
      .doc(chatUser.id)
      .collection('my_users')
      .doc(userModel!.userId)
      .set({});


  await firestore
      .collection('users_chat')
      .doc(chatUser.id)
      .collection('my_users')
      .doc(userModel!.userId)
      .update({
    "lastMessage": time,
    'timestamp': timestamp,
  });
  await firestore
      .collection('users_chat')
      .doc(userModel!.userId)
      .collection('my_users')
      .doc(chatUser.id)
      .update({
    "lastMessage": time,
    'timestamp': timestamp,
  });
}

//update read status of message
Future<void> updateMessageReadStatus(Message message) async {
  firestore
      .collection('chats/${getConversationID(message.fromId)}/messages/')
      .doc(message.sent)
      .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
}

//get only last message of a specific chat
Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user) {
  return firestore
      .collection('chats/${getConversationID(user.id)}/messages/')
      .orderBy('sent', descending: true)
       //timestamp
      .limit(1)
      .snapshots();
}

//send chat image
Future<void> sendChatImage(ChatUser chatUser, File file) async {
  //getting image file extension
  final ext = file.path.split('.').last;

  //storage file ref with path
  final ref = storage.ref().child(
      'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

  //uploading image
  await ref
      .putFile(file, SettableMetadata(contentType: 'image/$ext'))
      .then((p0) {
    log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
  });

  //updating image in firestore database
  final imageUrl = await ref.getDownloadURL();
  await sendMessage(chatUser, imageUrl, Type.image);
}

//delete message
Future<void> deleteMessage(Message message) async {
  await firestore
      .collection('chats/${getConversationID(message.toId)}/messages/')
      .doc(message.sent)
      .delete();

  if (message.type == Type.image) {
    await storage.refFromURL(message.msg).delete();
  }
}

Future<bool> searchConversationIdChat(String conversationId) async {
  DocumentSnapshot snapshot =
      await firestore.collection('chats').doc(conversationId).get();
  return snapshot.exists;
}
