import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Home_page.dart';
import 'login_page.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<SigninPage> {
  bool isPasswordObscured = true;

  bool isLoading = false;
  bool pageInitialized = false;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  ///creating Username and Password Controller.
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController cpassword = TextEditingController();

  // Getter methods for trimmed values
  String getTrimmedUsername() {
    return username.text.trim();
  }

  String getTrimmedPassword() {
    return password.text.trim();
  }

  // sign user in method for login
  void SignIn() async {
    print("Email: ${username.text}");
    print("Password: ${password.text}");

    // loading
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    try {
      // Sign in
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: username.text,
        password: password.text,
      );

      // pop close the loading
      Navigator.pop(context);

      // Navigate to the home page on successful sign-in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // pop close the loading
      Navigator.pop(context);

      showGenericErrorMsg(e.code);

      // if (e.code == 'user-not-found') {
      //   // Wrong emial id
      //   print(' no user found email id');
      //
      //   // error display for wrong email id
      //   wrongEmailmsg(context);
      // } else if (e.code == 'wrong-password') {
      //   // wrong password
      //   print('wrong password');
      //
      //   // error dispaly for wrong emial id
      //   wrongPwdmsg(context);
      // } else {
      //   // Handle other login errors
      //   print("Error signing in: $e");
      //
      //   // You can display a generic error message or handle specific error codes as needed
      //   //showGenericErrorMsg(context);
      // }

      print("Error signing in: $e");
    }
  }

// Logic for wrong email error
  void wrongEmailmsg(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text("Wrong Email ID..!"),
        );
      },
    );
  }

// Logic for wrong password error
  void wrongPwdmsg(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text("Wrong Password..!"),
        );
      },
    );
  }

  // Logic for generic error message
  void showGenericErrorMsg(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            message,
          ),
          // Text("An error occurred during login. Please try again."),
        );
      },
    );
  }

  @override
  void initState() {
    initializeFirebase();
    checkIfUserLoggedIn();
    super.initState();
  }

  // Initialize Firebase
  initializeFirebase() async {
    await Firebase.initializeApp().whenComplete(() {
      setState(() {});
    });
  }

  // Check if the user is already logged in
  checkIfUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool userLoggedIn = (prefs.getString('id') != null);

    if (userLoggedIn) {
      // If the user is logged in, navigate to the home page
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => HomePage()));
    } else {
      // If the user is not logged in, show the login UI
      setState(() {
        pageInitialized = true;
      });
    }
  }

  // Handle Google Sign-In
  handleSignIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      // Start the Google Sign-In process
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // Sign in to Firebase with Google credentials
        final UserCredential authResult =
            await firebaseAuth.signInWithCredential(credential);
        final User? firebaseUser = authResult.user;

        if (firebaseUser != null) {
          // Check if the user is already in the Firestore database
          final results = (await FirebaseFirestore.instance
                  .collection('users')
                  .where('id', isEqualTo: firebaseUser.uid)
                  .get())
              .docs;

          if (results.isEmpty) {
            // User not in the Firestore database, add them
            await FirebaseFirestore.instance
                .collection('users')
                .doc(firebaseUser.uid)
                .set({
              "id": firebaseUser.uid,
              "name": firebaseUser.displayName,
              "created_at": DateTime.now(),
            });

            // Save user information in SharedPreferences
            prefs.setString('id', firebaseUser.uid);
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => HomePage(),
            ));
          } else {
            // User found in the Firestore database
            prefs.setString('id', results[0]['id']);
            prefs.setString('name', results[0]['name']);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) => HomePage(),
              ),
            );
          }
        }
      }
    } catch (error) {
      print('Error during Google Sign-In: $error');
      // Handle error, e.g., show a snackbar or dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.blue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // logo
                const Icon(
                  Icons.create_new_folder_outlined,
                  size: 100,
                ),

                const SizedBox(height: 10),

                // welcome back, you've been missed!
                const Text(
                  " Signin Page",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 15),

                Form(
                  child: Builder(builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: username,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              hintText: 'Username',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (CurrentValue) {
                              var nonNullValue = CurrentValue ?? '';
                              if (nonNullValue.isEmpty) {
                                return ("Username is required");
                              }
                              if (!nonNullValue.contains("@")) {
                                return ("Username should contain @");
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 30,
                          ),

                          // PWD
                          TextFormField(
                            controller: password,
                            obscureText: isPasswordObscured,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              hintText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isPasswordObscured = !isPasswordObscured;
                                  });
                                },
                                icon: Icon(
                                  isPasswordObscured
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: isPasswordObscured
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (PassCurrentValue) {
                              RegExp regex = RegExp(
                                  r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
                              var passNonNullValue = PassCurrentValue ?? "";
                              if (passNonNullValue.isEmpty) {
                                return ("Password is required");
                              } else if (passNonNullValue.length < 6) {
                                return ("Password must be more than 5 characters");
                              } else if (!regex.hasMatch(passNonNullValue)) {
                                return ("Password should contain upper, lower, digit, and special character");
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 30,
                          ),

                          // CPWD
                          TextFormField(
                            controller: cpassword,
                            obscureText: isPasswordObscured,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              hintText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isPasswordObscured = !isPasswordObscured;
                                  });
                                },
                                icon: Icon(
                                  isPasswordObscured
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: isPasswordObscured
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (cPassCurrentValue) {
                              RegExp regex = RegExp(
                                  r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
                              var cPassNonNullValue = cPassCurrentValue ?? "";
                              if (cPassNonNullValue.isEmpty) {
                                return "Password is required";
                              } else if (cPassNonNullValue.length < 6) {
                                return "Password must be more than 5 characters";
                              } else if (!regex.hasMatch(cPassNonNullValue)) {
                                return "Password should contain upper, lower, digit, and special character";
                              }

                              // Check if passwords match
                              if (cPassNonNullValue != password.text) {
                                return 'Passwords do not match';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),

                          Container(
                            height: 50,
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // Adjust the radius as needed
                                ),
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                              onPressed: () async {
                                // Validate the form
                                if (Form.of(context)?.validate() ?? false) {
                                  // Call the LoginIn function
                                  SignIn();
                                }
                              },
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color:
                                      Colors.white, // Set text color to white
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 10),

                // or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // google + apple sign in buttons
                pageInitialized
                    ? Center(
                        child: InkWell(
                          onTap: handleSignIn,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                            ),
                            child: SvgPicture.asset(
                              'assets/IMG/google.svg',
                              height: 50,
                              width: 50,
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: SizedBox(
                          height: 36,
                          width: 36,
                          child: CircularProgressIndicator(),
                        ),
                      ),

                const SizedBox(height: 10),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already member?',
                      style: TextStyle(color: Colors.black),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return const LoginPage();
                          }),
                        );
                      },
                      child: const Text("Login now"),
                    ),
                    const SizedBox(height: 20),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
