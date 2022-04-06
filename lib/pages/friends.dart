import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../providers/authentication_provider.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../services/database_service.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key, required this.role}) : super(key: key);
  final String role;
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<FriendsPage> {
  final db = FirebaseFirestore.instance;
  late AuthenticationProvider _auth;
  late DatabaseService _database;
  late String role;
  late String id;
  Widget Parentbuilder() {
    String userid = _auth.user.uid;
    List<String> names = [];
    return Scaffold(
      appBar: AppBar(
        title: const Text("您的孩子"),
        centerTitle: true,
      ),
      body: StreamBuilder<String>(
        stream: _database.getStudentsnameStream(_auth.user.uid),
        builder: (context, name) {
          if (!name.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            names.add(name.data!);
            return ListView.builder(
              itemCount: names.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(names[index]),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget StudentBuilder() {
    List<String> names = [];
    String userid = _auth.user.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text("您的家长"),
        centerTitle: true,
      ),
      body: StreamBuilder<String>(
        stream: _database.getParentsnameStream(_auth.user.uid),
        builder: (context, name) {
          if (!name.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            names.add(name.data!);
            return ListView.builder(
              itemCount: names.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(names[index]),
                );
              },
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    role = widget.role;
    _auth = Provider.of<AuthenticationProvider>(context);
    _database = GetIt.instance.get<DatabaseService>();
    String userid = _auth.user.uid;
    if (role == 'Parent') {
      return Parentbuilder();
    } else {
      return StudentBuilder();
    }
    /*
    return Scaffold(
      appBar: AppBar(
        title: role == 'Parent' ? const Text("您的孩子") : const Text("您的家长"),
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
    );*/
  }
}
