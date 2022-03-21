// Packages
import 'package:chatifyapp/pages/home_page.dart';
import 'package:chatifyapp/pages/whitelist_page.dart';
import 'package:chatifyapp/providers/chat_page_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'dart:async';

// Widgets
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';
//page
import 'package:chatifyapp/pages/chat_page.dart';
// Models
import '../models/chats_model.dart';

// Providers
import '../providers/authentication_provider.dart';
import '../providers/chat_page_provider.dart';

import '../services/navigation_service.dart';

class WhiteListPage extends StatefulWidget {
  const WhiteListPage(
      {Key? key, required this.sender_role, required this.receiver_role})
      : super(key: key);
  final String sender_role, receiver_role;
  @override
  State<WhiteListPage> createState() => _WhiteListPageState();
}

class _WhiteListPageState extends State<WhiteListPage> {
  late double _deviceWidth;
  late double _deviceHeight;
  bool is_sent = false;
  bool checkState = false;
  List<String> appList = [];
  late AuthenticationProvider _auth;
  late ChatPageProvider _pageProvider;
  late NavigationService _navigation;
  late GlobalKey<FormState> _messageFormState;
  late ScrollController _messagesListViewController;
  String str = "";

  int _count = 0;
  void myTimer() {
    // 定义一个函数，将定时器包裹起来
    Timer _timer = Timer.periodic(Duration(milliseconds: 3000), (t) {
      // print("111111");
      _count++;
      if (_count == 15) {
        t.cancel(); // 定时器内部触发销毁
      }
      _getAppList();
      // _initBlueTooth();
    });
  }

  Set<int> selected = Set<int>();
  @override
  void initState() {
    // _initBlueTooth();
    super.initState();
    checkState = true;
    myTimer();
  }

  void _getAppList() async {
    const platform = const MethodChannel('samples.flutter.dev');
    // Future future = platform.invokeMethod('initBlueTooth');
    try {
      // 通过渠道，调用原生代码代码的方法
      //Future future = channel.invokeMethod("your_method_name", {"msg": msg} );
      String str = await platform.invokeMethod('getAppList');
      // 打印执行的结果
      // print(str);
      // _appList = str;
      var strList = str.split('/n');
      for (var i = 0; i < strList.length - 1; i++) {
        appList.add(strList[i]);
      }
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  void _launch() async {
    const platform = const MethodChannel('samples.flutter.dev');
    // Future future = platform.invokeMethod('initBlueTooth');
    try {
      // 通过渠道，调用原生代码代码的方法
      //Future future = channel.invokeMethod("your_method_name", {"msg": msg} );
      String str = await platform.invokeMethod('launch');
      // 打印执行的结果
      print(str);
      // _appList = str;
      var strList = str.split('/n');
      for (var i = 0; i < strList.length - 1; i++) {
        appList.add(strList[i]);
      }
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  void _appLock() async {
    const platform = const MethodChannel('samples.flutter.dev');
    // Future future = platform.invokeMethod('initBlueTooth');
    try {
      // 通过渠道，调用原生代码代码的方法
      //Future future = channel.invokeMethod("your_method_name", {"msg": msg} );
      String str = await platform.invokeMethod('appLock');
      // 打印执行的结果
      print(str);
      // _appList = str;
      var strList = str.split('/n');
      for (var i = 0; i < strList.length - 1; i++) {
        appList.add(strList[i]);
      }
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  List<String> generateAppList(List<int> numseq) {
    List<String> Applist =
        new List.generate(numseq.length, (index) => appList[numseq[index]]);
    return Applist;
  }

  String generateMessage(List<String> appList) {
    String str = appList[0];
    for (var i = 1; i < appList.length; i++) {
      str = str + ',' + appList[i];
    }
    return str;
  }

  Future<void> showAlertDialog(BuildContext context) async {
    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("确认"),
          content: const Text("请问确定要发送白名单吗?"),
          actions: [
            FlatButton(
              child: Text("取消"),
              onPressed: () {
                print('in the cancel alert the context is $context');
                //tmp = false;
                is_sent = false;
                //_navigation.goBack();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
                child: const Text("确定"),
                onPressed: () {
                  print('in the continue alert the context is $context');
                  is_sent = true;
                  //Navigator.pop(context, str);
                  //_navigation.goBack();
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: _deviceWidth * .03, vertical: _deviceHeight * .02),
          width: _deviceWidth,
          height: _deviceHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TopBar(
                "白名单",
                //widget.chat.title(),
                fontSize: 16,
                primaryAction: IconButton(
                  onPressed: () {
                    //print('back');
                    _navigation.goBack();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Color.fromRGBO(0, 82, 218, 1),
                  ),
                ),
              ),
              RaisedButton(
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder: (context1, setState) {
                        return Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20.0),
                              topRight: const Radius.circular(20.0),
                            ),
                          ),
                          height: MediaQuery.of(context).size.height / 2.0,
                          child: Column(children: [
                            _getModalSheetHeaderWithConfirm(
                              '白名单选择',
                              onCancel: () {
                                Navigator.of(context).pop();
                              },
                              onConfirm: () {
                                Navigator.of(context).pop(selected.toList());
                                List<String> tmp =
                                    generateAppList(selected.toList());
                                str = generateMessage(tmp);
                                Navigator.pop(context, str);
                              },
                            ),
                            const Divider(height: 1.0),
                            Expanded(
                              child: ListView.builder(
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    trailing: Icon(
                                        selected.contains(index)
                                            ? Icons.check_box
                                            : Icons.check_box_outline_blank,
                                        color: Theme.of(context).primaryColor),
                                    title: Text(appList[index]),
                                    onTap: () {
                                      setState(() {
                                        if (selected.contains(index)) {
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
                child: const Text("白名单选择"),
              ),
              RaisedButton(
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder: (context1, setState) {
                        return Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20.0),
                              topRight: const Radius.circular(20.0),
                            ),
                          ),
                          height: MediaQuery.of(context).size.height / 2.0,
                          child: Column(children: [
                            _getModalSheetHeaderWithConfirm(
                              '打开其他APP',
                              onCancel: () {
                                Navigator.of(context).pop();
                              },
                              onConfirm: () {
                                Navigator.of(context).pop(selected.toList());
                              },
                            ),
                            const Divider(height: 1.0),
                            Expanded(
                              child: ListView.builder(
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    title: Text(appList[index]),
                                    onTap: () {},
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
                child: const Text("打开其他APP"),
              ),
            ],
          ),
        ),
      ),
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
              color: Colors.blue,
            ),
            onPressed: () {
              onConfirm();
            }),
      ],
    ),
  );
}
