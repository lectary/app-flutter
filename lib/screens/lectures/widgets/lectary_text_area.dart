import 'package:flutter/material.dart';
import 'package:lectary/utils/colors.dart';

class TextArea extends StatefulWidget {
  final bool hideVocableModeOn;
  final String text;

  TextArea({this.hideVocableModeOn, this.text, Key key}) : super(key: key);

  @override
  _TextAreaState createState() => _TextAreaState();
}

class _TextAreaState extends State<TextArea> {
  bool showVocable = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => {
          if (widget.hideVocableModeOn) {
            setState(() {
              showVocable = showVocable ? false : true;
            })
          }
        },
        child: Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.all(10),
            child: widget.hideVocableModeOn && !showVocable
                ? Icon(Icons.visibility, size: 80, color: ColorsLectary.green,)
                : Text("Video #${widget.text}", style: TextStyle(fontSize: 28, color: ColorsLectary.white),)
        ),
      ),
    );
  }
}