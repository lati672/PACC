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

class UpdateTodoListPage extends StatefulWidget {
  const UpdateTodoListPage({Key? key, required this.todo}) : super(key: key);
  final TodoListModel todo;
  @override
  State<StatefulWidget> createState() {
    return _UpdateTodoListState();
  }
}

class _UpdateTodoListState extends State<UpdateTodoListPage> {
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
    TextEditingController _controller1 =
        TextEditingController(text: widget.todo.todolist_name);
    FocusNode _focusNode1 = FocusNode();
    TextEditingController _controller2 =
        TextEditingController(text: widget.todo.description);
    FocusNode _focusNode2 = FocusNode();
    String interval = widget.todo.interval;
    String recipients = "";
    widget.todo.recipients.forEach((e) {
      recipients += e;
    });
    return Builder(
      builder: (_context) {
        //* Triggers the info in the widgets to render themselves
        _pageProvider = _context.watch<TodoListPageProvider>();
        return Scaffold(
          appBar: AppBar(
            title: const Text("修改任务"),
            centerTitle: true,
            actions: [
              FlatButton(
                  child: const Text("确定"),
                  onPressed: () {
                    // _navigation.goBack();
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
                  title: Text("任务时间" + "    " + interval),
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
                  title: Text("发送到" + "   " + recipients),
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
                FlatButton(
                    child: const Text("删除待办"),
                    color: Colors.red,
                    onPressed: () {
                      // _navigation.goBack();
                    })
              ],
            ),
          )),
        );
      },
    );
  }
}
