
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../MAP/map_page.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
   HomePage({super.key});

   final user = FirebaseAuth.instance.currentUser;
   final GoogleSignIn googleSignIn = GoogleSignIn();

   Future<void> logOut(BuildContext context) async {
     try {
       // Google Sign out
       if (await googleSignIn.isSignedIn()) {
         await googleSignIn.signOut();
         print('User logged out from Google successfully');
       }

       // Firebase
       if (user != null) {
         await FirebaseAuth.instance.signOut();
         print('User logged out successfully');
       }

       // Clear SharedPreferences values
       SharedPreferences prefs = await SharedPreferences.getInstance();
       await prefs.clear();

       // Remove the current route if possible
       if (Navigator.canPop(context)) {
         Navigator.pop(context);
       }

       // Push the login page only if there are no other routes
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(
           builder: (context) => const LoginPage(),
         ),
       );
     } catch (e) {
       print('Error during logout: $e');
     }
   }


   @override
  Widget build(BuildContext context) {

    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Test Demo Login Home page"),
      //   actions: [
      //     IconButton(
      //       onPressed: () => logOut(context),
      //       icon: Icon(Icons.logout),
      //     ),
      //   ],
      // ),
      // body: Center(
      //   child: Text("Login Done.. : \n\n ${user.email}" ?? ""),
      // ),
      body: RoadSafetyApp(),
    );
  }
}
