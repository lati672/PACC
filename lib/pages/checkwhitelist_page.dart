// Packages
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
import 'package:chatifyapp/pages/chat_page.dart';

import '../services/navigation_service.dart';

class CheckWhiteListPage extends StatefulWidget {
  const CheckWhiteListPage(
      {Key? key, required this.applist, required this.role})
      : super(key: key);
  final List<String> applist;
  final String role;
  @override
  State<CheckWhiteListPage> createState() => _CheckWhiteListPageState();
}

class _CheckWhiteListPageState extends State<CheckWhiteListPage> {
  late double _deviceWidth;
  late double _deviceHeight;
  bool is_sent = false;
  bool checkState = false;
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
    List<String> tmp = ['要做核酸很烦'];
    if (numseq.length > 0) {
      List<String> Applist = new List.generate(
          numseq.length, (index) => widget.applist[numseq[index]]);
      return Applist;
    } else
      return tmp;
  }

  String generateMessage(List<String> appList) {
    String str = appList[0];
    for (var i = 1; i < appList.length; i++) {
      str = str + ',' + appList[i];
    }
    return str;
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("取消"),
      onPressed: () {
        is_sent = false;
        _navigation.goBack();
      },
    );
    Widget continueButton = FlatButton(
        child: Text("确定"),
        onPressed: () {
          is_sent = true;
          _navigation.goBack();
        });

    AlertDialog alert = AlertDialog(
      title: Text("确认"),
      content: Text("请问确定要发送白名单吗?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            children: <Widget>[
              TopBar(
                "审核白名单",
                //widget.chat.title(),
                fontSize: 16,
                primaryAction: IconButton(
                  onPressed: () {
                    //print('back');
                    _navigation.goBack();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Color.fromRGBO(0, 82, 218, 1),
                  ),
                ),
              ),
              RaisedButton(
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder: (context1, setState) {
                        return Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20.0),
                              topRight: const Radius.circular(20.0),
                            ),
                          ),
                          height: MediaQuery.of(context).size.height / 2.0,
                          child: Column(children: [
                            _getModalSheetHeaderWithConfirm(
                              '白名单选择',
                              onCancel: () {
                                Navigator.of(context).pop();
                              },
                              onConfirm: () {
                                print('selected on confirm${selected}');
                                Navigator.of(context).pop(selected.toList());
                                //final x = selected.toList();
                                print('selected to list:${selected.toList()}');
                                List<String> tmp =
                                    generateAppList(selected.toList());
                                str = generateMessage(tmp);
                                print('List of String: $tmp');
                                print('Message type applist: $str');
                                Navigator.pop(context, str);

                                showAlertDialog(context);
                              },
                            ),
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
                                    title: Text(widget.applist[index]),
                                    onTap: () {
                                      setState(() {
                                        if (selected.contains(index)) {
                                          selected.remove(index);
                                        } else {
                                          selected.add(index);
                                        }
                                        print('currently selected$selected');
                                      });
                                    },
                                  );
                                },
                                itemCount: widget.applist.length,
                              ),
                            ),
                          ]),
                        );
                      });
                    },
                  );
                },
                child: Text("白名单选择"),
              ),
            ],
          ),
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
          icon: Icon(Icons.close),
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
