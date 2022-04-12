import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

// Providers
import '../providers/authentication_provider.dart';
import '../providers/todolist_provider.dart';

//pages
import '../pages/pomodoro_page.dart';
import '../pages/addTodolist_page.dart';
import '../pages/updateTodolist_page.dart';

// Services
import '../services/navigation_service.dart';
import '../services/database_service.dart';

// Widgets
import '../widgets/top_bar.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TodoListState();
  }
}

class _TodoListState extends State<TodoListPage> {
  DatabaseService _database = GetIt.instance.get<DatabaseService>();
  NavigationService _navigation = GetIt.instance.get<NavigationService>();
  late AuthenticationProvider _auth;

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TodoListPageProvider>(
          create: (_) => TodoListPageProvider(_auth),
        )
      ],
      child: _buildUI(),
    );
    // return _buildUI();
  }

  Widget _buildUI() {
    return Builder(
      builder: (_context) {
        //* Triggers the info in the widgets to render themselves
        _pageProvider = _context.watch<TodoListPageProvider>();
        return Scaffold(
          body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TopBar(
                    (_auth.user.role == 'Student' ? '我的' : '该学生') + '任务',
                    primaryAction: IconButton(
                      onPressed: () {
                        // * Logout the user if he/she presses the button icon
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                  builder: (_) => AddTodoListPage()),
                            )
                            .then((val) => val ? _getRequests() : null);
                      },
                      icon: const Icon(
                        Icons.add,
                        color: Color.fromRGBO(0, 82, 218, 1),
                      ),
                    ),
                  ),
                  Expanded(child: _todosList())
                ],
              )),
        );
      },
    );
  }

  // Build UI
  Widget _todosList() {
    List<TodoListModel>? todos = _pageProvider.todos;
    List? todosID = _pageProvider.todosID;
    return todos == null
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
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
                subtitle: Text(todos[index].description),
                trailing: _auth.user.role == 'Student'
                    ? FlatButton(
                        child: const Text("开始"),
                        onPressed: () {
                          _navigation.navigateToPage(PomodoroPage(
                              todo: todos[index], todoID: todosID?[index]));
                        })
                    : const Text(
                        '占位空白view，透明',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                onTap: () {
                  // updateTodo(todos[index].id);
                  // todos.removeAt(index);
                  // setState(() {
                  //   todos = todos;
                  // });
                  _navigation.navigateToPage(UpdateTodoListPage(
                      todo: todos[index], todoID: todosID?[index]));
                  //传入此条todolist的信息
                },
              );
            },
          );
  }

  // void fetchTodos() async {
  //   // print("start fetchTodos");
  //   // todos = await _database.getTodoList(_auth.user.name);
  //   todos = await _database.getTodoList("liwanting");
  //   setState(() {
  //     todos = todos;
  //   });
  // }
  _getRequests() async {}
}
