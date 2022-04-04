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

class ConfirmMessageBubble extends StatelessWidget {
  ConfirmMessageBubble(
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
  late var senderrole;
  late String receiverid;
  late ChatUserModel user;
  late ChatPageProvider _pageProvider;

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

  void _confirmrequest(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("您有新的好友请求"),
          content: const Text("确定要添加好友吗"),
          actions: <Widget>[
            FlatButton(
              child: const Text("取消"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text("确认"),
              onPressed: () {
                print('replying to the request');
                _pageProvider.sendFriendRequestReply();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<AuthenticationProvider>(context).user;
    _pageProvider = context.watch<ChatPageProvider>();
    int confirmmessage_count = _pageProvider.countConfirm();
    return Container(
      constraints: BoxConstraints(maxWidth: width),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            child: Text(message.content,style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),),
            padding: const EdgeInsets.all(3.0),
          ),
          const Divider(color: Colors.black26, height: 2.0),
          SizedBox(
              height: height * .3,
              child: Row(
                children: [
                  Expanded(
                    //确认按钮
                    flex: 1,
                      child: TextButton(
                    onPressed: () {
                      if (confirmmessage_count == 2) {
                        null;
                      } else {
                        _confirmrequest(context);
                      }
                      //_confirmrequest(context);
                    },
                    child: const Text("接受", style: TextStyle(color: Colors.green),),
                  )),
                  const VerticalDivider(color: Colors.black26, width: 2.0),
                  Expanded(
                    //确认按钮
                      flex: 1,
                      child: TextButton(
                        onPressed: () {
                          null;
                        },
                        child: const Text("拒绝",style: TextStyle(color: Colors.redAccent)),
                      )),
                ],
              ))
        ],
      ),
    );
  }
}
