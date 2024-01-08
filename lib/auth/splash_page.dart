import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import 'auth_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      checkConnectivity(); // Check every 10 seconds
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      showErrorDialog();
    } else {
      // Connected to the internet
      // Implement your logic here or navigate to the next screen
      print('Connected to the internet');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthPage(),
        ),
      );
    }
  }

  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("No Internet Connection"),
          content: Text("Please check your internet connection and try again."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Your Splash Screen Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
