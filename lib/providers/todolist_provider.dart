import 'dart:async';

// Packages
import 'package:chatifyapp/models/todo_list_model.dart';
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

class TodoListPageProvider extends ChangeNotifier {
  TodoListPageProvider(this._auth) {
    _database = GetIt.I.get<DatabaseService>();
    getTodos();
  }
  final AuthenticationProvider _auth;

  late DatabaseService _database;

  List<TodoListModel>? todos;

  late StreamSubscription _chatsStream;

// * Once not longer needed, it will be disposed
  @override
  void dispose() {
    super.dispose();
    _chatsStream.cancel();
  }

//* Getting the chats
  void getTodos() async {
    try {
      todos = await _database.getTodoList(_auth.user.name);
    } catch (error) {
      debugPrint('Error getting chats.');
      debugPrint('$error');
    }
  }
}
