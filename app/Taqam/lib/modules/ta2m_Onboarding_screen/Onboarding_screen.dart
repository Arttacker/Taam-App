import 'package:flutter/material.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../shared/component/componanets.dart';
import '../../shared/network/local/Cash_helper.dart';
import '../ta2m_Login_screen/login_screen.dart';
import '../ta2m_Register_screen/register_screen.dart';


class Onboarding_model {
  final String? image;

  final String? body;

  Onboarding_model({@required this.image, @required this.body});
}

class OnbordingScreen extends StatefulWidget {
  const OnbordingScreen({super.key});

  @override
  State<OnbordingScreen> createState() => _OnbordingScreenState();
}

class _OnbordingScreenState extends State<OnbordingScreen> {
  List<Onboarding_model> model = [
    Onboarding_model(
        image: 'assets/images/Sell.png',
        body:('SELL')),

    Onboarding_model(
        image: 'assets/images/Buy.png',
        body:('BUY')),

    Onboarding_model(
        image: 'assets/images/Deal.png',
        body:('MAKE A DEAL')),
  ];

  var textPageController = PageController();

  bool isLast = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    itemBuilder: (context, index) {
                      return buildBoardingItem(model[index]);
                    },
                    itemCount: model.length,
                    controller: textPageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) async {
                      if (index == model.length -1 ) {
                        setState(() {
                          isLast=true;
                        });
                      } else {
                        setState(() {
                          isLast=false;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            if (isLast) // Conditional rendering of IconButton
              Positioned(
                bottom: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_right, size: 30, color: Colors.white),
                    onPressed: () async {
                      await submit(context);
                    },
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }


  Widget buildBoardingItem(Onboarding_model model1) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 5, left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: AssetImage('${model1.image}'),
            width: MediaQuery.of(context).size.width, // Adjust this width as needed
            height: MediaQuery.of(context).size.height * 0.5, // Adjust this height as needed
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            '${model1.body}',
            style: TextStyle(
              fontSize: 50,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 40,
          ),
          SmoothPageIndicator(
              controller: textPageController,
              count: model.length,
              effect:  ExpandingDotsEffect(
                  dotColor: Colors.grey,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 5,
                  expansionFactor: 2,
                  activeDotColor: Theme.of(context).primaryColor )
          )
        ],
      ),
    );
  }

  Future<void> submit(context) async {
    await CashHelper.putbool(key: 'onboarding', value: true)
        .then((value) => {
      if (value == true)
        {
          Navigator.of(context).pop(),
          Navaigatetofinsh(context, LoginScreen())
        }
    });
  }
}