import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
// Providers
import '../providers/authentication_provider.dart';
import '../providers/todolist_provider.dart';
//pages
import '../pages/pomodoro.dart';
// Services
import '../services/navigation_service.dart';
import '../services/database_service.dart';
// Widgets
import '../widgets/top_bar.dart';

class TodoListPage extends StatefulWidget {
  // const TodoListPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _TodoListState();
  }
}

class _TodoListState extends State<TodoListPage> {
  DatabaseService _database = GetIt.instance.get<DatabaseService>();
  NavigationService _navigation = GetIt.instance.get<NavigationService>();
  late AuthenticationProvider _auth;
  // AuthenticationProvider _auth =
  //     Provider.of<AuthenticationProvider>(getContext);
  // List<TodoListModel> todos = [];

  late TodoListPageProvider _pageProvider;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    // fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    return _buildUI();
  }

  Widget _buildUI() {
    return Builder(
      builder: (_context) {
        //* Triggers the info in the widgets to render themselves
        _pageProvider = _context.watch<TodoListPageProvider>();
        List<TodoListModel>? todos = _pageProvider.todos;
        // return Scaffold(
        //     body: todos == null
        //         ? Center(child: CircularProgressIndicator())
        //         : Column(children: [
        //             ListView.builder(
        //               scrollDirection: Axis.vertical,
        //               shrinkWrap: true,
        //               padding: const EdgeInsets.all(16.0),
        //               itemCount: todos.length,
        //               itemBuilder: (BuildContext context, int index) {
        //                 return ListTile(
        //                   title: Text(
        //                     todos[index].todolist_name,
        //                     style: _biggerFont,
        //                   ),
        //                   trailing: const Icon(
        //                     Icons.check_box_outline_blank,
        //                   ),
        //                   onTap: () {
        //                     // updateTodo(todos[index].id);
        //                     // todos.removeAt(index);
        //                     // setState(() {
        //                     //   todos = todos;
        //                     // });
        //                     // _navigation.navigateToPage(Pomodoro());
        //                   },
        //                 );
        //               },
        //             ),
        //             // FlatButton(onPressed: updateTodo(todos[index].id), child: const Text('点击添加'))
        //           ]));
        return SafeArea(
            child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              TopBar(
                'Chats' + (_auth.user.role == 'Student' ? '学生端' : '家长端'),
                primaryAction: IconButton(
                  onPressed: () {
                    // * Logout the user if he/she presses the button icon
                    _navigation.navigateToPage(Pomodoro());
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Color.fromRGBO(0, 82, 218, 1),
                  ),
                ),
              ),
              _todosList(),
            ],
          ),
        ));
      },
    );
  }

  // Build UI
  Widget _todosList() {
    List<TodoListModel>? todos = _pageProvider.todos;
    return todos == null
        ? Center(child: CircularProgressIndicator())
        : Column(children: [
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.all(16.0),
              itemCount: todos.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    todos[index].todolist_name,
                    style: _biggerFont,
                  ),
                  trailing: const Icon(
                    Icons.check_box_outline_blank,
                  ),
                  onTap: () {
                    // updateTodo(todos[index].id);
                    // todos.removeAt(index);
                    // setState(() {
                    //   todos = todos;
                    // });
                    // _navigation.navigateToPage(Pomodoro());
                  },
                );
              },
            ),
          ]);
  }
  // void fetchTodos() async {
  //   // print("start fetchTodos");
  //   // todos = await _database.getTodoList(_auth.user.name);
  //   todos = await _database.getTodoList("liwanting");
  //   setState(() {
  //     todos = todos;
  //   });
  // }

  // void addTodo() async {
  //   TodoListModel newTodo = TodoListModel(
  //     senderid: 'student1',
  //     start_time: DateTime.now(),
  //     status: "0",
  //     description: "add a new todolist",
  //     todolist_name: "todolist11111",
  //     interval: "1h",
  //     recipients: ["student1"],
  //   );
  //   await _database.addTodoList(newTodo);
  // }

  // void updateTodo(String uid) async {
  //   // todo.status = 2;
  //   TodoListModel newTodo = TodoListModel(
  //     senderid: 'student1',
  //     start_time: DateTime.now(),
  //     status: "0",
  //     description: "update a todolist",
  //     todolist_name: "todolist11111",
  //     interval: "2h",
  //     recipients: ["student1"],
  //   );
  //   await _database.updateTodoList(newTodo);
  // }
}
