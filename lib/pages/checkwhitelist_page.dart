// Packages
// ignore_for_file: non_constant_identifier_names

import 'package:chatifyapp/pages/home_page.dart';
import 'package:chatifyapp/pages/whitelist_page.dart';
import 'package:chatifyapp/providers/chat_page_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
// Widgets
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';
//page
import '../providers/authentication_provider.dart';
import '../services/navigation_service.dart';

class CheckWhiteListPage extends StatefulWidget {
  const CheckWhiteListPage(
      {Key? key,
      required this.applist,
      required this.sender_role,
      required this.receiver_role})
      : super(key: key);
  final List<String> applist;
  final String sender_role, receiver_role;
  @override
  State<CheckWhiteListPage> createState() => _CheckWhiteListPageState();
}

class _CheckWhiteListPageState extends State<CheckWhiteListPage> {
  late double _deviceWidth;
  late double _deviceHeight;
  bool is_sent = false;
  bool checkState = false;
  late AuthenticationProvider _auth;
  late ChatPageProvider _pageProvider;
  late NavigationService _navigation;
  late ScrollController _messagesListViewController;
  String str = "";

  Set<int> selected = Set<int>();
  @override
  void initState() {
    super.initState();
    checkState = true;
  }

  List<String> generateAppList(List<int> numseq) {
    List<String> tmp = [''];
    if (numseq.isNotEmpty) {
      // ignore: non_constant_identifier_names
      List<String> Applist = List.generate(
          numseq.length, (index) => widget.applist[numseq[index]]);
      return Applist;
    } else {
      return tmp;
    }
  }

  showAlertDialog(BuildContext context) {
    // show the dialog
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("确认"),
          content: const Text("您只能查看白名单"),
          actions: [
            FlatButton(
                child: const Text("确定"),
                onPressed: () {
                  is_sent = true;

                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  String generateMessage(List<String> appList) {
    String str = appList[0];
    for (var i = 1; i < appList.length; i++) {
      str = str + ',' + appList[i];
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    _navigation = GetIt.instance.get<NavigationService>();

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: _deviceWidth * .03, vertical: _deviceHeight * .02),
          width: _deviceWidth,
          height: _deviceHeight,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _getModalSheetHeaderWithConfirm(
                  '审批白名单',
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
                        title: Text(widget.applist[index]),
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
                    itemCount: widget.applist.length,
                  ),
                ),
              ]),
        ),
      ),
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
