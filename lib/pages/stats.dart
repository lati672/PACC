// Packages
import 'package:chatifyapp/pages/home_page.dart';
import 'package:chatifyapp/pages/whitelist_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

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

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late double _deviceWidth;
  late double _deviceHeight;
  late double _deviceTop;
  late DatabaseService _database;
  late AuthenticationProvider _auth;
  late ChatPageProvider _pageProvider;
  late NavigationService _navigation;

  @override
  Widget build(BuildContext context) {
    // * Initializations
    _database = GetIt.instance.get<DatabaseService>();
    _deviceTop = MediaQuery.of(context).padding.top;
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();

    return _buildUI();
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
                  const TopBar(
                    'Stats',
                    fontSize: 16,
                  ),
                  //Expanded(child: _messagesListView()),
                ]),
          ),
        ));
      },
    );
  }
}
