import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
//pages
import '../pages/pomodoro.dart';
// Services
import '../services/navigation_service.dart';
import '../services/database_service.dart';

class TodoListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TodoListState();
  }
}

class _TodoListState extends State<TodoListPage> {
  DatabaseService _database = GetIt.instance.get<DatabaseService>();
  NavigationService _navigation = GetIt.instance.get<NavigationService>();
  List<TodoListModel> todos = [];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    Future.delayed(
        Duration.zero,
        () => setState(() {
              fetchTodos();
            }));
  }

  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: todos == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: todos.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    todos[index].name,
                    style: _biggerFont,
                  ),
                  trailing: const Icon(
                    Icons.check_box_outline_blank,
                  ),
                  onTap: () {
                    // updateTodo(todos[index]);
                    todos.removeAt(index);
                    setState(() {
                      todos = todos;
                    });
                  },
                );
              },
            ),
    );
  }

  void fetchTodos() async {
    // late List<String> todos;
    todos = await _database.getTodoListAll();
    setState(() {
      todos = todos;
    });
  }

  // void addTodos() async {
  //   var person = {
  //   'name': 'ptbird',
  //   'age': 24,
  //   'work': ['it1', 'it2']
  // };
  //   var todolist = {
  //     'uid':'test',
  //     'description':'a new todo list demo test',
  //   start_time:'2022年3月8日UTC+8 00:00:00'.toDate(),
  //   end_time:'2022年3月9日UTC+8 00:00:00'.toDate(),
  //   name:'todolist2',
  //   interval:'1:00:00',
  //   recepients:'student1',
  //   };
  //   await _database.addTodoList();
  // }

  // void updateTodo(Todo todo) async {
  //   await todoModel.openSqlite();
  //   todo.done = true;
  //   await todoModel.update(todo);
  //   await todoModel.close();
  // }
}
