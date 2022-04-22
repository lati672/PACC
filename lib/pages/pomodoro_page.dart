//packages
import 'package:chatifyapp/pages/todolist_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:convert';

// Widgets
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';
import '../pages/takeVideo.dart';

// Models
import '../models/chats_model.dart';
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
  const PomodoroPage(
      {Key? key,
      required this.todo,
      required this.todoID,
      required this.index,
      required this.cameras})
      : super(key: key);
  final TodoListModel todo;
  final String todoID;
  final int index;
  final List<CameraDescription> cameras;
  @override
  _PomodoroPageState createState() => _PomodoroPageState();
}

Icon kPlayClockButton = const Icon(Icons.play_arrow_sharp);
Icon kPauseClockButton = const Icon(Icons.pause_sharp);

class _PomodoroPageState extends State<PomodoroPage> {
  bool isStart = false; //第一次开始番茄钟
  bool isVideoOpen = false;

// Time constants
  int kWorkDuration = 60;
  final CountDownController _clockController = CountDownController();
  Icon _clockButton = kPlayClockButton; // Initial value
  bool _isClockStarted = false; // Conditional flag

  NavigationService _navigation = GetIt.instance.get<NavigationService>();
  DatabaseService _database = GetIt.instance.get<DatabaseService>();
  late AuthenticationProvider _auth;

  String str = "";
  List<String> appList = [];
  late double _deviceWidth;
  late double _deviceHeight;
  bool isOpenUsageAccess = false;
  late Timer _appLockTimer;
  late Timer _takeVideoTimer;
  bool isVideoVisible = false;

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
      //开启视频录制
      setState(() {
        isVideoOpen = true;
      });
      appLockTimer();
      takeVideoTimer();
    } else {
      // Processed on pause
      _clockButton = kPlayClockButton;
      _clockController.pause();
      //停止视频录制
      setState(() {
        isVideoOpen = false;
      });
      //
      // appLockTimer();
      _takeVideoTimer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    // Half Screen Dimensions
    final double height = MediaQuery.of(context).size.height / 3;
    final double width = MediaQuery.of(context).size.width / 1.5;
    _getWhitelist(); //初始化，获取白名单应用

    CircularCountDownTimer clock = CircularCountDownTimer(
      controller: _clockController,
      isReverseAnimation: true,
      ringColor: Colors.blue,
      height: height,
      width: width,
      autoStart: false,
      duration: kWorkDuration * widget.todo.interval,
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
    int pos = 0;

    for (var i = 0; i < widget.todo.recipients.length; i++) {
      print(widget.todo.recipients[i]);
    }
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: <Widget>[
              Opacity(
                  opacity: isVideoVisible ? 1.0 : 0.0,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TakeVideoScreen(
                        todolistid: widget.todoID,
                        pos: widget.index,
                        parentid: widget.todo.senderid,
                        studentid: widget.todo.recipients[widget.index],
                        cameras: widget.cameras,
                        isVideoOpen: isVideoOpen,
                        setIsVideoOpen: (_isVideoOpen) =>
                            setIsVideoOpen(_isVideoOpen)),
                  )),
              Center(
                child: clock,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: _deviceHeight * 0.1),
                child: Container(
                    height: _deviceHeight * 0.1,
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
                                  if (!isStart) {
                                    isStart = true;
                                    startTodo();
                                  }
                                }
                              });
                            });
                          },
                          child: _clockButton,
                        ),
                        IconButton(
                          onPressed: () {
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
                                        topLeft: Radius.circular(20.0),
                                        topRight: Radius.circular(20.0),
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
                                        onConfirm: () {},
                                      ),
                                      const Divider(height: 1.0),
                                      Expanded(
                                        child: ListView.builder(
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return ListTile(
                                              title: Text(appList[index]),
                                              onTap: () {
                                                //launch()；安卓方法：跳转其他app
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
                            setState(() {
                              isVideoVisible = !isVideoVisible;
                            });
                          },
                          icon: const Icon(Icons.photo_camera),
                        ),
                        IconButton(
                          onPressed: () {
                            if (isStart) {
                              setState(() {
                                switchClockActionButton();
                              });
                            }
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
  void appLockTimer() {
    // 定义一个函数，将定时器包裹起来
    _appLockTimer = Timer.periodic(Duration(milliseconds: 1000), (t) {
      _count++;
      if (_count == 15) {
        t.cancel(); // 定时器内部触发销毁
      }
      _appLock();
    });
  }

  void takeVideoTimer() {
    // 定义一个函数，将定时器包裹起来
    _takeVideoTimer = Timer.periodic(Duration(milliseconds: 15000), (t) {
      setState(() {
        isVideoOpen = false;
      });
    });
  }

  setIsVideoOpen(_isVideoOpen) {
    setState(() {
      isVideoOpen = _isVideoOpen;
    });
  }

  void startTodo() async {
    List<String> _status = widget.todo.status;
    _status[widget.index] = "doing";
    TodoListModel newTodo = TodoListModel(
      senderid: widget.todo.senderid,
      start_time: List.generate(
          widget.todo.recipients.length, (index) => DateTime.now()),
      status: _status,
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
    List<String> _status = widget.todo.status;
    _status[widget.index] = "done";

    TodoListModel newTodo = TodoListModel(
      senderid: widget.todo.senderid,
      start_time: widget.todo.start_time,
      status: _status,
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
    List<String> _status = widget.todo.status;
    _status[widget.index] = "todo";
    TodoListModel newTodo = TodoListModel(
      senderid: widget.todo.senderid,
      start_time: widget.todo.start_time,
      status: _status,
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
            stopTodo();
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
              color: Colors.white, //透明，占位
            ),
            onPressed: () {
              onConfirm();
            }),
      ],
    ),
  );
}
