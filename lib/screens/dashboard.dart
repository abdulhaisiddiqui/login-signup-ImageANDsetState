import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/home.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? photoURL;

  bool isLiked = false;


  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard"), centerTitle: true,
      leading: IconButton(onPressed: (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
      }, icon: Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: [
          Text(
            currentUser != null
                ? "Logged in as: ${currentUser.email}"
                : "No user is logged in",
          ),
          StreamBuilder(stream: FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).snapshots(), builder: (context, snapshot){
            if(!snapshot.hasData){
              return CircleAvatar(
                radius: 45,
                backgroundImage: NetworkImage('https://cdn.pixabay.com/photo/2023/02/18/11/00/icon-7797704_640.png'),
              );
            }

            final userData = snapshot.data!.data() as Map<String ,dynamic>;
            final profilePic = userData['profilePic'] ?? '';

            return CircleAvatar(
              radius: 45,
              backgroundImage: NetworkImage(profilePic),
            );
          }),

          GestureDetector(
            onTap: (){
              setState(() {
                isLiked = !isLiked;
              });
            },
            child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.grey,
                size: 30,
              ),
          ),
          Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.grey,
            size: 30,
          ),
          Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.grey,
            size: 30,
          ),
        ],
      ),
    );
  }
}
