
import 'package:flutter/material.dart';

import 'login_page.dart';
import 'signin_page.dart';

class LoginorSignin extends StatefulWidget {
  const LoginorSignin({super.key});

  @override
  State<LoginorSignin> createState() => _LoginorSigninState();
}

class _LoginorSigninState extends State<LoginorSignin> {

  // Show login page or not
  bool ShowLogionPage = true;

  // toggle between login ither sign in
  void toggalePage(){
    setState(() {
      ShowLogionPage = !ShowLogionPage;
    });
  }

  @override
  Widget build(BuildContext context) {

    if(ShowLogionPage) {
      return LoginPage();
    }
    else
      {
        return SigninPage();
      }
  }
}
