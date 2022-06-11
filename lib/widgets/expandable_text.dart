import 'package:flutter/material.dart';
import 'package:PACCPolicyapp/utils/colors.dart';
import 'package:PACCPolicyapp/widgets/small_text.dart';
import 'package:get_it/get_it.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final double height;
  const ExpandableText({Key? key, required this.text, required this.height})
      : super(key: key);

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  late String firstHalf;
  late String secondHalf;
  bool hiddenText = true;
  late double textHeight;
  @override
  void initState() {
    // TODO: implement initState
    textHeight = widget.height / 4;
    super.initState();
    if (widget.text.length > textHeight) {
      firstHalf = widget.text.substring(0, textHeight.toInt());
      secondHalf =
          widget.text.substring(textHeight.toInt() + 1, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: secondHalf.isEmpty
          ? SmallText(text: firstHalf)
          : Column(
              children: [
                SmallText(
                    height: 1.4,
                    color: AppColors.paraColor,
                    size: widget.height / 45,
                    text: hiddenText
                        ? (firstHalf + '...')
                        : (firstHalf + secondHalf)),
                InkWell(
                  onTap: () {
                    setState(() {
                      hiddenText = !hiddenText;
                    });
                  },
                  child: Row(
                    children: [
                      SmallText(
                          text: hiddenText ? 'Show more' : ' Scroll back',
                          color: AppColors.mainColor),
                      Icon(
                          hiddenText
                              ? Icons.arrow_drop_down
                              : Icons.arrow_drop_up,
                          color: AppColors.mainColor),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
