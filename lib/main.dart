import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'MAP/map_page.dart';
import 'auth/firebase_options.dart';
import 'auth/splash_page.dart';
import 'page/login_or_signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      title: 'Road Safety App',
        home: SplashScreen(),
      // home: LoginorSignin(),
    );
  }
}


