// Packages
import 'package:flutter/material.dart';

class TopBar extends StatefulWidget {
  const TopBar(
    this._barTitle, {
    Key? key,
    this.primaryAction,
    this.secondaryAction,
    this.fontSize = 24,
  }) : super(key: key);

  final String _barTitle;
  final Widget? primaryAction;
  final Widget? secondaryAction;
  final double? fontSize;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  late double _deviceWidth;

  late double _deviceHeight;

  late double topPadding;

  @override
  Widget build(BuildContext context) {
    // Responsive layout
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    topPadding = MediaQuery.of(context).padding.top;
    return _buildUI();
  }

  Widget _buildUI() {
    return Container(
        padding: EdgeInsets.only(top: topPadding),
        color: const Color.fromRGBO(96, 169, 233, 1),
        child: SizedBox(
          width: _deviceWidth,
          height: _deviceHeight * .07,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.secondaryAction != null)
                Expanded(
                    flex: 1,
                    child: Container(
                        alignment: Alignment.centerLeft,
                        child: widget.secondaryAction!))
              else
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: _deviceWidth * 1 / 12,
                  ),
                ),
              Container(
                //color: Colors.redAccent,
                child: _titleBar(),
              ),
              if (widget.primaryAction != null)
                Expanded(
                    flex: 1,
                    child: Container(
                        alignment: Alignment.centerRight,
                        child: widget.primaryAction!))
              else
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: _deviceWidth * 1 / 12,
                  ),
                ),
              // if (widget.primaryAction != null)
              //   widget.primaryAction!
              // else
              //   Container(
              //     width: _deviceWidth / 12,
              //   ),
            ],
          ),
        ));
  }

  Widget _titleBar() {
    return Text(
      widget._barTitle,
      style: TextStyle(
        color: Colors.white,
        fontSize: widget.fontSize,
        fontWeight: FontWeight.w700,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
