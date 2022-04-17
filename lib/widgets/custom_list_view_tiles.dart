// Packages
import 'package:chatifyapp/models/chat_message_model.dart';
import 'package:chatifyapp/models/chat_user_model.dart';
import 'package:chatifyapp/widgets/confirm_message_bubble.dart';
import 'package:chatifyapp/widgets/image_message_bubbles.dart';
import 'package:chatifyapp/widgets/whitelist_message_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; //Custom Animations
import 'package:provider/provider.dart';

// Widgets
import '../providers/chat_page_provider.dart';
import '../widgets/rounded_image_network.dart';
import '../widgets/text_message_bubbles.dart';

// Models
// import '../models/chat_message_model.dart';
// import '../models/chat_user_model.dart';

class CustomListViewTileWithActivity extends StatelessWidget {
  const CustomListViewTileWithActivity({
    Key? key,
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isActivity,
    required this.onTap,
  }) : super(key: key);

  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isActivity;
  final Function onTap;

  //chats页对话列表的item
  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: height * .20,
      onTap: () => onTap(),
      leading: RoundedIMageNetworkWithStatusIndicator(
        key: UniqueKey(),
        imagePath: imagePath,
        size: height / 2,
        isActive: isActive,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black26,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: /*isActivity
          ? Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // * Typing animation (...)
                SpinKitThreeBounce(
                  color: Colors.white54,
                  size: height * .10,
                ),
              ],
            )
          : */
          Text(
        subtitle,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class CustomFriendsListViewTile extends StatelessWidget {
  const CustomFriendsListViewTile({
    Key? key,
    required this.height,
    required this.title,
    required this.isActive,
    required this.imagePath,
    required this.onTap,
  }) : super(key: key);

  final double height;
  final String title;
  final bool isActive;
  final String imagePath;

  final Function onTap;

  //chats页对话列表的item
  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: height * .20,
      onTap: () => onTap(),
      leading: RoundedIMageNetworkWithStatusIndicator(
        key: UniqueKey(),
        imagePath: imagePath,
        size: height / 2,
        isActive: isActive,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black26,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class CustomChatListViewTile extends StatelessWidget {
  ///* 聊天界面中的每一行消息
  const CustomChatListViewTile({
    Key? key,
    required this.width,
    required this.deviceHeight,
    required this.isOwnMessage,
    required this.message,
    required this.sender,
    required this.receiverid,
  }) : super(key: key);

  final double width;
  final double deviceHeight;
  final bool isOwnMessage;
  final ChatMessage message;
  final ChatUserModel sender;
  final String receiverid;

  @override
  Widget build(BuildContext context) {
    ///* 根据不同的消息类型调用不同的bubble生成消息行
    switch (message.type) {
      case MessageType.text:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          width: width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment:
                isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              !isOwnMessage
                  ? RoundedImageNetwork(
                      imagePath: sender.imageUrl,
                      size: width * .1,
                    )
                  : Container(),
              SizedBox(
                width: width * .05,
              ),
              TextMessageBubble(
                isOwnMessage: isOwnMessage,
                message: message,
                width: width,
                height: deviceHeight * .06,
              )
            ],
          ),
        );
      case MessageType.image:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          width: width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment:
                isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              !isOwnMessage
                  ? RoundedImageNetwork(
                      imagePath: sender.imageUrl,
                      size: width * .1,
                    )
                  : Container(),
              SizedBox(
                width: width * .05,
              ),
              ImageMessageBubble(
                  isOwnMessage: isOwnMessage,
                  message: message,
                  width: width * .75)
            ],
          ),
        );
      case MessageType.whitelist:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          width: width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment:
                isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              !isOwnMessage
                  ? RoundedImageNetwork(
                      imagePath: sender.imageUrl,
                      size: width * .1,
                    )
                  : Container(),
              SizedBox(
                width: width * .05,
              ),
              WhiteListMessageBubble(
                isOwnMessage: isOwnMessage,
                message: message,
                width: width * .75,
                height: deviceHeight * .15,
                senderid: sender.uid,
                receiverid: receiverid,
              )
            ],
          ),
        );
      case MessageType.confirm:
        ChatPageProvider pageProvider = context.watch<ChatPageProvider>();
        int cnt = pageProvider
            .countConfirmbefore(message.sentTime); //查询在此之前有多少条confirm信息
        if (cnt == 0) {
          if (isOwnMessage) {
            return Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: const Text('您已发送好友请求，请等待回复',
                    style: TextStyle(fontSize: 14, color: Colors.black26),
                    textAlign: TextAlign.center));
          } else {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              width: width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: isOwnMessage
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  !isOwnMessage
                      ? RoundedImageNetwork(
                          imagePath: sender.imageUrl,
                          size: width * .1,
                        )
                      : Container(),
                  SizedBox(
                    width: width * .05,
                  ),
                  ConfirmMessageBubble(
                    isOwnMessage: isOwnMessage,
                    message: message,
                    width: width * .75,
                    height: deviceHeight * .15,
                    senderid: sender.uid,
                    receiverid: receiverid,
                  )
                ],
              ),
            );
          }
        } else {
          return Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(message.content,
                  style: TextStyle(fontSize: 14, color: Colors.black26),
                  textAlign: TextAlign.center));
        }
        return Container(
          padding: const EdgeInsets.only(bottom: 10),
          width: width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment:
                isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              !isOwnMessage
                  ? RoundedImageNetwork(
                      imagePath: sender.imageUrl,
                      size: width * .1,
                    )
                  : Container(),
              SizedBox(
                width: width * .05,
              ),
              WhiteListMessageBubble(
                isOwnMessage: isOwnMessage,
                message: message,
                width: width * .75,
                height: deviceHeight * .15,
                senderid: sender.uid,
                receiverid: receiverid,
              )
            ],
          ),
        );
      default:
        return Container();
    }
  }
}
