// Packages
import 'package:chatifyapp/pages/addfriends.dart';
import 'package:chatifyapp/pages/stats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

// Providers
import '../providers/authentication_provider.dart';

// Services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

// Pages
import 'package:chatifyapp/pages/parent_chat_page.dart';

//Widget
import '../widgets/top_bar.dart';
import '../widgets/rounded_image_network.dart';

// Models
import 'package:chatifyapp/models/chat_user_model.dart';
import 'package:chatifyapp/models/chats_model.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key, required this.role}) : super(key: key);
  final String role;

  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<FriendsPage> {
  final db = FirebaseFirestore.instance;
  late NavigationService _navigation;
  late AuthenticationProvider _auth;
  late DatabaseService _database;
  late double _deviceWidth;
  late double _deviceHeight;
  late String role;
  late String id;

  Widget Parentbuilder() {
    return Builder(
      builder: (_context) {
        //* Triggers the info in the widgets to render themselves
        return SizedBox(
          width: _deviceWidth,
          height: _deviceHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              TopBar(
                "您的孩子",
                primaryAction: IconButton(
                  onPressed: () {
                    // * Logout the user if he/she presses the button icon
                    _navigation.navigateToPage(AddFriendsPage());
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Color.fromRGBO(0, 82, 218, 1),
                  ),
                ),
              ),
              Expanded(
                  child: FutureBuilder<List<ChatUserModel>>(
                future: _database.getStudentsModel(_auth.user.uid),
                builder: (context, users) {
                  if (!users.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    List<ChatUserModel> _users = List.from(users.data!);

                    return ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                            height: _deviceHeight * 0.1,
                            width: _deviceWidth * 0.9,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RoundedImageNetwork(
                                    imagePath: _users[index].imageUrl,
                                    size: _deviceHeight * .08),
                                TextButton(
                                    onPressed: () async {
                                      String chatid = await _database.getChatid(
                                          _auth.user.uid, _users[index].uid);
                                      ChatsModel _chat =
                                          await _database.getChatsbyChatId(
                                              chatid, _auth.user.uid);
                                      _navigation.navigateToPage(
                                          ParentChatPage(chat: _chat));
                                    },
                                    child: Text(
                                      _users[index].name,
                                      style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 15, 11, 11),
                                          fontSize: 20),
                                    )),
                                IconButton(
                                    onPressed: () => {
                                          _navigation.navigateToPage(
                                              StatsPage(uid: _users[index].uid))
                                        },
                                    icon: const Icon(Icons.bar_chart))
                              ],
                            ));
                      },
                    );
                  }
                },
              )),
            ],
          ),
        );
      },
    );
  }

  Widget StudentBuilder() {
    return Builder(
      builder: (_context) {
        //* Triggers the info in the widgets to render themselves
        return Container(
          width: _deviceWidth,
          height: _deviceHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              TopBar(
                "您的家长",
                primaryAction: IconButton(
                  onPressed: () {
                    // * Logout the user if he/she presses the button icon
                    _navigation.navigateToPage(AddFriendsPage());
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Color.fromRGBO(0, 82, 218, 1),
                  ),
                ),
              ),
              Expanded(
                  child: FutureBuilder<List<ChatUserModel>>(
                future: _database.getParentsModel(_auth.user.uid),
                builder: (context, users) {
                  if (!users.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    List<ChatUserModel> _users = List.from(users.data!);
                    return ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                            height: _deviceHeight * 0.1,
                            width: _deviceWidth * 0.9,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RoundedImageNetwork(
                                    imagePath: _users[index].imageUrl,
                                    size: _deviceHeight * .08),
                                TextButton(
                                    onPressed: () async {
                                      String chatid = await _database.getChatid(
                                          _auth.user.uid, _users[index].uid);
                                      ChatsModel _chat =
                                          await _database.getChatsbyChatId(
                                              chatid, _auth.user.uid);
                                      _navigation.navigateToPage(
                                          ParentChatPage(chat: _chat));
                                    },
                                    child: Text(
                                      _users[index].name,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    )),
                                Container(width: _deviceWidth * 0.1)
                              ],
                            ));
                      },
                    );
                  }
                },
              )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    role = widget.role;
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    _navigation = GetIt.instance.get<NavigationService>();
    _auth = Provider.of<AuthenticationProvider>(context);
    _database = GetIt.instance.get<DatabaseService>();
    String userid = _auth.user.uid;
    if (role == 'Parent') {
      return Parentbuilder();
    } else {
      return StudentBuilder();
    }
  }
}
