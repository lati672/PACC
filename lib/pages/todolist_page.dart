import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../models/todo_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

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
  final List<CameraDescription> cameras;

  const TodoListPage({Key? key, required this.cameras}) : super(key: key);

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
  late double _deviceWidth;
  late double _deviceHeight;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    // fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
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
        return SizedBox(
          height: _deviceHeight,
          width: _deviceWidth,
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
                          MaterialPageRoute(builder: (_) => AddTodoListPage()),
                        )
                        .then((val) => val ? _getRequests() : null);
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
              // _todosList(),
              Expanded(child: Container(
                color:const Color.fromRGBO(240, 240, 240, 1),
                child: _todosList(),
              ))


              // _todosList(),
            ],
          ),
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
        : todos.isEmpty
            ? const Center(
                child: Text(
                "当前暂无待办，快去添加吧",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18.0,
                ),
              ))
            : MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: _deviceWidth*.03),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  //padding: const EdgeInsets.all(16.0),
                  itemCount: todos.length,
                  itemBuilder: (BuildContext context, int index) {
                    int pos = 0;
                    for (var i = 0; i < todos[index].recipients.length; i++) {
                      if (todos[index].recipients[i] == _auth.user.uid) {
                        pos = i;
                        break;
                      }
                    }
                    return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
                            child: ListTile(
                              //tileColor: Colors.lightBlueAccent,
                              textColor: Colors.black,
                              title: Text(
                                todos[index].todolist_name,
                                style: _biggerFont,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                todos[index].description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: _auth.user.role == 'Student'
                                  ? TextButton(
                                      onPressed: () {
                                        _navigation.navigateToPage(PomodoroPage(
                                            todo: todos[index],
                                            todoID: todosID?[index],
                                            index: pos,
                                            cameras: widget.cameras));
                                      },
                                      child: const Text(
                                        "开始",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    )
                                  : const Text(
                                      '占位空白view，透明',
                                      style: TextStyle(
                                        color: Colors.lightBlueAccent,
                                      ),
                                    ),
                              onTap: () {
                                _navigation.navigateToPage(UpdateTodoListPage(
                                    todo: todos[index],
                                    todoID: todosID?[index],
                                    index: index));
                              },
                            ),
                          )
                        ]
                        // )
                        );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(
                      height: 10.0,
                    );
                  },
                ));
  }

  _getRequests() async {}
}
