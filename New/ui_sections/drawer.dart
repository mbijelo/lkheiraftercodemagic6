import 'package:active_ecommerce_flutter/l10n/app_localizations.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/screens/change_language.dart';
import 'package:active_ecommerce_flutter/screens/change_language_in_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:active_ecommerce_flutter/screens/profile.dart';
import 'package:active_ecommerce_flutter/screens/order_list.dart';
import 'package:active_ecommerce_flutter/screens/wishlist.dart';

import 'package:active_ecommerce_flutter/screens/login.dart';
import 'package:active_ecommerce_flutter/screens/messenger_list.dart';
import 'package:active_ecommerce_flutter/screens/wallet.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:active_ecommerce_flutter/screens/devab.dart';
import 'package:active_ecommerce_flutter/screens/deleteaccount.dart';
import 'package:toast/toast.dart';

import '../custom/toast_component.dart';


class MainDrawer extends StatefulWidget {
  const MainDrawer({
    Key key,
  }) : super(key: key);

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  onTapLogout(context) async {

    var logoutResponse = await AuthRepository().getLogoutResponse();

        /*
    if(logoutResponse.result == true){
         ToastComponent.showDialog(logoutResponse.message, context,
                   gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
         }
         */
    if(logoutResponse.result == true){

      /*
      ToastComponent.showDialog(logoutResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      */
      AuthHelper().clearUserData();

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Login();
      }));
    }

  }






  onTapLogout1(context) async {
    AuthHelper().clearUserData();

    /*
    var logoutResponse = await AuthRepository()
            .getLogoutResponse();


    if(logoutResponse.result == true){
         ToastComponent.showDialog(logoutResponse.message, context,
                   gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
         }
         */
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Login();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.5 ),
      child: Directionality(
        textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          padding: EdgeInsets.only(top: 20),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                is_logged_in.$ == true
                    ? ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            AppConfig.BASE_PATH + "${avatar_original.$}",
                          ),
                        ),
                    title: Text("${user_name.$}",style: TextStyle(
                            color: Colors.white,
                            )),
                        subtitle:
                            /*
                            user_email.$ != "" && user_email.$ != null
                                ? Text("${user_name.$}", style: TextStyle(
                                color: Colors.white,
                                ))
                                : Text("${user_phone.$}", style: TextStyle(
                                color: Colors.white,
                              */
                        Text("${user_phone.$}", style: TextStyle(
                          color: Colors.white,
                                )))
                    : Text(AppLocalizations.of(context).main_drawer_not_logged_in,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16)),


                Divider(color: Colors.white),
                ListTile(
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                    leading: Image.asset("assets/language.png",
                        height: 16, color: Colors.white),
                    title: Text(AppLocalizations.of(context).main_drawer_change_language,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,

                        )),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return ChangeLanguageInApp();
                          }));
                    }),
                Divider(color: Colors.white),






                ListTile(
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                    leading: Image.asset("assets/home.png",
                        height: 16, color: Colors.white),
                    title: Text(AppLocalizations.of(context).main_drawer_home,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16)),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Main();
                      }));
                    }),



                Divider(color: Colors.white) ,


                is_logged_in.$ == true
                    ? ListTile(
                        visualDensity:
                            VisualDensity(horizontal: -4, vertical: -4),
                        leading: Image.asset("assets/profile.png",
                            height: 16, color: Colors.white),
                        title: Text(AppLocalizations.of(context).main_drawer_profile,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14)),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Profile(show_back_button: true);
                          }));
                        })
                    : Container(),



                is_logged_in.$ == true ?
                Divider(color: Colors.white) :
                Container(),



                is_logged_in.$ == true
                    ? ListTile(
                        visualDensity:
                            VisualDensity(horizontal: -4, vertical: -4),
                        leading: Image.asset("assets/order.png",
                            height: 16, color: Colors.white),
                        title: Text(AppLocalizations.of(context).main_drawer_orders,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16)),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return OrderList(from_checkout: false);
                          }));
                        })
                    : Container(),


                is_logged_in.$ == true ?
                Divider(color: Colors.white) :
                Container(),



                is_logged_in.$ == true
                    ? ListTile(
                        visualDensity:
                            VisualDensity(horizontal: -4, vertical: -4),
                        leading: Image.asset("assets/heart.png",
                            height: 16, color: Colors.white),
                        title: Text(AppLocalizations.of(context).main_drawer_my_wishlist,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16)),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Wishlist();
                          }));
                        })
                    : Container(),


/*

                is_logged_in.$ == true ?
                Divider(color: Colors.white) :
                Container(),

*/
                /*
                (is_logged_in.$ == true)
                    ? ListTile(
                        visualDensity:
                            VisualDensity(horizontal: -4, vertical: -4),
                        leading: Image.asset("assets/chat.png",
                            height: 16, color: Colors.white),
                        title: Text(AppLocalizations.of(context).main_drawer_messages,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16)),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return MessengerList();
                          }));
                        })
                    : Container(),
                Divider(color: Colors.white),
                */

/*
                is_logged_in.$ == true
                    ? ListTile(
                        visualDensity:
                            VisualDensity(horizontal: -4, vertical: -4),
                        leading: Image.asset("assets/wallet.png",
                            height: 16, color: Colors.white),
                        title: Text(AppLocalizations.of(context).main_drawer_wallet,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16)),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Wallet();
                          }));
                        })
                    : Container(),
                Divider(color: Colors.white),
*/




                is_logged_in.$ == false
                    ? ListTile(
                        visualDensity:
                            VisualDensity(horizontal: -4, vertical: -4),
                        leading: Image.asset("assets/login.png",
                            height: 16, color: Colors.white),
                        title: Text(AppLocalizations.of(context).main_drawer_login,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16)),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Login();
                          }));
                        })
                    : Container(),
                Divider(color: Colors.white),
                is_logged_in.$ == true
                    ?
                ListTile(
                        visualDensity:
                            VisualDensity(horizontal: -4, vertical: -4),
                        leading: Image.asset("assets/logout.png",
                            height: 16, color: Colors.white),
                        title: Text(AppLocalizations.of(context).main_drawer_logout,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16)),
                        onTap: () {
                          onTapLogout(context);
                        })
                    : Container(),



                is_logged_in.$ == true ?
                Divider(color: Colors.white) :
                Container(),




                is_logged_in.$ == true
                    ?
                ListTile(
                    visualDensity:
                    VisualDensity(horizontal: -4, vertical: -4),
                    leading: Image.asset("assets/logout.png",
                        height: 16, color: Colors.white),
                    title: Text(AppLocalizations.of(context).supprimer_compte,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16)),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return deleteaccount(show_back_button: true);
                          }));
                    })
                    : Container(),





              ],
            ),
          ),
        ),
      ),
    );
  }
}
