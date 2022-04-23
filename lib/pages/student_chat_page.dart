// Packages
import 'package:chatifyapp/pages/home_page.dart';
import 'package:chatifyapp/pages/whitelist_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'dart:async';
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
import '../services/navigation_service.dart';
import '../services/database_service.dart';

class StudentChatPage extends StatefulWidget {
  const StudentChatPage({Key? key, required this.chat}) : super(key: key);

  final ChatsModel chat;

  @override
  _StudentChatPageState createState() => _StudentChatPageState();
}

class _StudentChatPageState extends State<StudentChatPage> {
  final TextEditingController _textController = TextEditingController();
  late double _deviceWidth;
  late double _deviceHeight;
  late double _deviceTop;
  late DatabaseService _database;
  late AuthenticationProvider _auth;
  late ChatPageProvider _pageProvider;
  late NavigationService _navigation;
  late GlobalKey<FormState> _messageFormState;
  final ScrollController _messagesListViewController = ScrollController();
  late String _memberid1, _memberid2;
  bool isfriends = false;
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _messageFormState = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    // * Initializations
    _database = GetIt.instance.get<DatabaseService>();
    _deviceTop = MediaQuery.of(context).padding.top;
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    //_database.getlatestWhitelistfromAlluser(_auth.user.uid);
    _memberid1 = widget.chat.members[1].uid;
    _memberid2 = widget.chat.members[0].uid;
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
              create: (_) => ChatPageProvider(
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
            body: SizedBox(
          width: _deviceWidth,
          height: _deviceHeight,
          child: SafeArea(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TopBar(
                    widget.chat.title(),
                    fontSize: 16,
                    primaryAction: IconButton(
                      icon: const Icon(
                        Icons.abc_outlined,
                        color: Color.fromRGBO(0, 82, 218, 1),
                      ),
                      onPressed: () async {
                        await _database.addAlarmToChat(
                            widget.chat.uid,
                            _auth.user.uid,
                            'https://firebasestorage.googleapis.com/v0/b/chatifyapp-87454.appspot.com/o/videos%2Ftodolists%2FHL34vJ1MrbTBAWBibA0P%2Fvideo.mp4?alt=media&token=38d1cf81-08bf-40ee-b7bd-2f3f20f8baf3');
                      },
                    ),
                    secondaryAction: IconButton(
                      onPressed: () {
                        _navigation.goBack();
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
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                String senderid = _auth.user.uid;
                                String receiverid = senderid == _memberid1
                                    ? _memberid2
                                    : _memberid1;
                                String senderrole =
                                    await _database.getRoleByID(senderid);
                                String receiverrole =
                                    await _database.getRoleByID(receiverid);
                                final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WhiteListPage(
                                          sender_role: senderrole,
                                          receiver_role: receiverrole),
                                    ));
                                if (result != null) {
                                  _pageProvider.sendWhiteList(result);
                                }
                              },
                              icon: const Icon(
                                Icons.add_chart,
                                color: Colors.black26,
                              )),
                        ],
                      )),
                ]),
          ),
        ));
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

  void _scrollDown() {
    _messagesListViewController.animateTo(
      _messagesListViewController.position.maxScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  Widget _buildTextComposer() {
    //Timer(const Duration(milliseconds: 1000), () => _scrollDown());
    //final position = _messagesListViewController.position.maxScrollExtent;
    //_messagesListViewController.jumpTo(position);
    print(widget.chat.uid);
    //发送消息框
    return IconTheme(
        data: IconThemeData(color: Theme.of(context).accentColor),
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

  void _confirmrequest(BuildContext context) {
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
                _pageProvider.sendFriendRequestReply();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

// * Rendenring Messages from Firebase
  Widget _messagesListView() {
    if (_pageProvider.messages != null) {
      if (_pageProvider.messages!.isNotEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: _deviceWidth * .02),
          color: const Color.fromRGBO(240, 240, 240, 1),
          child: ListView.builder(
            controller: _messagesListViewController,
            itemCount: _pageProvider.messages!.length,
            itemBuilder: (BuildContext _context, int _index) {
              final _message = _pageProvider.messages![_index];
              final _isOwnMessage = _message.senderID == _auth.user.uid;
              int confirmmessage_count = _pageProvider.countConfirm();

              switch (_message.type) {
                case MessageType.text:
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
                case MessageType.image:
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
                // case MessageType.confirm:
                //   {
                //     String senderid = _message.senderID;
                //     String receiverid =
                //     senderid == _memberid1 ? _memberid2 : _memberid1;
                //     int cnt =
                //     _pageProvider.countConfirmbefore(_message.sentTime);
                //     if (cnt == 0) {
                //       if (senderid == _auth.user.uid) {
                //         return const Text(
                //           '您已发送好友请求，请等待回复', style: TextStyle(),);
                //       } else {
                //         return TextButton(
                //           style: TextButton.styleFrom(
                //             textStyle: const TextStyle(fontSize: 20),
                //           ),
                //           onPressed: () {
                //             if (confirmmessage_count == 2) {
                //               null;
                //             } else {
                //               _confirmrequest(context);
                //             }
                //             //_confirmrequest(context);
                //           },
                //           child: Text(_message.content),
                //         );
                //       }
                //     } else {
                //       return Text(_message.content);
                //     }
                //   }
                case MessageType.confirm:
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
                case MessageType.todo:
                  {
                    return Text('${_message.content.toString()}');
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
              color: Colors.black12,
            ),
          ),
        );
      }
    } else {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.black12,
        ),
      );
    }
  }
}
