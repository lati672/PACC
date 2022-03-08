// Packages
import 'package:chatifyapp/models/chat_message_model.dart';
import 'package:chatifyapp/pages/home_page.dart';
import 'package:chatifyapp/pages/whitelist_page.dart';
import 'package:chatifyapp/providers/chat_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

// Widgets
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';

// Models
import '../models/chats_model.dart';

// Providers
import '../providers/authentication_provider.dart';
import '../providers/chat_page_provider.dart';

import '../services/navigation_service.dart';

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

  late AuthenticationProvider _auth;
  late ChatPageProvider _pageProvider;
  late NavigationService _navigation;
  late GlobalKey<FormState> _messageFormState;
  late ScrollController _messagesListViewController;
  final Widget _page = const WhiteListPage();

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
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();

    return GestureDetector(
        onTap: () {
          print('ontap');
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
                            onPressed: () {},
                            icon: const Icon(
                              Icons.image_sharp,
                              color: Colors.white,
                            )),
                        IconButton(
                            iconSize: 20.0,
                            onPressed: () async {
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

  Widget _getModalSheetHeaderWithConfirm(String title, {onCancel, onConfirm}) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              onCancel();
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
          ),
          IconButton(
              icon: Icon(
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

                case MessageType.whitelist:
                  {
                    List<String> appList = decodewhitelist(_message.content);
                    print('applist: $appList');
                    return Container();
                    /*return Column(
                      children: [
                        _getModalSheetHeaderWithConfirm('白名单'),
                        Divider(height: 1.0),
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
                        )
                      ],
                    );
                    return 
                    
                    
                    return ListView.builder(
                      itemCount: applist.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {},
                            child: Container(
                                height: 10.0,
                                margin: EdgeInsets.all(10),
                                child: Text(applist[index])));
                      },
                    );*/
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
