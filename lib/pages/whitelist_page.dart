// Packages
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'dart:async';

// Widgets
import '../widgets/top_bar.dart';

// Providers
import '../providers/authentication_provider.dart';
import '../providers/whitelist_provider.dart';

import '../services/navigation_service.dart';

class WhiteListPage extends StatefulWidget {
  const WhiteListPage(
      {Key? key, required this.sender_role, required this.receiver_role})
      : super(key: key);
  final String sender_role, receiver_role;
  @override
  State<WhiteListPage> createState() => _WhiteListPageState();
}

class _WhiteListPageState extends State<WhiteListPage> {
  late double _deviceWidth;
  late double _deviceHeight;
  bool is_sent = false;
  bool checkState = false;
  late AuthenticationProvider _auth;
  late WhitelistPageProvider _pageProvider;
  late NavigationService _navigation;
  late GlobalKey<FormState> _messageFormState;
  late ScrollController _messagesListViewController;
  String str = "";
  List<String> appList = [];
  List<String> pacakageNameList = [];

  Set<int> selected = Set<int>();
  @override
  void initState() {
    super.initState();
    checkState = true;
  }

  List<String> generateAppList(List<int> numseq) {
    List<String> Applist = new List.generate(
        numseq.length,
        (index) =>
            (appList[numseq[index]] + '+' + pacakageNameList[numseq[index]]));
    return Applist;
  }

  String generateMessage(List<String> appList) {
    String str = appList[0];
    for (var i = 1; i < appList.length; i++) {
      str = str + ',' + appList[i];
    }
    return str;
  }

  Future<void> showAlertDialog(BuildContext context) async {
    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("确认"),
          content: const Text("请问确定要发送白名单吗?"),
          actions: [
            FlatButton(
              child: Text("取消"),
              onPressed: () {
                //tmp = false;
                is_sent = false;
                //_navigation.goBack();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
                child: const Text("确定"),
                onPressed: () {
                  is_sent = true;
                  //Navigator.pop(context, str);
                  //_navigation.goBack();
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WhitelistPageProvider>(
          create: (_) => WhitelistPageProvider(_auth),
        )
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (_context) {
        //* Triggers the info in the widgets to render themselves
        _pageProvider = _context.watch<WhitelistPageProvider>();
        List<String>? _appList = _pageProvider.appList;
        List<String>? _pacakageNameList = _pageProvider.pacakageNameList;
        if (_appList != null && _pacakageNameList != null) {
          appList = _appList;
          pacakageNameList = _pacakageNameList;
        }
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
                  children: [
                    _getModalSheetHeaderWithConfirm(
                      '白名单选择',
                      onCancel: () {
                        Navigator.of(context).pop();
                      },
                      onConfirm: () {
                        List<String> tmp = generateAppList(selected.toList());
                        str = generateMessage(tmp);
                        Navigator.pop(context, str);
                      },
                    ),
                    const Divider(height: 1.0),
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
                    ),
                  ]),
            ),
          ),
        );
      },
    );
  }
}

Widget _getModalSheetHeaderWithConfirm(String title, {onCancel, onConfirm}) {
  return SizedBox(
    height: 50,
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            onCancel();
          },
        ),
        Expanded(
          child: Center(
            child: Text(
              title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          ),
        ),
        IconButton(
            icon: const Icon(
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
