import 'dart:io';

import 'package:flutter/material.dart';
import 'package:taqam/layout/ta2m_layout_screen/ta2m_Layout_screen.dart';
import 'package:taqam/modules/ta2m_Account_screen/cubit/cubit.dart';
import 'package:taqam/shared/component/componanets.dart';
import 'package:taqam/shared/style/color.dart';




class ConfirmImageProfileScreen extends StatelessWidget {
  const ConfirmImageProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit=AccountCubit.get(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsManager.mainBackgroundColor,
        leading: IconButton(
          onPressed: () {
            cubit.profileImage=null;
            Navigator.pop(context);
          },
          icon:  Icon(Icons.close,color: Theme.of(context).primaryColor,size: 30,),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 16, top: 10, left: 16,bottom: 10,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
                height: MediaQuery.sizeOf(context).height*0.7,
                width: double.infinity,
                child: Image.file(cubit.profileImage!)),
            Spacer(),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                  onPressed: (){
                    Navaigateto(context, Ta2mLayoutScreen());
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
