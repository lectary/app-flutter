import 'package:flutter/material.dart';
import 'package:lectary/screens/lectures/widgets/learning_control_area.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';


/// Class responsible for displaying the actual textual [Vocable] in the [Carousel] header.
/// The visibility of the vocable can be controlled by tapping the vocable itself
/// or via the [LearningControlArea].
class TextArea extends StatefulWidget {
  final bool hideVocableModeOn;
  final int mediaIndex;
  final String text;

  TextArea({this.hideVocableModeOn, this.mediaIndex, this.text, Key key}) : super(key: key);

  @override
  _TextAreaState createState() => _TextAreaState();
}

class _TextAreaState extends State<TextArea> {
  bool _hideVocable = true;

  @override
  Widget build(BuildContext context) {
    bool uppercase = context.select((SettingViewModel model) => model.settingUppercase);
    // listen on currentItemIndex and hide vocable if swiped out
    int currentItemIndex = context.select((CarouselViewModel model) => model.currentItemIndex);
    if (currentItemIndex != widget.mediaIndex) {
      setState(() {
        _hideVocable = true;
      });
    }
    return Expanded(
      child: GestureDetector(
        onTap: () => {
          if (widget.hideVocableModeOn) {
            setState(() {
              _hideVocable = _hideVocable ? false : true;
            })
          }
        },
        child: Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.all(10),
            child: widget.hideVocableModeOn && _hideVocable
                ? Icon(Icons.visibility_off, size: 80, color: ColorsLectary.green,)
                : SingleChildScrollView(
                  child: Text(
                      uppercase ? widget.text.toUpperCase() : widget.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, color: ColorsLectary.white),
                    ),
                )),
      ),
    );
  }
}