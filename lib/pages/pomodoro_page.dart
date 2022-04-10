//packages
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
// Widget
import '../pages/whitelist_page.dart';
// Services
import '../services/navigation_service.dart';

class PomodoroPage extends StatefulWidget {
  @override
  _PomodoroPageState createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
// Icon Constants
  Icon kPlayClockButton = const Icon(Icons.play_arrow_sharp);
  Icon kPauseClockButton = const Icon(Icons.pause_sharp);

// Time constants
  int kWorkDuration = 1;
  final CountDownController _clockController = CountDownController();
  Icon _clockButton = const Icon(Icons.play_arrow_sharp); // Initial value
  bool _isClockStarted = false; // Conditional flag
  // bool _isScreenLight = false;

  late NavigationService _navigation;

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
    _navigation = GetIt.instance.get<NavigationService>();
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
      duration: kWorkDuration * 160,
      isReverse: true,
      textStyle: const TextStyle(color: Colors.blue, fontSize: 40.0),
      fillColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.white12,
      strokeCap: StrokeCap.round,
      onComplete: () {
        /*这里要延时加载  否则会抱The widget on which setState() or markNeedsBuild() was called was:错误*/
        Future.delayed(Duration(milliseconds: 200)).then((e) {
          setState(() async {
            // _navigation.goBack();
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
                            setState(() {
                              switchClockActionButton();
                            });
                          },
                          child: _clockButton,
                        ),
                        IconButton(
                          onPressed: () {
                            //接白名单和锁机模块
                          },
                          icon: const Icon(Icons.apps),
                        ),
                        IconButton(
                          onPressed: () {
                            //接深度学习图像检测模块
                          },
                          icon: const Icon(Icons.photo_camera),
                        ),
                        IconButton(
                          onPressed: () {
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
            _navigation.goBack();
            //先判断此时status为done还是doing
            //发送网络请求，status变化 doing->todo
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
