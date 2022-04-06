import 'package:chatifyapp/models/chat_user_model.dart';
import 'package:chatifyapp/models/chats_model.dart';
import 'package:chatifyapp/pages/parent_chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../providers/authentication_provider.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../services/database_service.dart';
import '../services/navigation_service.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key, required this.role}) : super(key: key);
  final String role;
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<FriendsPage> {
  final db = FirebaseFirestore.instance;
  late NavigationService _navigation;
  late AuthenticationProvider _auth;
  late DatabaseService _database;
  late String role;
  late String id;
  Widget Parentbuilder() {
    String userid = _auth.user.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text("您的孩子"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ChatUserModel>>(
        future: _database.getStudentsModel(_auth.user.uid),
        builder: (context, users) {
          if (!users.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<ChatUserModel> _users = List.from(users.data!);
            return ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                return TextButton(
                    onPressed: () async {
                      String chatid = await _database.getChatid(
                          _auth.user.uid, _users[index].uid);
                      ChatsModel _chat = await _database.getChatsbyChatId(
                          chatid, _auth.user.uid);
                      _navigation.navigateToPage(ParentChatPage(chat: _chat));
                    },
                    child: Text(
                      _users[index].name,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 15, 11, 11), fontSize: 20),
                    ));
              },
            );
          }
        },
      ),
    );
  }

  Widget StudentBuilder() {
    String userid = _auth.user.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text("您的家长"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ChatUserModel>>(
        future: _database.getParentsModel(_auth.user.uid),
        builder: (context, users) {
          if (!users.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<ChatUserModel> _users = List.from(users.data!);
            return ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                return TextButton(
                    onPressed: () async {
                      String chatid = await _database.getChatid(
                          _auth.user.uid, _users[index].uid);
                      ChatsModel _chat = await _database.getChatsbyChatId(
                          chatid, _auth.user.uid);
                      _navigation.navigateToPage(ParentChatPage(chat: _chat));
                    },
                    child: Text(
                      _users[index].name,
                      style: const TextStyle(color: Colors.black, fontSize: 20),
                    ));
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
    _navigation = GetIt.instance.get<NavigationService>();
    _auth = Provider.of<AuthenticationProvider>(context);
    _database = GetIt.instance.get<DatabaseService>();
    String userid = _auth.user.uid;
    if (role == 'Parent') {
      return Parentbuilder();
    } else {
      return StudentBuilder();
    }
  }
}
