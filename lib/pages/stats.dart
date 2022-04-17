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
  const StatsPage({Key? key, required this.uid}) : super(key: key);
  final String uid;
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
  int startmonth = 0;
  int endmonth = 11;
  int cnt = 0;
  int focustime = 0;
  int hour = 0;
  int min = 0;
  List<charts.Series<StatsModel, int>> _seriesBarData = [];
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
    cnt = 0;
    focustime = 0;
    List<StatsModel> stats = List.generate(
        12,
        (index) => StatsModel(
            focustime: 0, nummonth: index + 1, month: months[index]));

    for (var i = 0; i < todos.length; i++) {
      int m = todos[i].start_time.month;
      if (todos[i].status == 'done') {
        stats[m - 1].focustime += todos[i].interval;
        cnt++;
        focustime += todos[i].interval;
      }
    }
    startmonth = 0;
    endmonth = 11;
    while (startmonth < 11 && stats[startmonth].focustime == 0) {
      startmonth++;
    }
    while (endmonth > 0 && stats[endmonth].focustime == 0) {
      endmonth--;
    }
    if (startmonth == 11 && endmonth == 0) {
      startmonth = DateTime.now().month - 1;
      endmonth = DateTime.now().month;
    }
    endmonth += 1;
    startmonth += 1;
    hour = focustime ~/ 60;
    min = focustime % 60;
    return stats;
  }

  _generateData(mydata) {
    //_seriesBarData = List<charts.Series<Sales, String>> [];
    _seriesBarData.add(
      charts.Series(
        domainFn: (StatsModel stats, _) => stats.nummonth,
        measureFn: (StatsModel stats, _) => stats.focustime,
        id: 'month',
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
        body: SafeArea(
            child: Container(
      width: _deviceWidth,
      height: _deviceHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          TopBar(
            '数据统计',
            primaryAction: IconButton(
              onPressed: () {
                _navigation.goBack();
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color.fromRGBO(0, 82, 218, 1),
              ),
            ),
          ),
          SizedBox(
            height: _deviceHeight * 0.025,
          ),
          _buildBody(context),
        ],
      ),
    )));
  }

  Widget _buildBody(BuildContext context) {
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
            stream: _database.getUserTodoList(widget.uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const LinearProgressIndicator();
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
                statsdata = generate_statsdata(todos);
                _generateData(statsdata);
                return Column(
                  children: [
                    _buildCard(),
                    SizedBox(
                      height: _deviceHeight * 0.025,
                    ),
                    _buildChart(context)
                  ],
                );
              }
            }));
  }

  Widget _buildCard() {
    const bigerstyle = TextStyle(color: Colors.lightBlue, fontSize: 30);
    const smallerstyle = TextStyle(color: Colors.lightBlue, fontSize: 20);
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.blueGrey),
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: SizedBox(
        height: _deviceHeight * 0.2,
        width: _deviceWidth * 0.9,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          const Text(
            '累计专注',
            style: bigerstyle,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('次数', style: smallerstyle),
                Text(
                  '时长',
                  style: smallerstyle,
                )
              ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '$cnt',
                style: smallerstyle,
              ),
              Text(
                '$hour小时$min分钟',
                style: smallerstyle,
              )
            ],
          )
        ]),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: _deviceHeight * 0.6,
        width: _deviceWidth * 0.9,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: charts.LineChart(_seriesBarData,
                    animate: true,
                    animationDuration: const Duration(seconds: 2),
                    defaultRenderer: charts.LineRendererConfig(
                      includePoints: true,
                    ),
                    behaviors: [
                      charts.ChartTitle('专注时常分布',
                          titleStyleSpec:
                              const charts.TextStyleSpec(fontSize: 25),
                          behaviorPosition: charts.BehaviorPosition.top,
                          titleOutsideJustification:
                              charts.OutsideJustification.start,
                          innerPadding: 18),
                      charts.LinePointHighlighter(
                          showHorizontalFollowLine:
                              charts.LinePointHighlighterFollowLineType.nearest,
                          showVerticalFollowLine:
                              charts.LinePointHighlighterFollowLineType.none),
                      charts.SelectNearest(
                          eventTrigger: charts.SelectionTrigger.tapAndDrag)
                    ],
                    domainAxis: charts.NumericAxisSpec(
                        viewport: charts.NumericExtents(startmonth, endmonth),
                        tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
                            (num? value) => '${value!.toInt()}月'))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
