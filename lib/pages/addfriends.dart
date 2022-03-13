//packages
import 'package:chatifyapp/models/chat_user_model.dart';
import 'package:chatifyapp/models/chats_model.dart';
import 'package:chatifyapp/pages/chats_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
//Provider
import '../providers/authentication_provider.dart';
import '../providers/chat_page_provider.dart';
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
    Text('用户未找到'),
    Text('不能与自己建立聊天'),
    Text('成功添加聊天'),
    Text('聊天已经存在'),
    Text('用户未找到'),
    Text('不能与自己建立聊天'),
  ];
  List<Text> AlertContent = [
    Text('请输入正确的邮箱'),
    Text('请输入正确的邮箱'),
    Text('成功'),
    Text('不能重复添加聊天'),
    Text('请输入正确的用户名'),
    Text('请输入正确的用户名')
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

  void _EmailhandleSubmitted(text) {
    print(_EmailtextController.text);
    addfriend(1);

    _EmailtextController.clear();
    setState(() {
      _EmailisComposing = false;
    });
  }

  void _NamehandleSubmitted(text) {
    print(_NametextController.text);
    addfriend(2);

    _NametextController.clear();
    setState(() {
      _NameisComposing = false;
    });
  }

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

  Future<String> getUserList(int type) async {
    QuerySnapshot qshot;

    print('getting list');
    if (type == 1) {
      qshot = await _database.getUserbyEmail(_EmailtextController.text);
    } else {
      qshot = await _database.getUserbyName(_NametextController.text);
    }
    if (qshot.size == 0 && type == 1) {
      _showAlert(context, 0);
    } else if (qshot.size == 0 && type == 2) {
      _showAlert(context, 4);
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
    print('adding friends based on type: $type');
    String friendid = await getUserList(type);
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
    // the chat already exist
    if (await _database.checkChatexist(_auth.user.uid, friendid)) {
      _showAlert(context, 3);
      return;
    }
    List<String> usersid = new List.from([_auth.user.uid, friendid]);
    await _database.createChat(_auth.user.uid, true, false, usersid);
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
