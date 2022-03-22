import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import '../pages/countdown_timer.dart';
import '../utils/constants.dart';
import 'package:ndialog/ndialog.dart';
import '../pages/whitelist_page.dart';

class PomodoroPage extends StatefulWidget {
  @override
  _PomodoroPageState createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  final CountDownController _clockController = CountDownController();
  Icon _clockButton = kPlayClockButton; // Initial value
  bool _isClockStarted = false; // Conditional flag

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
    // Half Screen Dimensions
    final double height = MediaQuery.of(context).size.height / 2;
    final double width = MediaQuery.of(context).size.width / 2;

    CountDownTimer _countDownTimer = CountDownTimer(
      duration: kWorkDuration,
      fillColor: Colors.pink,
      onComplete: () {
        /*这里要延时加载  否则会抱The widget on which setState() or markNeedsBuild() was called was:错误*/
        Future.delayed(Duration(milliseconds: 200)).then((e) {
          setState(() async {
            // await NDialog(
            //   dialogStyle: DialogStyle(titleDivider: true),
            //   title: Text("Timer Completed"),
            //   content: Text("Time to break."),
            //   actions: <Widget>[
            //     ElevatedButton(
            //         style: ButtonStyle(
            //           backgroundColor: MaterialStateColor.resolveWith(
            //               (states) => Colors.green),
            //         ),
            //         child: Text("Start a short break"),
            //         onPressed: () {}),
            //   ],
            // ).show(context);
          });
        });
      },
    );

    CircularCountDownTimer clock = CircularCountDownTimer(
      controller: _clockController,
      isReverseAnimation: true,
      ringColor: Color(0xff0B0C19),
      height: height,
      width: width,
      autoStart: false,
      duration: _countDownTimer.duration * 60,
      isReverse: true,
      textStyle: TextStyle(color: Colors.white),
      fillColor: _countDownTimer.fillColor,
      backgroundColor: Color(0xFF2A2B4D),
      strokeCap: StrokeCap.round,
      onComplete: _countDownTimer.onComplete(),
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
              Text(
                "进行中",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      switchClockActionButton();
                    });
                  },
                  child: Container(
                      // width: width / 2.5,
                      // height: height / 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      // child: _clockButton,
                      child: Row(
                        children: [
                          _clockButton,
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.headset_off),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.wb_sunny),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.stop),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.screen_rotation),
                          ),
                        ],
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
