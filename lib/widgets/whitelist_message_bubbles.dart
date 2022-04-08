import 'package:chatifyapp/providers/authentication_provider.dart';
import 'package:chatifyapp/providers/chat_page_provider.dart';
import 'package:chatifyapp/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

// Packages
import 'package:timeago/timeago.dart' as timeago;

// Models
import '../models/chat_message_model.dart';
import '../models/chat_user_model.dart';
import '../pages/checkwhitelist_page.dart';

class WhiteListMessageBubble extends StatelessWidget {
  WhiteListMessageBubble(
      {

      ///* 构造函数
      ///@param isOwnMessage 是否是自己的消息
      ///@param message 消息
      ///@param width 气泡的长度
      ///@param height 气泡的高度
      ///@param senderid 发送者id
      ///@param receiverid 接受者id
      Key? key,
      required this.isOwnMessage,
      required this.message,
      required this.width,
      required this.height,
      required this.senderid,
      required this.receiverid})
      : super(key: key);

  final bool isOwnMessage;
  final ChatMessage message;
  final double width;
  final double height;
  late String senderid;
  late DatabaseService _database;
  late ChatPageProvider _provider;
  late var senderrole;
  late String receiverid;
  late ChatUserModel user;

  List<String> decodewhitelist(String whitelist) {
    return whitelist.split(',');
  } //解析白名单数据

  Future<void> getRole() async {
    ///* 异步加载两者的职责
    senderrole = await _database.getRoleByID(senderid);
  }

  String convertToAgo(DateTime input) {
    Duration diff = DateTime.now().difference(input);

    if (diff.inDays >= 1) {
      return '${diff.inDays} 天前';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} 小时前';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} 分钟前';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} 秒前';
    } else {
      return '刚刚';
    }
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<AuthenticationProvider>(context).user;
    _database = GetIt.instance.get<DatabaseService>();
    _provider = context.watch<ChatPageProvider>();
    List<String> appList = decodewhitelist(message.content);
    print(user.role);
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        width: width,
        //height: height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text((user.role == "Parent" && isOwnMessage) ||
                    (user.role == "Student" && (!isOwnMessage))
                ? "白名单审核"
                : "白名单申请"),
            const SizedBox(
              height: 5,
            ),
            Container(
                height: 120,
                decoration: ShapeDecoration(
                    image: const DecorationImage(
                        image: AssetImage('assets/images/whiteList2.png'),
                        fit: BoxFit.fitWidth),
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey, width: .2),
                        borderRadius: BorderRadiusDirectional.circular(5)))),
            Text(
              //timeago.format(message.sentTime),
              convertToAgo(message.sentTime),
              style: const TextStyle(
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
      onTap: () async {
        String senderrole = await _database.getRoleByID(senderid);
        String receiverrole = await _database.getRoleByID(receiverid);
        final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckWhiteListPage(
                applist: appList,
                sender_role: senderrole,
                receiver_role: receiverrole,
              ),
            ));
        //print('result:  $result');
        if (result != null) {
          _provider.sendWhiteList(result);
          //print(_pageProvider.getchatid());
        }
      },
    );
  }
}
