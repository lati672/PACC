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
  final TextEditingController _textController = new TextEditingController();
  bool _isComposing = false;
  List<Text> AlertTitle = [
    Text('用户未找到'),
    Text('不能与自己建立聊天'),
    Text('成功添加聊天'),
    Text('聊天已经存在')
  ];
  List<Text> AlertContent = [
    Text('请输入正确的邮箱'),
    Text('请输入正确的邮箱'),
    Text('成功'),
    Text('不能重复添加聊天')
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
              _buildTextComposer(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmitted(text) {
    print(_textController.text);
    addfriends();

    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  void _showAlert(BuildContext context, int AlertType) {
    final alert = AlertDialog(
      title: AlertTitle[AlertType],
      content: AlertContent[AlertType],
      actions: [
        FlatButton(
            child: Text("确认"),
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

  Future<String> getUserList() async {
    QuerySnapshot qshot;

    print('getting list');
    qshot = await _database.getUserbyEmail(_textController.text);
    if (qshot.size == 0) {
      _showAlert(context, 0);
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

  void addfriends() async {
    print('adding friends');
    String friendid = await getUserList();
    if (_auth.user.uid == friendid) {
      _showAlert(context, 1);
      return;
    }
    List<String> usersid = new List.from([_auth.user.uid, friendid]);
    //print(_auth.user.name);
    //print(friendid);
    await _database.createChat(_auth.user.uid, true, false, usersid);
    _showAlert(context, 2);
  }

  Widget _buildTextComposer() {
    return IconTheme(
        data: IconThemeData(color: Theme.of(context).accentColor),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(children: <Widget>[
              Flexible(
                  child: TextField(
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration(
                    filled: true, fillColor: Colors.white, hintText: '输入邮箱'),
              )),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _isComposing
                        ? () => _handleSubmitted(_textController.text)
                        : null),
              )
            ])));
  }
}
