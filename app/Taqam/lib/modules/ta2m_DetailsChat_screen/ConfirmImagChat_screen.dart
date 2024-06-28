import 'dart:io';

import 'package:flutter/material.dart';




class ConfirmImageChatScreen extends StatelessWidget {
  final File image;
  ConfirmImageChatScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon:  Icon(Icons.close,color: Theme.of(context).primaryColor,size: 30,),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(42),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
                child: Image.file(image)
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.send,color: Colors.white,)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
