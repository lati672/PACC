import 'dart:async';

// Packages
import 'package:chatifyapp/models/todo_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/services.dart';

// Services
import '../services/database_service.dart';

// Providers
import '../providers/authentication_provider.dart';

// Models
import '../models/chat_message_model.dart';
import '../models/chat_user_model.dart';
import '../models/chats_model.dart';

class WhitelistPageProvider extends ChangeNotifier {
  WhitelistPageProvider(this._auth) {
    _database = GetIt.I.get<DatabaseService>();
    getAppList();
  }
  final AuthenticationProvider _auth;
  late DatabaseService _database;
  List<String>? appList;
  List<String>? pacakageNameList;

// * Once not longer needed, it will be disposed
  @override
  void dispose() {
    super.dispose();
  }

  void getAppList() async {
    const platform = const MethodChannel('samples.flutter.dev');
    // 通过渠道，调用原生代码代码的方法
    //Future future = channel.invokeMethod("your_method_name", {"msg": msg} );
    String str = await platform.invokeMethod('getAppList');
    // 打印执行的结果
    List<String> _appList = [];
    List<String> _packageNameList = [];
    var strList = str.split('/n');
    for (int i = 0; i < strList.length - 1; i++) {
      _appList.add(strList[i].split('+')[0]);
      _packageNameList.add(strList[i].split('+')[1]);
    }
    appList = _appList;
    pacakageNameList = _packageNameList;
    notifyListeners();
  }
}
