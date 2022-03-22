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
  // final TodoListModel todoModel;
  // TodoListModel todoSqlite = new TodoListModel();
  late DatabaseService _database;
  late NavigationService _navigation;
  // List<TodoListModel> todos = await _database.getTodoListAll(false);
  // late List<TodoListModel> todos;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _database = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();
    // addTodos();
    fetchTodos();
    // return _buildUI();
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.headset_off),
        ),
        title: Text('Pomodoro'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.alarm_off),
          ),
        ],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Text(
                'kWorkLabel',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              FlatButton(
                  child: const Text("开始番茄钟"),
                  onPressed: () {
                    _navigation.navigateToPage(Pomodoro());
                  })
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildUI() {
  //   return Scaffold(
  //     body: todos == null
  //         ? Center(child: CircularProgressIndicator())
  //         : ListView.builder(
  //             padding: const EdgeInsets.all(16.0),
  //             itemCount: todos.length,
  //             itemBuilder: (BuildContext context, int index) {
  //               return new ListTile(
  //                 title: new Text(
  //                   // todos[index].title,
  //                   'title',
  //                   style: _biggerFont,
  //                 ),
  //                 trailing: new Icon(
  //                   Icons.check_box_outline_blank,
  //                 ),
  //                 onTap: () {
  //                   // updateTodo(todos[index]);
  //                   todos.removeAt(index);
  //                   setState(() {
  //                     todos = todos;
  //                   });
  //                 },
  //               );
  //             },
  //           ),
  //   );
  // }

  void fetchTodos() async {
    // late List<String> todos;
    // List<String> todos = await _database.getTodoListAll(false);
    List<TodoListModel> list = await _database.getTodoListAll();
    // print(todos);

    // todos = await _database.getTodoListAll(userId);
    // await todoModel.openSqlite();
    // todos = await todoModel.queryAll(false);
    // setState(() {
    //   todos = todos;
    // });
    // await todoModel.close();
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
