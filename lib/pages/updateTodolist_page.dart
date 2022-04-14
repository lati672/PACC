import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'dart:convert';
// Providers
import '../providers/authentication_provider.dart';
import '../providers/todolist_provider.dart';
//pages
import 'package:chatifyapp/pages/todolist_page.dart';
// Services
import '../services/navigation_service.dart';
import '../services/database_service.dart';
// Widgets
import '../widgets/top_bar.dart';
//Utils
import '../utils/showToast.dart';

class UpdateTodoListPage extends StatefulWidget {
  const UpdateTodoListPage({Key? key, required this.todo, required this.todoID})
      : super(key: key);
  final TodoListModel todo;
  final String todoID;
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

  late TextEditingController _controller1;
  FocusNode _focusNode1 = FocusNode();
  late TextEditingController _controller2;
  FocusNode _focusNode2 = FocusNode();

  int _interval = 0;
  String _intervalStr = "0min";
  static const PickerData2 = '''
[
    [
        "1h",
        "2h",
        "3h",
        "4h",
        "5h",
        "6h",
        "7h"
    ],
    [
        "0min",
        "5min",
        "10min",
        "15min",
        "20min",
        "25min",
        "30min",
        "35min",
        "40min",
        "45min",
        "50min",
        "55min"
    ]
]
    ''';

  @override
  void initState() {
    super.initState();
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
    _controller1 = TextEditingController(text: widget.todo.todolist_name);
    _controller2 = TextEditingController(text: widget.todo.description);

    Set<int> selected = Set<int>();
    List<String> recipients = [];
    List<String> recipientsName = [];

    int interval = widget.todo.interval;
    String intervalStr = (interval / 60).truncate().toString() +
        "h " +
        (interval % 60).toString() +
        "min";

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
                    updateTodo(widget.todoID);
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
                  title: Text("任务时间    " + _intervalStr),
                  trailing: IconButton(
                    onPressed: () {
                      showPickerArray(context);
                      setState(() {
                        intervalStr = _intervalStr;
                        interval = _interval;
                      });
                    },
                    icon: const Icon(
                      Icons.keyboard_arrow_right,
                      color: Color.fromRGBO(0, 82, 218, 1),
                    ),
                  ),
                ),
                if (_auth.user.role == 'parent')
                  ListTile(
                    title: Text(
                        "发送到" + "   " + widget.todo.recipientsName.join(' , ')),
                    trailing: IconButton(
                      onPressed: () {
                        List<String>? students = _pageProvider.students;
                        List<String>? studentsName = _pageProvider.studentsName;
                        (students == null || studentsName == null)
                            ? const Center(child: CircularProgressIndicator())
                            : showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                context: context,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(
                                      builder: (context1, setState1) {
                                    return Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20.0),
                                          topRight: Radius.circular(20.0),
                                        ),
                                      ),
                                      height:
                                          MediaQuery.of(context).size.height /
                                              2.0,
                                      child: Column(children: [
                                        _getModalSheetHeaderWithConfirm(
                                          '发送到',
                                          onCancel: () {
                                            Navigator.of(context).pop();
                                          },
                                          onConfirm: () {
                                            setState1(() {
                                              recipients = [];
                                              recipientsName = [];
                                              selected.forEach((e) {
                                                recipients.add(students[e]);
                                                recipientsName
                                                    .add(studentsName[e]);
                                              });
                                            });

                                            Navigator.of(context)
                                                .pop(selected.toList());
                                          },
                                        ),
                                        const Divider(height: 1.0),
                                        Expanded(
                                          child: ListView.builder(
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return ListTile(
                                                trailing: Icon(
                                                    selected.contains(index)
                                                        ? Icons.check_box
                                                        : Icons
                                                            .check_box_outline_blank,
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                                title:
                                                    Text(studentsName[index]),
                                                onTap: () {
                                                  setState1(() {
                                                    if (selected
                                                        .contains(index)) {
                                                      selected.remove(index);
                                                    } else {
                                                      selected.add(index);
                                                    }
                                                  });
                                                },
                                              );
                                            },
                                            itemCount: studentsName.length,
                                          ),
                                        ),
                                      ]),
                                    );
                                  });
                                },
                              );
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
                      removeTodo(widget.todoID);
                    })
              ],
            ),
          )),
        );
      },
    );
  }

  showPickerArray(BuildContext context) {
    Picker(
        adapter: PickerDataAdapter<String>(
            pickerdata: new JsonDecoder().convert(PickerData2), isArray: true),
        hideHeader: true,
        title: const Text("任务时间"),
        onConfirm: (Picker picker, List value) {
          List arr = picker.getSelectedValues();
          int h = int.parse(arr[0][0]);
          int m = int.parse(arr[1].split('min')[0]);
          print("1111111111111111");
          print(arr.join(' '));
          setState(() {
            _interval = h * 60 + m;
            _intervalStr = arr.join(' ');
          });
        }).showDialog(context);
  }

  Widget _getModalSheetHeaderWithConfirm(String title, {onCancel, onConfirm}) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              onCancel();
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
          ),
          IconButton(
              icon: const Icon(
                Icons.check,
                color: Colors.blue,
              ),
              onPressed: () {
                onConfirm();
              }),
        ],
      ),
    );
  }

  void updateTodo(String uid) async {
    if (_controller1.text.length == 0) {
      showErrorToast('标题不能为空！');
      return;
    }
    TodoListModel newTodo = TodoListModel(
      senderid: widget.todo.senderid,
      start_time: DateTime.now(),
      status: "todo",
      description: _controller2.text,
      todolist_name: _controller1.text,
      interval: _interval,
      recipients: [_auth.user.uid],
      recipientsName: [_auth.user.uid],
      sent_time: widget.todo.sent_time,
    );
    await _database.updateTodoList(newTodo, uid);
    showToast('修改 Todo 成功 (ﾟ▽ﾟ)/');
    // _navigation.navigateToPage(TodoListPage());
    Navigator.pop(context, true);
  }

  void removeTodo(String uid) async {
    await _database.removeTodoList(uid);
    showToast('删除 Todo 成功 (ﾟ▽ﾟ)/');
    // _navigation.navigateToPage(TodoListPage());
    Navigator.pop(context, true);
  }
}
