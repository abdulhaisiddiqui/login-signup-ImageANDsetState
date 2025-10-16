import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/dashboard.dart';
import 'package:myapp/services/authService.dart';

import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController Email = TextEditingController();
  final TextEditingController Password = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void signIn() async {
    if (Password.text.isEmpty || Email.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Feild is required")));
    }

    final authService = AuthService();

    try {
      await authService.signInWithEmailAndPassword(context,Email.text, Password.text);

      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection("users").doc(currentUser.uid).set({
          "uid": currentUser.uid,
          "email": currentUser.email,
          "lastLogin": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login successful"),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("User Not Found")));
      } else if (e.code == "wrong-password") {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Incorrect Password")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Sign In Failed ${e.message}")));
      }
    } catch (e) {
      print("Error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login"), centerTitle: true),
      body: Column(
        children: [
          TextField(
            controller: Email,
            decoration: const InputDecoration(labelText: 'Enter your email'),
          ),
          TextField(
            controller: Password,
            decoration: const InputDecoration(labelText: 'Enter your Password'),
          ),
          ElevatedButton(onPressed: signIn, child: Text('Sign In')),
        ],
      ),
    );
  }
}
