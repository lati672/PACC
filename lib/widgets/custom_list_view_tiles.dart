// Packages
import 'package:chatifyapp/models/chat_message_model.dart';
import 'package:chatifyapp/models/chat_user_model.dart';
import 'package:chatifyapp/widgets/image_message_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; //Custom Animations

// Widgets
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

class CustomChatListViewTile extends StatelessWidget {
  const CustomChatListViewTile({
    Key? key,
    required this.width,
    required this.deviceHeight,
    required this.isOwnMessage,
    required this.message,
    required this.sender,
  }) : super(key: key);

  final double width;
  final double deviceHeight;
  final bool isOwnMessage;
  final ChatMessage message;
  final ChatUserModel sender;

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
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
                      imagePath: "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fup.enterdesk.com%2Fedpic%2Ffb%2Fa2%2F69%2Ffba2696b9fa4120d758eba82c04f1aad.jpg&refer=http%3A%2F%2Fup.enterdesk.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1650375129&t=401f58e617fbfe66648265e8b398de2a",
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
                      imagePath: "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fup.enterdesk.com%2Fedpic%2Ffb%2Fa2%2F69%2Ffba2696b9fa4120d758eba82c04f1aad.jpg&refer=http%3A%2F%2Fup.enterdesk.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1650375129&t=401f58e617fbfe66648265e8b398de2a",
                      size: width * .1,
                    )
                  : Container(),
              SizedBox(
                width: width * .05,
              ),
              ImageMessageBubble(isOwnMessage: isOwnMessage, message: message, width: width*.75)
            ],
          ),
        );
      default:
        return Container();
    }
  }
}
