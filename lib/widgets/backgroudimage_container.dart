import 'package:flutter/material.dart';

class BackgroundImageContainer extends StatelessWidget {
  const BackgroundImageContainer({
    Key? key,
    required this.height,
    required this.width,
    required this.wid,
  }) : super(key: key);
  final double height;
  final double width;
  final Widget wid;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/background_tree.jpg"),
            fit: BoxFit.cover),
      ),
      child: wid,
    );
  }
}
