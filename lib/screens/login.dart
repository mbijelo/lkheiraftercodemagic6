import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/other_config.dart';
import 'package:active_ecommerce_flutter/social_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/intl_phone_input.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:active_ecommerce_flutter/addon_config.dart';
import 'package:active_ecommerce_flutter/screens/registration.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:active_ecommerce_flutter/screens/password_forget.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:active_ecommerce_flutter/screens/login_screen.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:active_ecommerce_flutter/l10n/app_localizations.dart';


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plain_notification_token/plain_notification_token.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _login_by = "phone"; //phone or email
  String initialCountry = 'MR';
  PhoneNumber phoneCode = PhoneNumber(isoCode: 'MR', dialCode: "+222");
  String _phone = "";
  bool  showLoading = false;








  //controllers
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();

  }





  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onPressedLogin() async {

    setState(() {
      showLoading = true;
    });


    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();

    if (_login_by == 'email' && email == "") {
      ToastComponent.showDialog(AppLocalizations.of(context).login_screen_email_warning, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      setState(() {
        showLoading = false;
      });
      return;
    } else if (_login_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(AppLocalizations.of(context).login_screen_phone_warning, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
          setState(() {showLoading = false;});
      return;
    } else if (password == "") {
      ToastComponent.showDialog(AppLocalizations.of(context).login_screen_password_warning, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
          setState(() {showLoading = false;});
      return;
    }

    var loginResponse = await AuthRepository()
        .getLoginResponse(_login_by == 'email' ? email : _phone, password);

    if (loginResponse.result == false) {
      ToastComponent.showDialog(loginResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      setState(() {showLoading = false;});
    } else {
      if(loginResponse.message == "Vous êtes connecté(e)s.") {
        ToastComponent.showDialog(AppLocalizations.of(context).vousetesconnecte, context,
            gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
        AuthHelper().setUserData(loginResponse);
      }

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
          print("--fcm token--");
          print(fcmToken);
          if (is_logged_in.$ == true) {
            // update device token
            var deviceTokenUpdateResponse = await ProfileRepository()
                .getDeviceTokenUpdateResponse(fcmToken);
          }
        }
      }

      //push norification ends

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Main();
      }));
    }

  }

  onPressedFacebookLogin() async {
    final facebookLogin = FacebookLogin();
    final facebookLoginResult = await facebookLogin.logIn(['email']);

    /*print(facebookLoginResult.accessToken);
    print(facebookLoginResult.accessToken.token);
    print(facebookLoginResult.accessToken.expires);
    print(facebookLoginResult.accessToken.permissions);
    print(facebookLoginResult.accessToken.userId);
    print(facebookLoginResult.accessToken.isValid());

    print(facebookLoginResult.errorMessage);
    print(facebookLoginResult.status);*/

    final token = facebookLoginResult.accessToken.token;

    /// for profile details also use the below code
    Uri url = Uri.parse('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
    final graphResponse = await http.get(url);
    final profile = json.decode(graphResponse.body);
    //print(profile);
    /*from profile you will get the below params
    {
     "name": "Iiro Krankka",
     "first_name": "Iiro",
     "last_name": "Krankka",
     "email": "iiro.krankka\u0040gmail.com",
     "id": "<user id here>"
    }*/

    var loginResponse = await AuthRepository().getSocialLoginResponse(
        profile['name'], profile['email'], profile['id'].toString());

    if (loginResponse.result == false) {
      ToastComponent.showDialog(loginResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    } else {
      ToastComponent.showDialog(loginResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      AuthHelper().setUserData(loginResponse);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Main();
      }));
    }
  }

  onPressedGoogleLogin() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        // you can add extras if you require
      ],
    );

    _googleSignIn.signIn().then((GoogleSignInAccount acc) async {
      GoogleSignInAuthentication auth = await acc.authentication;
      print(acc.id);
      print(acc.email);
      print(acc.displayName);
      print(acc.photoUrl);

      acc.authentication.then((GoogleSignInAuthentication auth) async {
        print(auth.idToken);
        print(auth.accessToken);

        //---------------------------------------------------
        var loginResponse = await AuthRepository().getSocialLoginResponse(
            acc.displayName, acc.email, auth.accessToken);

        if (loginResponse.result == false) {
          ToastComponent.showDialog(loginResponse.message, context,
              gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
        } else {
          ToastComponent.showDialog(loginResponse.message, context,
              gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
          AuthHelper().setUserData(loginResponse);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Main();
          }));
        }

        //-----------------------------------
      });
    });
  }







  @override
  Widget build(BuildContext context) {
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,

        body: Stack(
          children: [
            Container(
              width: _screen_width * (3 / 4),
              child: Image.asset(
                  "assets/splash_login_registration_background_image.png"),
            ),
            Container(
              width: double.infinity,
              child: SingleChildScrollView(
                  child: showLoading ?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 0.0, bottom: 0),
                          child: Container(
                           // width:10,
                            height: (MediaQuery.of(context).size.height) / 3,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0, bottom: 15),
                          child: Container(
                            width: 75,
                            height: 75,
                            child:
                            CircularProgressIndicator(),
                          ),
                        ),
                  ],

                  )
                  :Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [












                  AppBar(
                    backgroundColor: Colors.white,
                    centerTitle: true,
                    leading: Builder(
                      builder: (context) => IconButton(
                        icon: Icon(Icons.arrow_back, color: MyTheme.black),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    elevation: 0.0,
                    titleSpacing: 0,
                  ),








                  Padding(
                    padding: const EdgeInsets.only(top: 00.0, bottom: 15),
                    child: Container(
                      width: 75,
                      height: 75,
                      child:
                          Image.asset('assets/login_registration_form_logo.png'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      "${AppLocalizations.of(context).login_screen_login_to} " + AppConfig.app_name,
                      style: TextStyle(
                          color: MyTheme.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  Container(
                    width: _screen_width * (3 / 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            _login_by == "email" ? AppLocalizations.of(context).login_screen_email : AppLocalizations.of(context).registration_screen_phone,
                            style: TextStyle(
                                color: MyTheme.brown, fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (_login_by == "email")
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  height: 36,
                                  child: TextField(
                                    controller: _emailController,
                                    autofocus: false,
                                    decoration:
                                        InputDecorations.buildInputDecoration_1(
                                            hint_text: "abcd@example.com"),
                                  ),
                                ),
                                AddonConfig.otp_addon_installed
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _login_by = "phone";
                                          });
                                        },
                                        child: Text(
                                            AppLocalizations.of(context).login_screen_or_login_with_phone,
                                          style: TextStyle(
                                              color: MyTheme.accent_color,
                                              fontStyle: FontStyle.italic,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  height: 36,
                                  child: CustomInternationalPhoneNumberInput(
                                    onInputChanged: (PhoneNumber number) {
                                      print(number.phoneNumber);
                                      setState(() {
                                        _phone = number.phoneNumber;
                                      });
                                    },
                                    onInputValidated: (bool value) {
                                      print(value);
                                    },
                                    selectorConfig: SelectorConfig(
                                      selectorType: PhoneInputSelectorType.DIALOG,
                                    ),
                                    ignoreBlank: false,
                                    autoValidateMode: AutovalidateMode.disabled,
                                    selectorTextStyle:
                                        TextStyle(color: MyTheme.font_grey),
                                    textStyle:
                                        TextStyle(color: MyTheme.font_grey),
                                    initialValue: phoneCode,
                                    textFieldController: _phoneNumberController,
                                    formatInput: true,
                                    keyboardType: TextInputType.numberWithOptions(
                                        signed: true, decimal: true),
                                    inputDecoration: InputDecorations
                                        .buildInputDecoration_phone(
                                            hint_text: AppLocalizations.of(context).login_screen_phone_warning),
                                    onSaved: (PhoneNumber number) {
                                      print('On Saved: $number');
                                    },
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    /*
                                    setState(() {
                                      _login_by = "email";
                                    });
                                    */
                                  },
                                  child: Text(
                                   // AppLocalizations.of(context).login_screen_or_login_with_email,
                                    "",
                                    style: TextStyle(
                                        color: MyTheme.accent_color,
                                        fontStyle: FontStyle.italic,
                                        decoration: TextDecoration.underline),
                                  ),
                                )
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            "Password",
                            style: TextStyle(
                                color: MyTheme.brown, fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                height: 36,
                                child: TextField(
                                  controller: _passwordController,
                                  autofocus: false,
                                  obscureText: true,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  decoration:
                                      InputDecorations.buildInputDecoration_1(
                                          hint_text: "• • • • • • • •"),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  /*
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return PasswordForget();
                                  }));
                                  */
                                },
                                child: Text(
                                    //AppLocalizations.of(context).login_screen_forgot_password,
                                  "",
                                  style: TextStyle(
                                      color: MyTheme.brown, fontSize: 2,
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.underline),
                                ),
                              )
                            ],
                          ),
                        ),






















                        Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: MyTheme.textfield_grey, width: 1),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0))),
                            child: FlatButton(
                              minWidth: MediaQuery.of(context).size.width,
                              //height: 50,
                              color: MyTheme.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12.0))),
                              child: Text(
                                AppLocalizations.of(context).login_screen_log_in,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                              onPressed: () {
                                onPressedLogin();
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Center(
                              child: Text(
                                AppLocalizations.of(context).login_screen_or_create_new_account,
                            style: TextStyle(
                                color: MyTheme.black, fontSize: 16),
                          )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: MyTheme.textfield_grey, width: 1),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0))),
                            child: FlatButton(
                              minWidth: MediaQuery.of(context).size.width,
                              //height: 50,
                              color: MyTheme.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12.0))),
                              child: Text(
                                AppLocalizations.of(context).login_screen_sign_up,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                      return LoginScreen();
                                  //return Registration();
                                }));
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: SocialConfig.allow_google_login ||
                              SocialConfig.allow_facebook_login,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Center(
                                child: Text(
                                  AppLocalizations.of(context).login_screen_login_with,
                              style: TextStyle(
                                  color: MyTheme.medium_grey, fontSize: 14),
                            )),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Center(
                            child: Container(
                              width: 120,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Visibility(
                                    visible: SocialConfig.allow_google_login,
                                    child: InkWell(
                                      onTap: () {
                                        onPressedGoogleLogin();
                                      },
                                      child: Container(
                                        width: 28,
                                        child:
                                            Image.asset("assets/google_logo.png"),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: SocialConfig.allow_facebook_login,
                                    child: InkWell(
                                      onTap: () {
                                        onPressedFacebookLogin();
                                      },
                                      child: Container(
                                        width: 28,
                                        child: Image.asset(
                                            "assets/facebook_logo.png"),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: false,
                                    child: InkWell(
                                      onTap: () {
                                        // onPressedTwitterLogin();
                                      },
                                      child: Container(
                                        width: 28,
                                        child: Image.asset(
                                            "assets/twitter_logo.png"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )),
            )
          ],
        ),
      ),
    );
  }
}
