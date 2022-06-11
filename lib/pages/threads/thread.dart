// Packages

import 'package:PACCPolicyapp/models/comment_model.dart';
import 'package:PACCPolicyapp/models/thread_model.dart';
import 'package:PACCPolicyapp/widgets/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:timeago/timeago.dart' as timeago;
// Providers
import 'package:PACCPolicyapp/providers/authentication_provider.dart';
import 'package:PACCPolicyapp/providers/thread_provider.dart';
// Services
import 'package:PACCPolicyapp/services/database_service.dart';
import 'package:PACCPolicyapp/services/media_service.dart';
import 'package:PACCPolicyapp/services/cloud_storage_service.dart';
import 'package:PACCPolicyapp/services/navigation_service.dart';

// Pages

// Models
import 'package:PACCPolicyapp/models/chat_user_model.dart';

//Widget
import 'package:PACCPolicyapp/widgets/rounded_image_network.dart';

class ThreadPage extends StatefulWidget {
  ThreadPage({Key? key, required this.thread}) : super(key: key);
  final ThreadModel thread;
  @override
  _ThreadPageState createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
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
  late CommentProvider _pageProvider;
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
      ChangeNotifierProvider<CommentProvider>(
        create: (_) => CommentProvider(_auth, widget.thread),
      )
    ], child: _buildUI());
  }

  Widget _buildUI() {
    widget.thread.output();
    return Builder(builder: (_context) {
      _pageProvider = _context.watch<CommentProvider>();

      return Scaffold(
        body: Container(
          width: _deviceWidth,
          height: _deviceHeight,
          child: _Thread(),
          /*Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              TopBar(
                'Thread',
                secondaryAction: IconButton(
                  onPressed: () {
                    _navigation.goBack();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
              ),
              _Thread(),
            ],
          ),*/
        ),
      );
    });
  }

  Widget _Thread() {
    ThreadModel? _thread = _pageProvider.thread;

    if (_pageProvider.thread != null) {
      return scroll();
      // return forum(_pageProvider.thread!);
    } else {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      );
    }
  }

  Widget scroll() {
    ThreadModel _thread = _pageProvider.thread!;
    bool voted = _thread.votedusers.contains(_auth.user.uid) ? true : false;
    print('$_deviceHeight, $_deviceWidth');
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          toolbarHeight: 70,
          /*title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            /* IconButton(
              onPressed: () {
                _navigation.goBack();
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),*/
          ]),*/
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(20),
              child: Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: Center(
                    child: Text(
                  _thread.title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                )),
                width: double.maxFinite,
                padding: const EdgeInsets.only(top: 5, bottom: 10),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
              )),
          pinned: true,
          backgroundColor: Colors.greenAccent,
          expandedHeight: _deviceHeight * 0.15,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset(
              'assets/images/background_tree.jpg',
              width: double.maxFinite,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                    left: _deviceHeight / 34.15, right: _deviceHeight / 34.15),
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
                margin: EdgeInsets.only(
                    left: _deviceHeight / 34.15, right: _deviceHeight / 34.15),
                child: ExpandableText(
                  text: _thread.body.replaceAll("<br>", "\n"),
                  height: _deviceHeight,
                ),
              ),
              _buildTextComposer(_thread.id),
              _thread.comments == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    )
                  : comments(_thread.comments!)
            ],
          ),
        )
      ],
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
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0)),
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
        _buildTextComposer(_thread.id),
        _thread.comments == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              )
            : comments(_thread.comments!)
      ],
    );
  }

  void _handleSubmitted(String threadid) {
    _pageProvider.sendComment(threadid, _textController.text);
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  Widget _buildTextComposer(String threadid) {
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
                            hintText: 'leave your comment',
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
                                ? () => _handleSubmitted(threadid)
                                : null),
                      ))
                ]))));
  }

  Widget comments(List<CommentModel> _comments) {
    if (_comments.isEmpty) {
      return const Center(
        child: Text(
          'No Comments Found.',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      );
    }
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: _comments.length,
        itemBuilder: (BuildContext _context, int _index) {
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
                        imagePath: _comments[_index].avatar,
                        size: _deviceWidth * 0.1),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(_comments[_index].username),
                          Text(timeago.format(_comments[_index].time)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  width: _deviceWidth * 0.9,
                  margin:
                      const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0))),
                  child: Text(_comments[_index].comment)),
            ],
          );
        });
  }
}
