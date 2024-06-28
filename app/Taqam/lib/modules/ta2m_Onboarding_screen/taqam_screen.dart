import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:taqam/modules/ta2m_Onboarding_screen/Onboarding_screen.dart';
import 'package:taqam/shared/style/color.dart';

import '../../shared/component/componanets.dart';
import '../../shared/network/local/Cash_helper.dart';

class TaqamScreen extends StatefulWidget {
  const TaqamScreen({super.key});

  @override
  State<TaqamScreen> createState() => _TaqamScreenState();
}

class _TaqamScreenState extends State<TaqamScreen> {

  @override
  void initState() {
    super.initState();
    _navigateToHomeScreen();
  }

  Future<void> _navigateToHomeScreen() async {
    await Future.delayed(Duration(seconds: 4)); // Wait for 3 seconds
    CashHelper.putbool(key: 'taqam', value: true).then((value) {
      Navaigatetofinsh(context, const OnbordingScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20,right: 20),
        child: Container(
          color: ColorsManager.mainBackgroundColor,
          child: Center(
            child: Image.asset('assets/images/transparent.png',fit: BoxFit.cover,), // Replace 'assets/your_image.png' with your image path
          ),
        ),
      ),
    );
  }
}
