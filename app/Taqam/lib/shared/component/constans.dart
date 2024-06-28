// baseUrl:https://newsapi.org/
// method(Url):v2/top-headlines?
// query:country=us&category=business&apiKey=46bc5e0eccc941c99ca85c24563fbd86

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../network/local/Cash_helper.dart';
import 'componanets.dart';



void SignoutSocial(context)
{
  CashHelper.cleardata(key: 'UId').then((value) {
    if(value==true)
    {
      //Navaigatetofinsh(context,SocialAppLogin());
    }
  });

}

void showAlltext(String text)
{
  final pattern = RegExp('.{1,800}');
  pattern.allMatches(text).forEach((element) {
    print(element.group(0));
  });
}



// FIREBASE
var firebaseAuth = FirebaseAuth.instance;
var firebaseStorage = FirebaseStorage.instance;
var firestore = FirebaseFirestore.instance;


const borderColor = Colors.grey;

const APIServerPort = "8000";
const APIServerIP = "192.168.1.4";


const List<String> scopes = <String>[
  'email',
];