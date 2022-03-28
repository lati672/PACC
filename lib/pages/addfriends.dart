//packages
import 'dart:io';

import 'package:chatifyapp/models/chat_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
//Provider
import '../providers/authentication_provider.dart';
// Widget
import '../widgets/top_bar.dart';
// Services
import '../services/navigation_service.dart';
import '../services/database_service.dart';

class AddFriendsPage extends StatefulWidget {
  @override
  _AddFriendsPageState createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  final TextEditingController _EmailtextController =
      new TextEditingController();
  final TextEditingController _NametextController = new TextEditingController();
  bool _EmailisComposing = false;
  bool _NameisComposing = false;
  List<Text> AlertTitle = [
    const Text('用户未找到'),
    const Text('不能添加自己'),
    const Text('成功发送请求'),
    const Text('你们已经是好友'),
    const Text('用户未找到'),
    const Text('不能添加自己'),
    const Text('添加错误'),
    const Text('添加错误'),
  ];
  List<Text> AlertContent = [
    const Text('请输入正确的邮箱'),
    const Text('请输入正确的邮箱'),
    const Text('成功'),
    const Text('不能重复添加'),
    const Text('请输入正确的用户名'),
    const Text('请输入正确的用户名'),
    const Text('家长不能添加家长'),
    const Text('学生不能添加学生')
  ];
  // Responsive UI for diferent devices
  late DatabaseService _database;
  late NavigationService _navigation;
  late double _deviceWidth;
  late double _deviceHeight;
  late AuthenticationProvider _auth;
  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    _database = GetIt.instance.get<DatabaseService>();
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: _deviceWidth * .03,
            vertical: _deviceHeight * .02,
          ),
          width: _deviceWidth * .97,
          height: _deviceHeight * .98,
          child: Column(
            children: [
              TopBar(
                'Chats',
                primaryAction: IconButton(
                  onPressed: () {
                    _navigation.goBack();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Color.fromRGBO(0, 82, 218, 1),
                  ),
                ),
              ),
              _AddFriendbyEmail(),
              _AddFriendbyName(),
            ],
          ),
        ),
      ),
    );
  }

  //Submitted by email
  void _EmailhandleSubmitted(text) {
    //print(_EmailtextController.text);
    addfriend(1);

    _EmailtextController.clear();
    setState(() {
      _EmailisComposing = false;
    });
  }

  //Submitted by user name
  void _NamehandleSubmitted(text) {
    //print(_NametextController.text);
    addfriend(2);

    _NametextController.clear();
    setState(() {
      _NameisComposing = false;
    });
  }

  //Show Alert based on alert type
  void _showAlert(BuildContext context, int AlertType) {
    final alert = AlertDialog(
      title: AlertTitle[AlertType],
      content: AlertContent[AlertType],
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

  //Get the user id
  Future<String> getUserId(int type) async {
    QuerySnapshot qshot;
    if (type == 1) {
      qshot = await _database.getUserbyEmail(_EmailtextController.text);
    } else {
      qshot = await _database.getUserbyName(_NametextController.text);
    }
    if (qshot.size == 0 && type == 1) {
      _showAlert(context, 0);
      return "";
    } else if (qshot.size == 0 && type == 2) {
      _showAlert(context, 4);
      return "";
    }
    List<ChatUserModel> l = qshot.docs
        .map((e) => ChatUserModel(
            uid: qshot.docs.first.id,
            name: e.get('name'),
            email: e.get('email'),
            imageUrl: e.get('image'),
            role: e.get('role'),
            lastActive: DateTime.now()))
        .toList();
    return l[0].uid;
  }

  //type=1:email;type=2:name
  void addfriend(int type) async {
    String userid = _auth.user.uid;
    String friendid = await getUserId(type);
    if (friendid == "") {
      return;
    }
    //Email,the friend id is same as the user id
    if (_auth.user.uid == friendid && type == 1) {
      _showAlert(context, 1);
      return;
    }
    //Name, the friend id is same as the user id
    else if (_auth.user.uid == friendid && type == 2) {
      _showAlert(context, 5);
      return;
    }
    String user1role = await _database.getRoleBySenderID(userid);
    String user2role = await _database.getRoleBySenderID(friendid);
    //Parent cannot add another parent
    if (user1role == 'Parent' && user2role == 'Parent') {
      _showAlert(context, 6);
      return;
    }
    //Student cannot add another student
    if (user1role == 'Student' && user2role == 'Student') {
      _showAlert(context, 7);
      return;
    }
    //the relationship of chat already exist
    if ((await _database.checkPSrel(userid, friendid)) ||
        (await _database.checkChatexist(userid, friendid))) {
      _showAlert(context, 3);
      return;
    }
    List<String> usersid = List.from([userid, friendid]);

    await _database.friendrequest(userid, true, false, usersid);
    //successfully created the chat
    _showAlert(context, 2);
  }

  Widget _AddFriendbyEmail() {
    return IconTheme(
        data: IconThemeData(color: Theme.of(context).accentColor),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(children: <Widget>[
              Flexible(
                  child: TextField(
                controller: _EmailtextController,
                onChanged: (String text) {
                  setState(() {
                    _EmailisComposing = text.length > 0;
                  });
                },
                onSubmitted: _EmailhandleSubmitted,
                decoration: const InputDecoration(
                    filled: true, fillColor: Colors.white, hintText: '输入邮箱'),
              )),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _EmailisComposing
                        ? () => _EmailhandleSubmitted(_EmailtextController.text)
                        : null),
              )
            ])));
  }

  Widget _AddFriendbyName() {
    return IconTheme(
        data: IconThemeData(color: Theme.of(context).accentColor),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(children: <Widget>[
              Flexible(
                  child: TextField(
                controller: _NametextController,
                onChanged: (String text) {
                  setState(() {
                    _NameisComposing = text.length > 0;
                  });
                },
                onSubmitted: _NamehandleSubmitted,
                decoration: const InputDecoration(
                    filled: true, fillColor: Colors.white, hintText: '输入用户名'),
              )),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _NameisComposing
                        ? () => _NamehandleSubmitted(_NametextController.text)
                        : null),
              )
            ])));
  }
}
