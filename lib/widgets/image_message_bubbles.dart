import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/chat_message_model.dart';

class ImageMessageBubble extends StatelessWidget {
  const ImageMessageBubble(
      {Key? key,
      required this.isOwnMessage,
      required this.message,
      required this.width //设置图片的最大高度和宽度
      })
      : super(key: key);

  final bool isOwnMessage;
  final ChatMessage message;
  final double width;

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
    List<Color> _colorScheme = isOwnMessage
        ? [
            const Color.fromRGBO(0, 136, 249, 1),
            const Color.fromRGBO(0, 82, 218, 1),
          ]
        : [
            const Color.fromRGBO(51, 49, 68, 1),
            const Color.fromRGBO(51, 49, 68, 1),
          ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      constraints: BoxConstraints(maxWidth: width),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: _colorScheme,
          stops: const [0.30, 0.70],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          Image(image: NetworkImage("https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fmmbiz.qpic.cn%2Fmmbiz_jpg%2FADamEbibMMaN42xAkj7WklHbUc64TKL2Jgt7Dz4el7ria1fIdqxBOhmuLcP5tbpzibTJicwvAqmTDjVShAWGSSNsIQ%2F640%3Fwx_fmt%3Djpeg&refer=http%3A%2F%2Fmmbiz.qpic.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1650289065&t=0f7832b760284deed3d8facc1edd75ca")),
          Text(
            //timeago.format(message.sentTime),
            convertToAgo(message.sentTime),
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
