import 'package:flutter/material.dart';
import 'package:lectary/utils/colors.dart';

class TextViewer extends StatefulWidget {
  final String content;
  final int textIndex;

  final bool slowMode;
  final bool autoMode;
  final bool loopMode;

  final double slowModeSpeed = 0.3;

  TextViewer({this.content, this.textIndex, this.slowMode, this.autoMode, this.loopMode, Key key}) : super(key: key);

  @override
  _TextViewerState createState() => _TextViewerState();
}

class _TextViewerState extends State<TextViewer> {
  bool showText = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showText = showText ? false : true;
        });
      },
      child: Center(
        child: AspectRatio(
            aspectRatio: 4/3,
            child: showText
                ? Center(child: Text(widget.content, style: TextStyle(fontSize: 28, color: ColorsLectary.white)))
                : Icon(Icons.subject, size: 120,)
        ),
      ),
    );
  }
}
