import 'package:flutter/material.dart';
import 'package:lectary/screens/lectures/widgets/learning_control_area.dart';
import 'package:lectary/utils/colors.dart';


/// Class responsible for displaying the actual textual [Vocable] in the [Carousel] header.
/// The visibility of the vocable can be controlled by tapping the vocable itself
/// or via the [LearningControlArea].
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
                : Text(widget.text, style: TextStyle(fontSize: 28, color: ColorsLectary.white),)
        ),
      ),
    );
  }
}