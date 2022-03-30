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
    //getTodos();
    listenToTodolists();
  }
  final AuthenticationProvider _auth;

  late DatabaseService _database;

  List<TodoListModel>? todos;

  late StreamSubscription _todosStream;

// * Once not longer needed, it will be disposed
  @override
  void dispose() {
    super.dispose();
    _todosStream.cancel();
  }

//* Getting the todos
  void listenToTodolists() {
    try {
      _todosStream = _database.getUserTodoList(_auth.user.uid).listen(
        (_snapshot) {
          List<TodoListModel> _todos = [];
          _snapshot.docs.forEach((doc) {
            _todos.add(TodoListModel(
                sent_time: doc['sent_time'].toDate(),
                senderid: doc['senderid'],
                status: doc['status'],
                start_time: doc['start_time'].toDate(),
                description: doc['description'],
                todolist_name: doc['todolist_name'],
                interval: doc['interval'],
                recipients: List.from(doc['recipients'])));
          });
          todos = _todos;
          notifyListeners();
        },
      );
    } catch (error) {
      debugPrint('$error');
    }
  }

  void getTodos() async {
    try {
      todos = await _database.getTodoList(_auth.user.name);
    } catch (error) {
      debugPrint('Error getting chats.');
      debugPrint('$error');
    }
  }
}
