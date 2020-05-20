import 'package:flutter/material.dart';
import 'package:lectary/utils/colors.dart';


class LectureScreen extends StatefulWidget {
  @override
  _LectureScreenState createState() => _LectureScreenState();
}

class _LectureScreenState extends State<LectureScreen> {
  bool slowModeOn = false;
  bool autoModeOn = false;
  bool repeatModeOn = false;
  bool vocableVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          child: (vocableVisible ? Text('Vokabel') : Icon(Icons.visibility, size: 80, color: ColorsLectary.green,)),
        ),
        // TODO Videoplayer
        Container(
          height: 300,
          color: Colors.grey
        ),
        /// First button row for setting different video modes
        Container(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildButton(
                  (slowModeOn ? ColorsLectary.yellow : ColorsLectary.darkblue),
                  Icons.casino,
                  35,
                  func: () => setState(() {
                    slowModeOn = slowModeOn ? false : true;
                  })
              ),
              _buildButton(
                  (autoModeOn ? ColorsLectary.orange : ColorsLectary.darkblue),
                  Icons.casino,
                  35,
                  func: () => setState(() {
                    autoModeOn = autoModeOn ? false : true;
                  })
              ),
              _buildButton(
                  (repeatModeOn ? ColorsLectary.red : ColorsLectary.darkblue),
                  Icons.casino,
                  35,
                  func: () => setState(() {
                    repeatModeOn = repeatModeOn ? false : true;
                  })),
            ],
          ),
        ),
        /// second button row for setting different vocable selection (modes)
        Container(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildButton(
                  ColorsLectary.green,
                  vocableVisible ? Icons.visibility : Icons.visibility_off,
                  70,
                  func: () => setState(() {
                    vocableVisible = vocableVisible ? false : true;
                  })
              ),
              _buildButton(
                  ColorsLectary.violett, Icons.casino, 70,
                  func: () => setState(() {
                    // TODO select vocable randomly
                  })
              ),
              _buildButton(
                  ColorsLectary.lightblue, Icons.search, 70,
                  func: () => setState(() {
                    // TODO search vocable
                  })),
            ],
          ),
        ),
      ],
    );
  }

  Expanded _buildButton(color, icon, int size, {Function func=emptyFunction}) {
    return Expanded(
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(0))
        ),
        color: color,
        child: Icon(icon, size: size.toDouble(), color: ColorsLectary.white),
        onPressed: func,
      ),
    );
  }
  static emptyFunction() {}
}