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
    getStudents();
  }
  final AuthenticationProvider _auth;

  late DatabaseService _database;

  List<TodoListModel>? todos;
  List? todosID;
  List<String>? students;
  List<String>? studentsName;
  List<int>? studentsTodo;

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
          List? _todosID = [];
          _snapshot.docs.forEach((doc) {
            _todos.add(TodoListModel(
                sent_time: doc['sent_time'].toDate(),
                senderid: doc['senderid'],
                start_time: List.generate(doc['start_time'].length,
                    (index) => doc['start_time'][index].toDate()),
                status: List.from(doc['status']),
                description: doc['description'],
                todolist_name: doc['todolist_name'],
                interval: doc['interval'],
                recipients: List.from(doc['recipients']),
                recipientsName: List.from(doc['recipientsName'])));
            _todosID.add(doc.id);
          });
          todos = _todos;
          todosID = _todosID;
          notifyListeners();
        },
      );

      print("1111111111111111111111111111");
      print(todos);
    } catch (error) {
      debugPrint('$error');
    }
  } //* Getting the todos

  void getStudents() async {
    List<String> _studentsName = [];
    List<int> _studentsTodo = [];
    List<String> _students = await _database.getStudents(_auth.user.uid);
    for (int i = 0; i < _students.length; i++) {
      List<TodoListModel> todo = await _database.getTodoList(_students[i]);
      _studentsTodo.add(todo.length);
    }
    studentsTodo = _studentsTodo;
    for (int i = 0; i < _students.length; i++) {
      String name = await _database.getUserName(_students[i]);
      _studentsName.add(name);
    }
    studentsName = _studentsName;
    students = _students;
    notifyListeners();
  }
}
