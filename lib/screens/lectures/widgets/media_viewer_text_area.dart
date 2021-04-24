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

  TextArea({required this.hideVocableModeOn, required this.mediaIndex, required this.text, Key? key}) : super(key: key);

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
        behavior: HitTestBehavior.opaque,
        onTap: () => {
          if (widget.hideVocableModeOn)
            {
              setState(() {
                _hideVocable = _hideVocable ? false : true;
              })
            }
        },
        child: widget.hideVocableModeOn && _hideVocable
            ? Container(
                // visibility icon
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(bottom: 10),
                child: Icon(
                  Icons.visibility_off,
                  size: 80,
                  color: ColorsLectary.green,
                ),
              )
            : Container(
                // vocable-text
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.only(left: 15, bottom: 10),
                child: SingleChildScrollView(
                  child: Text(
                    uppercase ? widget.text.toUpperCase() : widget.text,
                    style: TextStyle(fontSize: 28, color: ColorsLectary.white),
                  ),
                ),
              ),
      ),
    );
  }
}