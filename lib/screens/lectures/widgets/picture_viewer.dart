import 'package:flutter/material.dart';

class PictureViewer extends StatefulWidget {
  final String picturePath;
  final int pictureIndex;

  final bool slowMode;
  final bool autoMode;
  final bool loopMode;

  final double slowModeSpeed = 0.3;

  PictureViewer({this.picturePath, this.pictureIndex, this.slowMode, this.autoMode, this.loopMode, Key key}) : super(key: key);

  @override
  _PictureViewerState createState() => _PictureViewerState();
}

class _PictureViewerState extends State<PictureViewer> {
  bool showPicture = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showPicture = showPicture ? false : true;
        });
      },
      child: Center(
        child: AspectRatio(
            aspectRatio: 4/3,
            child: showPicture
                ? Image.asset(widget.picturePath)
                : Icon(Icons.image, size: 120,)
        ),
      ),
    );
  }
}
