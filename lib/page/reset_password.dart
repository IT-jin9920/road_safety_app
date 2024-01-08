
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'NewPasswordScreen.dart';
import 'login_page.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // final emailController = TextEditingController();
  String message = '';
  bool isEmailEntered = false;

  Future<void> resetPassword(String emailController) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.trim());
      // Show a success message or navigate to a success screen
      print("Password reset email sent successfully");

      // Close the current screen
      Navigator.pop(context);

      // Display a pop-up message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Done"),
            content: const Text("Password reset email sent successfully"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Navigator.pop(context);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Show an error message
      print("Error sending password reset email: $e");
    }
  }

  void validateEmail(String enteredEmail) {
    setState(() {
      isEmailEntered = enteredEmail.isNotEmpty;
      if (isEmailEntered) {
        if (EmailValidator.validate(enteredEmail)) {
          message = ''; // Clear the message if email is valid
        } else {
          message = 'Invalid email format';
        }
      } else {
        message = ''; // Clear the message if no email is entered
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              onChanged: (enteredEmail) => validateEmail(enteredEmail),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintText: 'Enter your email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 5),
            // Display the message only when email is entered
            if (isEmailEntered) Text(message),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? true) {
                  // Form is valid, perform the reset password operation
                  resetPassword(emailController.text);
                }
                // resetPassword(emailController.text);
              },
              child: const Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}
