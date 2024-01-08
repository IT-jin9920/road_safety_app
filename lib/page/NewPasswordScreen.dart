// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'login_page.dart';
//
// class NewPasswordScreen extends StatefulWidget {
//   final String email;
//
//   const NewPasswordScreen({Key? key, required this.email}) : super(key: key);
//
//   @override
//   _NewPasswordScreenState createState() => _NewPasswordScreenState();
// }
//
// class _NewPasswordScreenState extends State<NewPasswordScreen> {
//   final TextEditingController newPasswordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Set New Password"),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => LoginPage(),
//               ),
//             );
//           },
//           icon: Icon(Icons.arrow_back),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               TextFormField(
//                 controller: newPasswordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   hintText: 'Enter new password',
//                   prefixIcon: const Icon(Icons.lock),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'New password is required';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: confirmPasswordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   hintText: 'Confirm new password',
//                   prefixIcon: const Icon(Icons.lock),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Confirm password is required';
//                   }
//                   if (value != newPasswordController.text) {
//                     return 'Passwords do not match';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState?.validate() ?? false) {
//                     // Perform the password update operation
//                     updatePassword(
//                       widget.email,
//                       newPasswordController.text,
//                       'codeFromEmail', // Replace with the actual reset code
//                     );
//                   }
//                 },
//                 child: Text("Update Password"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> updatePassword(
//       String email,
//       String newPassword,
//       String resetCode,
//       ) async {
//     try {
//       // Use the email, newPassword, and resetCode to update the user's password
//       await FirebaseAuth.instance.confirmPasswordReset(
//         code: resetCode,
//         newPassword: newPassword,
//       );
//
//       // Show a success message or navigate to a success screen
//       print("Password updated successfully");
//
//       // Navigate back to the login page
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => LoginPage(),
//         ),
//       );
//     } catch (e) {
//       // Show an error message
//       print("Error updating password: $e");
//     }
//   }
// }
