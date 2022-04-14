// Packages
import 'package:chatifyapp/models/stats_model.dart';
import 'package:chatifyapp/models/todo_list_model.dart';
import 'package:chatifyapp/pages/home_page.dart';
import 'package:chatifyapp/pages/whitelist_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';

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
  List<charts.Series<StatsModel, String>> _seriesBarData = [];
  List<StatsModel> statsdata = [];
  List<StatsModel> generate_statsdata(List<TodoListModel> todos) {
    List months = [
      '1月',
      '2月',
      '3月',
      '4月',
      '5月',
      '6月',
      '7月',
      '8月',
      '9月',
      '10月',
      '11月',
      '12月'
    ];
    List<StatsModel> stats = List.generate(
        12, (index) => StatsModel(focustime: 0, month: months[index]));

    for (var i = 0; i < todos.length; i++) {
      int m = todos[i].start_time.month;
      if (todos[i].status == 'done') {
        stats[m - 1].focustime += todos[i].interval;
      }
    }
    return stats;
  }

  _generateData(mydata) {
    //_seriesBarData = List<charts.Series<Sales, String>> [];
    _seriesBarData.add(
      charts.Series(
        domainFn: (StatsModel stats, _) => stats.month,
        measureFn: (StatsModel stats, _) => stats.focustime,
        id: 'Sales',
        data: mydata,
        labelAccessorFn: (StatsModel row, _) => "${row.month}",
      ),
    );
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

    return Scaffold(
      appBar: AppBar(title: Text('Stats')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _database.getUserTodoList(_auth.user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          } else {
            List<TodoListModel> todos = [];
            snapshot.data!.docs.forEach((doc) {
              todos.add(TodoListModel(
                  sent_time: doc['sent_time'].toDate(),
                  senderid: doc['senderid'],
                  start_time: doc['start_time'].toDate(),
                  status: doc['status'],
                  description: doc['description'],
                  todolist_name: doc['todolist_name'],
                  interval: doc['interval'],
                  recipients: List.from(doc['recipients']),
                  recipientsName: List.from(doc['recipientsName'])));
            });

            return _buildChart(context, todos);
          }
        });
  }

  Widget _buildChart(BuildContext context, List<TodoListModel> todos) {
    statsdata = generate_statsdata(todos);
    _generateData(statsdata);
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                '数据统计',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: charts.BarChart(
                  _seriesBarData,
                  animate: true,
                  animationDuration: Duration(seconds: 5),
                  behaviors: [
                    new charts.DatumLegend(
                      entryTextStyle: charts.TextStyleSpec(
                          color: charts.MaterialPalette.purple.shadeDefault,
                          fontFamily: 'Georgia',
                          fontSize: 18),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
