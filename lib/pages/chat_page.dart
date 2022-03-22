// Packages
import 'package:chatifyapp/pages/checkwhitelist_page.dart';
import 'package:chatifyapp/pages/home_page.dart';
import 'package:chatifyapp/pages/whitelist_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:provider/provider.dart';
import 'package:chatifyapp/providers/chat_page_provider.dart';

// Services
import '../services/database_service.dart';
import '../services/navigation_service.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.chat}) : super(key: key);

  final ChatsModel chat;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = new TextEditingController();
  late double _deviceWidth;
  late double _deviceHeight;
  late DatabaseService _database;
  PlatformFile? _profileImage;
  late AuthenticationProvider _auth;
  late ChatPageProvider _pageProvider;
  late NavigationService _navigation;
  late GlobalKey<FormState> _messageFormState;
  late ScrollController _messagesListViewController;
  final Widget _page = const WhiteListPage();
  late String _role;

  bool _isComposing = false;
  Set<int> selected = Set<int>();
  @override
  void initState() {
    super.initState();
    _messageFormState = GlobalKey<FormState>();
    _messagesListViewController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    // * Initializations
    _database = GetIt.instance.get<DatabaseService>();
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    _role = _auth.user.role;
    return GestureDetector(
        onTap: () {
          //print('ontap');
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
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: _deviceWidth * .03,
                  vertical: _deviceHeight * .02),
              width: _deviceWidth,
              height: _deviceHeight,
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
                          //print('back');
                          _navigation.navigateToPage(HomePage());
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Color.fromRGBO(0, 82, 218, 1),
                        ),
                      ),
                    ),
                    _messagesListView(),
                    _buildTextComposer(),
                    Row(
                      //mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            iconSize: 20.0,
                            onPressed: () {
                              _pageProvider.sendImageMessage();
                            },
                            icon: const Icon(
                              Icons.image_sharp,
                              color: Colors.white,
                            )),
                        IconButton(
                            iconSize: 20.0,
                            onPressed: () async {
                              if (_role == 'Parent') {
                                _showAlert(context);
                              } else {
                                //_navigation.navigateToPage(WhiteListPage());
                                final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WhiteListPage(),
                                    ));
                                print('result: $result');
                                if (result != null) {
                                  _pageProvider.sendWhiteList(result);
                                  print(_pageProvider.getchatid());
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.add_chart,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ]),
            ),
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
                    filled: true, fillColor: Colors.white, hintText: '发送信息'),
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

  List<String> decodewhitelist(String whitelist) {
    return whitelist.split(',');
  }

// * Rendenring Messages from Firebase
  Widget _messagesListView() {
    if (_pageProvider.messages != null) {
      if (_pageProvider.messages!.isNotEmpty) {
        return SizedBox(
          height: _deviceHeight * .70,
          //height: _deviceHeight,
          child: ListView.builder(
            itemCount: _pageProvider.messages!.length,
            itemBuilder: (BuildContext _context, int _index) {
              final _message = _pageProvider.messages![_index];
              final _isOwnMessage = _message.senderID == _auth.user.uid;
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
                    );
                  }
                case MessageType.image:
                  {
                    return Image.network(_message.content);
                  }
                case MessageType.whitelist:
                  {
                    List<String> appList = decodewhitelist(_message.content);

                    return ElevatedButton.icon(
                      icon: _auth.user.role == 'Student'
                          ? Icon(Icons.send)
                          : Icon(Icons.ac_unit),
                      label: _auth.user.role == 'Parent'
                          ? Text("家长审核白名单")
                          : Text("学生查看白名单"),
                      onPressed: () async {
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckWhiteListPage(
                                applist: appList,
                                role: _auth.user.role,
                              ),
                            ));
                        print('result:  $result');
                        if (result != null) {
                          _pageProvider.sendWhiteList(result);
                          print(_pageProvider.getchatid());
                        }
                      },
                    );
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
            'Be the first to send a message!',
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
