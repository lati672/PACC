// Packages
import 'package:chatifyapp/pages/home_page.dart';
import 'package:chatifyapp/pages/whitelist_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('KindaCode.com'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: BarChart(BarChartData(
            borderData: FlBorderData(
                border: const Border(
              top: BorderSide.none,
              right: BorderSide.none,
              left: BorderSide(width: 1),
              bottom: BorderSide(width: 1),
            )),
            groupsSpace: 10,
            barGroups: [
              BarChartGroupData(x: 1, barRods: [
                BarChartRodData(toY: 10, width: 15, color: Colors.amber),
              ]),
              BarChartGroupData(x: 2, barRods: [
                BarChartRodData(toY: 9, width: 15, color: Colors.amber),
              ]),
              BarChartGroupData(x: 3, barRods: [
                BarChartRodData(toY: 4, width: 15, color: Colors.amber),
              ]),
              BarChartGroupData(x: 4, barRods: [
                BarChartRodData(toY: 2, width: 15, color: Colors.amber),
              ]),
              BarChartGroupData(x: 5, barRods: [
                BarChartRodData(toY: 13, width: 15, color: Colors.amber),
              ]),
              BarChartGroupData(x: 6, barRods: [
                BarChartRodData(toY: 17, width: 15, color: Colors.amber),
              ]),
              BarChartGroupData(x: 7, barRods: [
                BarChartRodData(toY: 19, width: 15, color: Colors.amber),
              ]),
              BarChartGroupData(x: 8, barRods: [
                BarChartRodData(toY: 21, width: 15, color: Colors.amber),
              ]),
            ])),
      ),
    );
  }
}
