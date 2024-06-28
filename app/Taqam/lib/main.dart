import 'dart:developer';
import 'dart:io';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:taqam/modules/ta2m_Chats_screen/Chats_screen.dart';
import 'package:taqam/modules/ta2m_DetailsChat_screen/DetailsChat_screen.dart';
import 'package:taqam/modules/ta2m_EditPost_screen/cubit/cubit.dart';
import 'package:taqam/modules/ta2m_Onboarding_screen/taqam_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:taqam/modules/ta2m_Search_screen/ProductsSearch_screen.dart';
import 'package:taqam/modules/ta2m_Sell_screen/Sell_screen.dart';
import 'package:taqam/modules/ta2m_chats_module/api/apis.dart';
import 'package:taqam/shared/component/componanets.dart';
import 'package:taqam/shared/network/dependency_injection.dart';
import 'package:taqam/shared/style/color.dart';
import 'firebase_options.dart';

import 'package:taqam/shared/BlocObserver.dart';
import 'package:taqam/shared/maincubit/cubit.dart';
import 'package:taqam/shared/maincubit/states.dart';
import 'package:taqam/shared/network/local/Cash_helper.dart';
import 'package:taqam/shared/network/remote/dio_helper.dart';


import 'generated/l10n.dart';
import 'layout/ta2m_layout_screen/ta2m_Layout_screen.dart';
import 'modules/ta2m_Account_screen/cubit/cubit.dart';
import 'modules/ta2m_Chats_screen/cubit/cubit.dart';
import 'modules/ta2m_Home_screen/cubit/cubit.dart';
import 'modules/ta2m_Login_screen/login_cubit/login_cubit.dart';
import 'modules/ta2m_Login_screen/login_screen.dart';
import 'modules/ta2m_MyAds_screen/cubit/cubit.dart';
import 'modules/ta2m_Onboarding_screen/Onboarding_screen.dart';
import 'modules/ta2m_OtherProfile_screen/cubit/cubit.dart';
import 'modules/ta2m_ProductDetails_screen/cubit/cubit.dart';
import 'modules/ta2m_Register_screen/register_cubit/register_cubit.dart';
import 'modules/ta2m_Search_screen/cubit/cubit.dart';
import 'modules/ta2m_Sell_screen/cubit/cubit.dart';

late Size mq;

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DependencyInjection.init();
  Bloc.observer = MyBlocObserver();
  await DioHelperPayment.init();
  await CashHelper.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    androidProvider: AndroidProvider.debug,
    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Device Check provider
    // 3. App Attest provider
    // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    appleProvider: AppleProvider.appAttest,
  );
  var result = await FlutterNotificationChannel.registerNotificationChannel(
      description: 'For Showing Message Notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats');
  log('\nNotification Channel Result: $result');
  bool taqam = CashHelper.getbool(key: 'taqam')??false;
  bool onboarding = CashHelper.getbool(key: 'onboarding')??false;
  bool isSigned =  CashHelper.getbool(key: 'signed')??false;
  UidTokenSave = CashHelper.getdata(key: 'uId');
  Widget? widget;
  if(isSigned){
    widget = Ta2mLayoutScreen();
  }
  else if(onboarding){
    widget=LoginScreen();
  }
  else if(taqam){
    widget=OnbordingScreen();
  }
  else{
    widget=TaqamScreen();
  }

  runApp(
      MyApp( wid: widget,));
  exitCallBack();
}

void exitCallBack() {
  ProcessSignal.sigterm.watch().listen((_) async {
    // This code will be executed when the app is terminated
    await updateActiveStatus(false);
  });
}

class MyApp extends StatefulWidget {
  final Widget wid;
  const MyApp({super.key,  required this.wid});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size; // Initialize mq here
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AppCubit()),
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => RegisterCubit()),
        BlocProvider(create: (context) => SellCubit()..getNumberOfPosts()),
        BlocProvider(create: (context) => SearchCubit()),
        BlocProvider(create: (context) => ProductCubit()),
        BlocProvider(create: (context) => OtherProfileCubit()),
        BlocProvider(create: (context) => MyAdsCubit()..getAllMyPosts()),
        BlocProvider(create: (context) => HomeCubit()..getAllPosts()),
        BlocProvider(create: (context) => ChatCubit()),
        BlocProvider(create: (context) => AccountCubit()..getUserData()),
        BlocProvider(create: (context) => EditPostCubit()),
      ],
      child: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {},
        builder: (context, state) {
          return GetMaterialApp(
            key: const Key('en'),
            locale: const Locale('en'),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            debugShowCheckedModeBanner: false,
            home: widget.wid,
            theme: ThemeData(
              primaryColor: ColorsManager.mainColor, // Main color
              backgroundColor: ColorsManager.mainBackgroundColor, // Background color
              scaffoldBackgroundColor: ColorsManager.mainBackgroundColor, // Background color for scaffold
              colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: const Color(0xFF717171),
              ),
              appBarTheme: const AppBarTheme(elevation: 0, backgroundColor: Color(0xFFD4D4D4),),
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: ColorsManager.mainColor, // Main color
              backgroundColor: ColorsManager.mainBackgroundColor, // Background color
              scaffoldBackgroundColor: ColorsManager.mainBackgroundColor, // Background color for scaffold
              colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: const Color(0xFF717171), // Secondary color
              ),
            ),
            themeMode: ThemeMode.light,
          );
        },
      ),
    );
  }
}


