import 'package:active_ecommerce_flutter/other_config.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/screens/splash.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:shared_value/shared_value.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'dart:async';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'app_config.dart';
import 'package:active_ecommerce_flutter/services/push_notification_service.dart';
import 'package:one_context/one_context.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:active_ecommerce_flutter/providers/locale_provider.dart';
import 'package:active_ecommerce_flutter/services/navigation_service.dart';
import 'l10n/app_localizations.dart';
import 'lang_config.dart';
import 'package:firebase_core/firebase_core.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  fetch_user() async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    // push notification starts
    if (OtherConfig.USE_PUSH_NOTIFICATION) {
      final FirebaseMessaging _fcm = FirebaseMessaging.instance;

      await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );


      String fcmToken = await _fcm.getToken();
      if (fcmToken != null) {
        print("--fcm token main main main --");
        print(fcmToken);



        var userByTokenResponse = await AuthRepository().getUserByTokenResponse1(fcmToken);
        print(userByTokenResponse.result.toString() + 'jean');
        if (userByTokenResponse.result == true) {
          is_logged_in.$ = true;
          is_logged_in.save();
          user_id.$ = userByTokenResponse.id;
          user_id.save();
          user_name.$ = userByTokenResponse.name;
          user_name.save();
          user_name.$ = userByTokenResponse.email;
          user_name.save();
          user_phone.$ = userByTokenResponse.phone;
          user_phone.save();
          avatar_original.$ = userByTokenResponse.avatar_original;
          avatar_original.save();
        }
        else{
          print('PPPPPPPPPPPP888888888888888');
        }







      }
    }






  }// end fetch_user()

  app_language.load();
  app_mobile_language.load();
  app_language_rtl.load();

  access_token.load().whenComplete(() {
    fetch_user();
    print('888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888');
  });

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  runApp(
    SharedValue.wrapApp(
      MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    if (OtherConfig.USE_PUSH_NOTIFICATION) {
      /*
      Future.delayed(Duration(milliseconds: 100), () async {
        WidgetsFlutterBinding.ensureInitialized();
        await Firebase.initializeApp();
        PushNotificationService().initialise();
      });
      */

    }
  }



  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: Consumer<LocaleProvider>(builder: (context, provider, snapshot) {
          return MaterialApp(
            builder: OneContext().builder,
            navigatorKey: OneContext().navigator.key,
            title: AppConfig.app_name,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: MyTheme.white,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              accentColor: MyTheme.accent_color,
              /*textTheme: TextTheme(
              bodyText1: TextStyle(),
              bodyText2: TextStyle(fontSize: 12.0),
            )*/
              //
              // the below code is getting fonts from http
              textTheme: GoogleFonts.sourceSansProTextTheme(textTheme).copyWith(
                bodyText1:
                    GoogleFonts.sourceSansPro(textStyle: textTheme.bodyText1),
                bodyText2: GoogleFonts.sourceSansPro(
                    textStyle: textTheme.bodyText2, fontSize: 12),
              ),
            ),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate,
            ],
            locale: provider.locale,
            supportedLocales: LangConfig().supportedLocales(),
            home: Splash(),
            //home: Main(),
          );
        }));
  }
}
