// Packages
import 'package:chatifyapp/pages/checkwhitelist_page.dart';
import 'package:chatifyapp/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

// Widgets
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';

// Models
import '../models/chats_model.dart';
import 'package:chatifyapp/models/chat_message_model.dart';

// Providers
import '../providers/authentication_provider.dart';
import '../providers/chat_page_provider.dart';

// Services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

class ParentChatPage extends StatefulWidget {
  const ParentChatPage({Key? key, required this.chat}) : super(key: key);

  final ChatsModel chat;

  @override
  _ParentChatPageState createState() => _ParentChatPageState();
}

class _ParentChatPageState extends State<ParentChatPage> {
  final TextEditingController _textController = TextEditingController();
  late double _deviceWidth;
  late double _deviceHeight;
  late AuthenticationProvider _auth;
  late ChatPageProvider _pageProvider;
  late NavigationService _navigation;
  late GlobalKey<FormState> _messageFormState;
  late ScrollController _messagesListViewController;
  late DatabaseService _database;
  bool _isComposing = false;
  late String _memberid1, _memberid2;
  bool isfriends = false;

  @override
  void initState() {
    super.initState();
    _messageFormState = GlobalKey<FormState>();
    _messagesListViewController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    // * Initializations
    _deviceWidth = MediaQuery
        .of(context)
        .size
        .width;
    _deviceHeight = MediaQuery
        .of(context)
        .size
        .height;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    _memberid1 = widget.chat.members[1].uid;
    _memberid2 = widget.chat.members[0].uid;
    _database = GetIt.instance.get<DatabaseService>();

    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<ChatPageProvider>(
              create: (_) =>
                  ChatPageProvider(
                    widget.chat.uid,
                    _auth,
                    _messagesListViewController,
                  ),
            )
          ],
          child: _buildUI(),
        ));
  }

  Widget _buildUI() {
    return Builder(
      builder: (_context) {
        _pageProvider = _context.watch<ChatPageProvider>();
        return Scaffold(
          body: SafeArea(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TopBar(
                    widget.chat.title(),
                    fontSize: 16,
                    primaryAction: IconButton(
                      onPressed: () {
                        _pageProvider.deleteChat();
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Color.fromRGBO(0, 82, 218, 1),
                      ),
                    ),
                    secondaryAction: IconButton(
                      onPressed: () {
                        _navigation.navigateToPage(HomePage());
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color.fromRGBO(0, 82, 218, 1),
                      ),
                    ),
                  ),
                  Expanded(child: _messagesListView()),
                  _buildTextComposer(),
                  SizedBox(
                    height: 35,
                    child: Row(
                      //mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            padding: const EdgeInsets.all(.01),
                            iconSize: 20,
                            onPressed: () {
                              _pageProvider.sendImageMessage();
                            },
                            icon: const Icon(
                              Icons.image_sharp,
                              color: Colors.black26,
                            )),
                        IconButton(
                            iconSize: 20,
                            padding: const EdgeInsets.all(.01),
                            onPressed: () async {
                              _showAlert(context);
                            },
                            icon: const Icon(
                              Icons.add_chart,
                              color: Colors.black26,
                            )),
                      ],
                    ),
                  )
                ]),
          ),
        );
      },
    );
  }

  void _showAlert(BuildContext context) {
    final alert = AlertDialog(
      title: const Text('不能申请白名单'),
      content: const Text('您是家长'),
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

  void _handleSubmitted(text) {
    _pageProvider.sendText(_textController.text);
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  void _confirmrequest(BuildContext context) {
    //加好友请求
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("您有新的好友请求"),
          content: const Text("确定要添加好友吗"),
          actions: <Widget>[
            FlatButton(
              child: const Text("取消"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text("确认"),
              onPressed: () {
                print('replying to the request');
                _pageProvider.sendFriendRequestReply();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildTextComposer() {
    //发送消息框
    return IconTheme(
        data: IconThemeData(color: Theme
            .of(context)
            .accentColor),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.0),
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(children: <Widget>[
                  Flexible(
                      fit: FlexFit.tight,
                      child: TextField(
                        controller: _textController,
                        onChanged: (String text) {
                          setState(() {
                            _isComposing = text.isNotEmpty;
                          });
                        },
                        onSubmitted: _handleSubmitted,
                        decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            filled: true,
                            fillColor: Colors.black12,
                            hintText: '发送信息',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide.none)),
                      )),
                  Container(
                      margin: const EdgeInsets.only(left: 4.0),
                      child: SizedBox(
                        width: 25,
                        height: 25,
                        child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.send),
                            onPressed: _isComposing
                                ? () => _handleSubmitted(_textController.text)
                                : null),
                      ))
                ]))));
  }

  List<String> decodewhitelist(String whitelist) {
    return whitelist.split(',');
  }

// * Rendering Messages from Firebase
  Widget _messagesListView() {
    if (_pageProvider.messages != null) {
      if (_pageProvider.messages!.isNotEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: _deviceWidth * .02),
          color: const Color.fromRGBO(240, 240, 240, 1),
          child: ListView.builder(
            itemCount: _pageProvider.messages!.length,
            itemBuilder: (BuildContext _context, int _index) {
              final _message = _pageProvider.messages![_index];
              final _isOwnMessage = _message.senderID == _auth.user.uid;
              int confirmmessage_count = _pageProvider.countConfirm();
              switch (_message.type) {
                case MessageType.text:
                  {
                    return CustomChatListViewTile(
                      //文本
                      width: _deviceWidth * .80,
                      deviceHeight: _deviceHeight,
                      isOwnMessage: _isOwnMessage,
                      message: _message,
                      sender: widget.chat.members
                          .where((element) => element.uid == _message.senderID)
                          .first,
                      receiverid: _memberid2,
                    );
                  }
                case MessageType.image:
                //图片
                  {
                    return CustomChatListViewTile(
                      width: _deviceWidth * .80,
                      deviceHeight: _deviceHeight,
                      isOwnMessage: _isOwnMessage,
                      message: _message,
                      sender: widget.chat.members
                          .where((element) => element.uid == _message.senderID)
                          .first,
                      receiverid: _memberid2,
                    );
                  }
              // case MessageType.whitelist:
              //   {
              //     //白名单
              //     List<String> appList = decodewhitelist(_message.content);
              //     String senderid = _message.senderID;
              //     String receiverid =
              //         senderid == _memberid1 ? _memberid2 : _memberid1;
              //     return ElevatedButton.icon(
              //       icon: const Icon(Icons.ac_unit),
              //       label: const Text("家长审核白名单"),
              //       onPressed: () async {
              //         String senderrole =
              //             await _database.getRoleBySenderID(senderid);
              //         String receiverrole =
              //             await _database.getRoleBySenderID(receiverid);
              //         final result = await Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) => CheckWhiteListPage(
              //                 applist: appList,
              //                 sender_role: senderrole,
              //                 receiver_role: receiverrole,
              //               ),
              //             ));
              //         //print('result:  $result');
              //         if (result != null) {
              //           _pageProvider.sendWhiteList(result);
              //           //print(_pageProvider.getchatid());
              //         }
              //       },
              //     );
              //   }
                case MessageType.whitelist:
                  {
                    return CustomChatListViewTile(
                      width: _deviceWidth * .80,
                      deviceHeight: _deviceHeight,
                      isOwnMessage: _isOwnMessage,
                      message: _message,
                      sender: widget.chat.members
                          .where((element) => element.uid == _message.senderID)
                          .first,
                      receiverid: _memberid2,
                    );
                  }
                case MessageType.confirm:
                  {
                    String senderid = _message.senderID;
                    String receiverid =
                    senderid == _memberid1 ? _memberid2 : _memberid1;
                    int cnt =
                    _pageProvider.countConfirmbefore(_message.sentTime);
                    if (cnt == 0) {
                      if (senderid == _auth.user.uid) {
                        return const Text('您已发送好友请求，请等待回复');
                      } else {
                        return TextButton(
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            if (confirmmessage_count == 2) {
                              null;
                            } else {
                              _confirmrequest(context);
                            }
                            //_confirmrequest(context);
                          },
                          child: Text(_message.content),
                        );
                      }
                    } else {
                      return Text(_message.content);
                    }
                  }
                default:
                  {
                    return Container();
                  }
              }
            },
          ),
        );
      } else {
        return const Align(
          alignment: Alignment.center,
          child: Text(
            '暂无消息',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        );
      }
    } else {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }
  }
}
