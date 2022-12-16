// Packages
import 'package:PACCPolicyapp/models/comment_model.dart';
import 'package:PACCPolicyapp/models/thread_model.dart';
import 'package:PACCPolicyapp/pages/editor/editor.dart';
import 'package:PACCPolicyapp/pages/threads/thread.dart';
import 'package:PACCPolicyapp/providers/threads_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:timeago/timeago.dart' as timeago;
// Providers
import 'package:PACCPolicyapp/providers/authentication_provider.dart';

// Services
import 'package:PACCPolicyapp/services/database_service.dart';
import 'package:PACCPolicyapp/services/media_service.dart';
import 'package:PACCPolicyapp/services/cloud_storage_service.dart';
import 'package:PACCPolicyapp/services/navigation_service.dart';

// Pages

// Models
import 'package:PACCPolicyapp/models/chat_user_model.dart';

//Widget
import 'package:PACCPolicyapp/widgets/top_bar.dart';
import 'package:PACCPolicyapp/widgets/rounded_image_network.dart';

class ThreadsPage extends StatefulWidget {
  ThreadsPage({Key? key}) : super(key: key);

  @override
  _ThreadsPageState createState() => _ThreadsPageState();
}

class _ThreadsPageState extends State<ThreadsPage> {
  final TextEditingController _textController = TextEditingController();
  late ChatUserModel user;
  late DatabaseService _database;
  late AuthenticationProvider _auth;
  late double _deviceWidth;
  late double _deviceHeight;
  late CloudStorageService _cloudStorageService;
  late CloudStorageService _storage;
  late MediaService _media;
  late NavigationService _navigation;
  PlatformFile? _ChatImage;
  late ThreadsProvider _pageProvider;
  bool _isComposing = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _storage = GetIt.instance.get<CloudStorageService>();
    _auth = Provider.of<AuthenticationProvider>(context);
    _database = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    user = _auth.user;
    return MultiProvider(providers: [
      ChangeNotifierProvider<ThreadsProvider>(
        create: (_) => ThreadsProvider(_auth),
      )
    ], child: _buildUI());
  }

  Widget _buildUI() {
    return Builder(builder: (_context) {
      _pageProvider = _context.watch<ThreadsProvider>();
      return Container(
        width: _deviceWidth * .97,
        height: _deviceHeight * .98,
        padding: EdgeInsets.symmetric(
          horizontal: _deviceWidth * .03,
          vertical: _deviceHeight * .02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            TopBar(
              'Threads',
              primaryAction: IconButton(
                onPressed: () {
                  _navigation.navigateToPage(EditorPage());
                },
                icon: const Icon(
                  Icons.add,
                ),
              ),
            ),
            _Threads(),
          ],
        ),
      );
    });
  }

  Widget _Threads() {
    List<ThreadModel>? _threads = _pageProvider.threads;
    return Expanded(
      child: (() {
        if (_pageProvider.threads != null) {
          if (_pageProvider.threads!.isNotEmpty) {
            return ListView.builder(
              itemCount: _pageProvider.threads!.length,
              itemBuilder: (BuildContext _context, int _index) {
                return InkWell(
                  onTap: () {
                    _navigation.navigateToPage(
                        ThreadPage(thread: _pageProvider.threads![_index]));
                  },
                  child: forum(_pageProvider.threads![_index]),
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                'No Threads Found.',
                style: TextStyle(
                  color: Colors.black,
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
      })(),
    );
  }

  Widget forum(ThreadModel _thread) {
    // print('in the forum');
    //_thread.output;
    bool voted = _thread.votedusers.contains(_auth.user.uid) ? true : false;
    return Column(
      children: <Widget>[
        Container(
          width: _deviceWidth * 0.9,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 46, 170, 223),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0)),
          ),
          child: Row(
            children: <Widget>[
              const Padding(padding: EdgeInsets.only(left: 2.0)),
              RoundedImageNetwork(
                  imagePath: _thread.avatar, size: _deviceWidth * 0.1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(_thread.username),
                    Text(timeago.format(_thread.time)),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.thumb_up,
                          color: voted ? Colors.green : Colors.white,
                        ),
                        onPressed: () {
                          _pageProvider.vote(_thread.id);
                        },
                      )),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(_thread.likes.toString()),
                  ),
                  const Padding(padding: EdgeInsets.only(right: 2.0)),
                ],
              )
            ],
          ),
        ),
        Container(
          width: _deviceWidth * 0.9,
          margin: const EdgeInsets.only(left: 2.0, right: 2.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: Text(
            _thread.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          width: _deviceWidth * 0.9,
          margin: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0))),
          child: Text(_thread.body.replaceAll("<br>", "\n")),
        ),
      ],
    );
  }
}
