import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/services/authService.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Username = TextEditingController();
  final Email = TextEditingController();
  final Password = TextEditingController();
  final cnfPassword = TextEditingController();
  final profilePic = TextEditingController();
  bool _isLoading = false;

  final authService = AuthService();

  File? selectedImage;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Scren"), centerTitle: true),
      body: Column(
        children: [
          GestureDetector(
            onTap: ()async{
              await authService.pickImage(context,(file){
                setState(() {
                  selectedImage = file;
                });
              });
            },
            child: CircleAvatar(
              radius: 45,
              backgroundImage: selectedImage != null ? FileImage(selectedImage!) : NetworkImage("https://cdn.pixabay.com/photo/2023/02/18/11/00/icon-7797704_640.png",),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          ),

          TextField(
            controller: Username,
            decoration: const InputDecoration(labelText: 'Enter your name'),
          ),
          TextField(
            controller: Email,
            decoration: const InputDecoration(labelText: 'Enter your email'),
          ),
          TextField(
            controller: Password,
            decoration: const InputDecoration(labelText: 'Enter your password'),
          ),
          TextField(
            controller: cnfPassword,
            decoration: const InputDecoration(
              labelText: 'Enter your confirm Password',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              authService.signUpWithEmailAndPassword(
                context,
                Username.text.trim(),
                Email.text.trim(),
                Password.text.trim(),
                selectedImage!
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0XFF24786D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an Account?"),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text("Sign in"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
