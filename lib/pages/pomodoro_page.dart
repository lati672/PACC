//packages
import 'package:chatifyapp/pages/todolist_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// Widgets
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';

// Models
import '../models/chats_model.dart';
// import 'dart:io';
// import 'dart:convert';
// import 'package:image_picker/image_picker.dart';
// import 'package:video_player/video_player.dart';
//Models
import '../models/todo_list_model.dart';
// Providers
import '../providers/authentication_provider.dart';
import '../providers/todolist_provider.dart';
// Widget
import '../pages/whitelist_page.dart';
// Services
import '../services/navigation_service.dart';
import '../services/database_service.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({Key? key, required this.todo, required this.todoID})
      : super(key: key);
  final TodoListModel todo;
  final String todoID;
  @override
  _PomodoroPageState createState() => _PomodoroPageState();
}

Icon kPlayClockButton = const Icon(Icons.play_arrow_sharp);
Icon kPauseClockButton = const Icon(Icons.pause_sharp);

class _PomodoroPageState extends State<PomodoroPage> {
// Icon Constants
  int isStart = 0; //第一次开始番茄钟

// Time constants
  int kWorkDuration = 1;
  final CountDownController _clockController = CountDownController();
  Icon _clockButton = kPlayClockButton; // Initial value
  bool _isClockStarted = false; // Conditional flag

  NavigationService _navigation = GetIt.instance.get<NavigationService>();
  DatabaseService _database = GetIt.instance.get<DatabaseService>();
  late AuthenticationProvider _auth;

  Set<int> selected = Set<int>();
  String str = "";
  List<String> appList = [];
  bool isOpenUsageAccess = false;

  // Change Clock button icon and controller
  void switchClockActionButton() {
    if (_clockButton == kPlayClockButton) {
      _clockButton = kPauseClockButton;

      if (!_isClockStarted) {
        // Processed on init
        _isClockStarted = true;
        _clockController.start();
      } else {
        // Processed on play
        _clockController.resume();
      }
    } else {
      // Processed on pause
      _clockButton = kPlayClockButton;
      _clockController.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    // Half Screen Dimensions
    final double height = MediaQuery.of(context).size.height / 1.3;
    final double width = MediaQuery.of(context).size.width / 1.5;

    CircularCountDownTimer clock = CircularCountDownTimer(
      controller: _clockController,
      isReverseAnimation: true,
      ringColor: Colors.blue,
      height: height,
      width: width,
      autoStart: false,
      duration: kWorkDuration * 15,
      isReverse: true,
      textStyle: const TextStyle(color: Colors.blue, fontSize: 40.0),
      fillColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.white12,
      strokeCap: StrokeCap.round,
      onComplete: () {
        finishTodo();
        /*这里要延时加载  否则会抱The widget on which setState() or markNeedsBuild() was called was:错误*/
        Future.delayed(Duration(milliseconds: 200)).then((e) {
          setState(() async {
            _navigation.goBack();
            _showAlert(context);
          });
        });
      },
    );

    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Center(
                child: clock,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _isOpenUsageAccess();
                            /* 延时加载  */
                            Future.delayed(Duration(milliseconds: 200))
                                .then((e) {
                              setState(() async {
                                if (!isOpenUsageAccess) {
                                  _showAlertAccess(context);
                                } else {
                                  setState(() {
                                    switchClockActionButton();
                                  });
                                  if (isStart == 0) {
                                    isStart = 1;
                                    startTodo();
                                    myTimer();
                                  }
                                }
                              });
                            });
                          },
                          child: _clockButton,
                        ),
                        IconButton(
                          onPressed: () {
                            _getWhitelist();
                            showModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                    builder: (context1, setState) {
                                  return Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(20.0),
                                        topRight: const Radius.circular(20.0),
                                      ),
                                    ),
                                    height: MediaQuery.of(context).size.height /
                                        2.0,
                                    child: Column(children: [
                                      _getModalSheetHeaderWithConfirm(
                                        '打开其他app',
                                        onCancel: () {
                                          Navigator.of(context).pop();
                                        },
                                        onConfirm: () {
                                          // Navigator.of(context)
                                          //     .pop(selected.toList());
                                          Navigator.pop(context, str);
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
                                              title: Text(appList[index]),
                                              onTap: () {
                                                setState(() {
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
                                          itemCount: appList.length,
                                        ),
                                      ),
                                    ]),
                                  );
                                });
                              },
                            );
                          },
                          icon: const Icon(Icons.apps),
                        ),
                        IconButton(
                          onPressed: () {
                            //接深度学习图像检测模块
                            // _testRecordTheScreen();
                          },
                          icon: const Icon(Icons.photo_camera),
                        ),
                        IconButton(
                          onPressed: () {
                            if (isStart == 1) {
                              setState(() {
                                switchClockActionButton();
                              });
                            }
                            stopTodo();
                            _showAlertStop(context);
                          },
                          icon: const Icon(Icons.stop),
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getWhitelist() async {
    String list = await _database.getlatestWhitelistfromAlluser(_auth.user.uid);

    // String list = await _database.getLatestWhitelist(_auth.user.uid);

    // List<String> arr = [];
    appList = list.split(',');
  }

  //判断用户是否开启“Apps with usage access”权限
  void _isOpenUsageAccess() async {
    const platform = const MethodChannel('samples.flutter.dev');
    try {
      bool _isOpen = await platform.invokeMethod('isOpenUsageAccess');
      setState(() {
        isOpenUsageAccess = _isOpen;
      });
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  //若用户未开启权限，则引导用户开启“Apps with usage access”权限
  void _openUsageAccess() async {
    const platform = const MethodChannel('samples.flutter.dev');
    try {
      await platform.invokeMethod('openUsageAccess');
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  //番茄钟时间段内锁机，若当前栈顶app不是白名单中的，则跳转我们的番茄钟app
  void _appLock() async {
    const platform = const MethodChannel('samples.flutter.dev');
    try {
      await platform.invokeMethod('appLock');
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  int _count = 0;
  void myTimer() {
    // 定义一个函数，将定时器包裹起来
    Timer _timer = Timer.periodic(Duration(milliseconds: 5000), (t) {
      _count++;
      if (_count == 15) {
        t.cancel(); // 定时器内部触发销毁
      }
      _appLock();
    });
  }

  void startTodo() async {
    TodoListModel newTodo = TodoListModel(
      senderid: widget.todo.senderid,
      start_time: DateTime.now(),
      status: "doing",
      description: widget.todo.description,
      todolist_name: widget.todo.todolist_name,
      interval: widget.todo.interval,
      recipients: widget.todo.recipients,
      recipientsName: widget.todo.recipientsName,
      sent_time: widget.todo.sent_time,
    );
    await _database.updateTodoList(newTodo, widget.todoID);
  }

  finishTodo() async {
    TodoListModel newTodo = TodoListModel(
      senderid: widget.todo.senderid,
      start_time: widget.todo.start_time,
      status: "done",
      description: widget.todo.description,
      todolist_name: widget.todo.todolist_name,
      interval: widget.todo.interval,
      recipients: widget.todo.recipients,
      recipientsName: widget.todo.recipientsName,
      sent_time: widget.todo.sent_time,
    );
    await _database.updateTodoList(newTodo, widget.todoID);
  }

  stopTodo() async {
    TodoListModel newTodo = TodoListModel(
      senderid: widget.todo.senderid,
      start_time: DateTime.now(),
      status: "todo",
      description: widget.todo.description,
      todolist_name: widget.todo.todolist_name,
      interval: widget.todo.interval,
      recipients: widget.todo.recipients,
      recipientsName: widget.todo.recipientsName,
      sent_time: widget.todo.sent_time,
    );
    await _database.updateTodoList(newTodo, widget.todoID);
  }

//Show Alert based on alert type
  void _showAlert(BuildContext context) {
    final alert = AlertDialog(
      title: const Text("已完成"),
      content: const Text('此番茄钟已完成'),
      actions: [
        FlatButton(
            child: const Text("确认"),
            onPressed: () {
              _navigation.goBack();
            })
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //Show Alert based on alert type
  void _showAlertStop(BuildContext context) {
    final alert = AlertDialog(
      title: const Text("停止"),
      content: const Text('确定要结束此番茄钟吗'),
      actions: [
        FlatButton(
            child: const Text("取消"),
            onPressed: () {
              _navigation.goBack();
            }),
        FlatButton(
          child: const Text("确认"),
          onPressed: () {
            int count = 0;
            Navigator.popUntil(context, (route) {
              return count++ == 2;
            });
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //Show Alert based on alert type
  void _showAlertAccess(BuildContext context) {
    final alert = AlertDialog(
      title: const Text("权限申请"),
      content: const Text('番茄钟的锁机功能需要申请使用情况访问权限'),
      actions: [
        FlatButton(
            child: const Text("取消"),
            onPressed: () {
              _navigation.goBack();
            }),
        FlatButton(
          child: const Text("去打开"),
          onPressed: () {
            _openUsageAccess();
            _navigation.goBack();
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  // /// 录屏
  // Future _testRecordTheScreen() async {
  //   /// 打开摄像头录制视频，并限制时长5min
  //   PickedFile? image = await ImagePicker().getVideo(
  //       source: ImageSource.camera, maxDuration: Duration(minutes: 5));
  //   late VideoPlayerController _controller;
  //   if (image != null) {
  //     /// 视频绝对路径地址
  //     String path = image.path;
  //     File f = File(path);
  //     /// 文件大小，单位：B
  //     int fileSize = 0;
  //     /// 视频时长，单位：秒
  //     int seconds = 0;
  //     _controller = VideoPlayerController.file(f);
  //     _controller.initialize().then((value) {
  //       _controller.setLooping(true);
  //       seconds = _controller.value.duration.inSeconds;
  //       fileSize = f.lengthSync();
  //     });
  //     /// 视频名称
  //     var name = path.substring(path.lastIndexOf("/") + 1, path.length);
  //   }
  // }
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
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
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
