import 'package:flutter/material.dart';
import 'package:lectary/utils/colors.dart';

class TextArea extends StatefulWidget {
  final bool hideVocableModeOn;
  final String text;

  final int itemIndex;

  TextArea({this.hideVocableModeOn, this.text, this.itemIndex, Key key}) : super(key: key);

  @override
  _TextAreaState createState() => _TextAreaState();
}

class _TextAreaState extends State<TextArea> {
  bool showVocable = false;

  @override
  Widget build(BuildContext context) {
    switch (widget.itemIndex % 5) {
      case 0:
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
                    : Text("Overflow with only ellipses and maxLines 2. Loooooong text, looooong, loooooong, looooong, looooooong Text",
                  style: TextStyle(fontSize: 28, color: ColorsLectary.white), overflow: TextOverflow.ellipsis, maxLines: 2,)
            ),
          ),
        );

      case 1:
        final String longText = "Overflow with ellipses and maxLines 3. Show text by long click. Loooooong text, looooong, loooooong, loooong, looooooooooooooooooong Text";
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
                    : GestureDetector(
                  child: Text(longText, style: TextStyle(fontSize: 28, color: ColorsLectary.white), overflow: TextOverflow.ellipsis, maxLines: 3,),
                  onLongPress: () {
                    showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text(
                            longText,
                              style: TextStyle(fontSize: 18, color: Colors.black)
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('OK', style: TextStyle(fontSize: 12, color: Colors.black)),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                    )
            ),
          ),
        );

      case 2:
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
                  : SingleChildScrollView(
                  child: Text("Scrollable overview. Loooooong text, looooong, loooooong, loooong, looooooooooooooooooong looooooooooooooooooong looooooooooooooooooong  looooooooooooooooooong looooooooooooooooooong looooooooooooooooooong Text. Ende.",
                    style: TextStyle(fontSize: 28, color: ColorsLectary.white),))
          ),
        ),
      );

      default:
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
                    : Text("Normal text", style: TextStyle(fontSize: 28, color: ColorsLectary.white),)
            ),
          ),
        );
    }
  }

}