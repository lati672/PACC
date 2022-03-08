import 'dart:async';

// Packages
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Services
import '../services/database_service.dart';

// Providers
import '../providers/authentication_provider.dart';

// Models
import '../models/chat_message_model.dart';
import '../models/chat_user_model.dart';
import '../models/chats_model.dart';

class UsersProvider extends ChangeNotifier {
  UsersProvider(this._auth) {
    _database = GetIt.I.get<DatabaseService>();
    getUsers();
  }
  final AuthenticationProvider _auth;

  late DatabaseService _database;

  List<ChatUserModel>? users;

  late StreamSubscription _usersStream;

// * Once not longer needed, it will be disposed
  @override
  void dispose() {
    super.dispose();
  }

//* Getting the chats
  void getUsers() async {
    try {
      final _userSnapshot = await _database.getUsers();
      _userSnapshot.docs.forEach((doc) {
        print(doc['name']);
      });
    } catch (error) {
      debugPrint('Error getting users.');
      debugPrint('$error');
    }
  }
}
