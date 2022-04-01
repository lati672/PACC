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

class AddTodoListPage extends StatefulWidget {
  // const TodoListPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _AddTodoListState();
  }
}

class _AddTodoListState extends State<AddTodoListPage> {
  DatabaseService _database = GetIt.instance.get<DatabaseService>();
  NavigationService _navigation = GetIt.instance.get<NavigationService>();
  late AuthenticationProvider _auth;
  // AuthenticationProvider _auth =
  //     Provider.of<AuthenticationProvider>(getContext);
  // List<TodoListModel> todos = [];

  late TodoListPageProvider _pageProvider;
  final _biggerFont = const TextStyle(fontSize: 18.0);
  TextEditingController _controller1 = TextEditingController();
  FocusNode _focusNode1 = FocusNode();
  TextEditingController _controller2 = TextEditingController();
  FocusNode _focusNode2 = FocusNode();

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
          appBar: AppBar(
            title: const Text("添加任务"),
            centerTitle: true,
            actions: [
              FlatButton(
                  child: const Text("确定"),
                  onPressed: () {
                    addTodo();
                  })
            ],
          ),
          body: SafeArea(
              child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                TextField(
                  controller: _controller1,
                  focusNode: _focusNode1,
                  maxLength: 20,
                  decoration: InputDecoration(
                    hintText: "标题",
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  ),
                  onSubmitted: (str) {
                    print('_TextFieldViewState.buildView--$str');
                  },
                  textInputAction: TextInputAction.search,
                  onChanged: (content) {
                    print('_TextFieldViewState.buildView-changed:$content');
                  },
                ),
                TextField(
                  controller: _controller2,
                  focusNode: _focusNode2,
                  maxLength: 100,
                  maxLines: 5,
                  decoration: InputDecoration(
                      hintText: "备注",
                      contentPadding: EdgeInsets.all(10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                  onSubmitted: (str) {
                    print('_TextFieldViewState.buildView--$str');
                  },
                  textInputAction: TextInputAction.search,
                  onChanged: (content) {
                    print('_TextFieldViewState.buildView-changed:$content');
                  },
                ),
                ListTile(
                  title: const Text("任务时间" + "    "),
                  trailing: IconButton(
                    onPressed: () {
                      // _navigation.navigateToPage(AddTodoListPage());
                    },
                    icon: const Icon(
                      Icons.keyboard_arrow_right,
                      color: Color.fromRGBO(0, 82, 218, 1),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text("发送到" + "   "),
                  trailing: IconButton(
                    onPressed: () {
                      // _navigation.navigateToPage(AddTodoListPage());
                    },
                    icon: const Icon(
                      Icons.keyboard_arrow_right,
                      color: Color.fromRGBO(0, 82, 218, 1),
                    ),
                  ),
                ),
              ],
            ),
          )),
        );
      },
    );
  }

  void addTodo() async {
    TodoListModel newTodo = TodoListModel(
      senderid: _auth.user.uid,
      start_time: DateTime.now(),
      status: "0",
      description: _controller2.text,
      todolist_name: _controller1.text,
      interval: "1:00:00",
      recipients: [_auth.user.uid],
      sent_time: DateTime.now(),
    );
    await _database.addTodoList(newTodo);
  }
}
