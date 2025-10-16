import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/dashboard.dart';

class AuthService {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseStorage _storage = FirebaseStorage.instance;

    final ImagePicker _picker = ImagePicker();

    File? _image;

    Future<void> pickImage(BuildContext context,Function(File?) onImagePicked) async {
        try {
            final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
                _image = File(pickedFile.path);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Image selected successfully!")),
                );
                onImagePicked(_image);
            } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No image selected")),
                );
            }
        } catch (e) {
            print("Image pick error: $e");
        }
    }

    Future<String> uploadProfilePic(String uid) async {
        if (_image == null) {
            print("No image selected!");
            return '';
        }

        try {
            final ref = _storage.ref().child('profilePics/$uid');
            await ref.putFile(_image!);
            final imageUrl = await ref.getDownloadURL();
            print("Uploaded Image URL: $imageUrl");
            return imageUrl;
        } catch (e) {
            print("Image upload error: $e");
            return '';
        }
    }


    Future<void> signUpWithEmailAndPassword(
        BuildContext context, String username, String email, String password,File imageFile) async {
        try {
            UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(email: email, password: password);
            final uid = userCredential.user!.uid;

            String imageUrl = '';
            if(imageUrl != null){
                imageUrl = await uploadProfilePic(uid);
            }

            if (imageUrl.isNotEmpty) {
                await userCredential.user!.updatePhotoURL(imageUrl);
            }

            await _firestore.collection('users').doc(uid).set({
                'uid': uid,
                'username': username,
                'email': email,
                'profilePic': imageUrl,
                'createdAt': Timestamp.now(),
            });

            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Account created successfully!"),
                    backgroundColor: Colors.green,
                ),
            );

            Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard()));
        } on FirebaseAuthException catch (e) {
            String message = "";
            if (e.code == "email-already-in-use") {
                message = "Email already registered!";
            } else if (e.code == "invalid-email") {
                message = "Invalid email format!";
            } else {
                message = e.message ?? "Signup failed!";
            }
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
        } catch (e) {
            print("error: $e");
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("error: $e"), backgroundColor: Colors.red),
            );
        }
    }
    Future<void> signInWithEmailAndPassword(
        BuildContext context, String email, String password) async {
        if (email.isEmpty || password.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Email and password are required!")),
            );
            return;
        }

        try {
            UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(email: email, password: password);
            final user = userCredential.user!;
            await _firestore.collection('users').doc(user.uid).set({
                'email': email,
                'lastLogin': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Logged in successfully!"),
                    backgroundColor: Colors.green,
                ),
            );
        } on FirebaseAuthException catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${e.message}"), backgroundColor: Colors.red),
            );
        } catch (e) {
            print("Login error: $e");
        }
    }
}
