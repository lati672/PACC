import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../providers/authentication_provider.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../services/database_service.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<FriendsPage> {
  final db = FirebaseFirestore.instance;
  late AuthenticationProvider _auth;
  late DatabaseService _database;
  late String role;
  late String id;

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    String userid = _auth.user.uid;
    print('the user id is $userid');
    return Scaffold(
      appBar: AppBar(
        title: const Text("好友"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _auth.user.role == 'Parent'
            ? (db
                .collection('Parent-Student')
                .where('parentid', isEqualTo: userid)
                .snapshots())
            : (db
                .collection('Parent-Student')
                .where('studentid', isEqualTo: userid)
                .snapshots()),
        builder: (context, snapshot) {
          print('dont have data');
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            print('have data');

            return ListView(
              children: snapshot.data!.docs.map((doc) {
                return Card(
                  child: ListTile(
                    title: Text(
                      'parent id:' +
                          (doc.data() as dynamic)['parentid'] +
                          '       student id:' +
                          (doc.data() as dynamic)['studentid'],
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
