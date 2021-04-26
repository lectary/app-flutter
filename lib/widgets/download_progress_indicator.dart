import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/viewmodels/lecture_viewmodel.dart';
import 'package:provider/provider.dart';

/// A custom [CircularProgressIndicator], that listens on the download progress of the passed [Lecture] by means
/// of the [Provider] package. It uses [LectureViewModel].
class DownloadProgressIndicator extends StatefulWidget {
  final Lecture lecture;

  DownloadProgressIndicator(this.lecture);

  @override
  _DownloadProgressIndicatorState createState() => _DownloadProgressIndicatorState();
}

class _DownloadProgressIndicatorState extends State<DownloadProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return Selector<LectureViewModel, double?>(
      selector: (context, model) => model.lectureDownloadProgress[widget.lecture.fileName],
      builder: (context, progress, child) {
        if (progress == -1) {
          final lectureModel = Provider.of<LectureViewModel>(context, listen: false);
          lectureModel.lectureDownloadProgress.remove(widget.lecture.fileName);
        }
        return CircularProgressIndicatorWithNumber(progress);
      },
    );
  }
}

/// A custom square [CircularProgressIndicator] with the progress displayed in the center.
/// The size can be adjusted with [indicatorSize].
class CircularProgressIndicatorWithNumber extends StatelessWidget {
  final double? progress;
  final double indicatorSize;

  CircularProgressIndicatorWithNumber(this.progress, {this.indicatorSize = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: indicatorSize,
      width: indicatorSize,
      child: Stack(alignment: Alignment.center, children: [
        CircularProgressIndicator(
          value: progress,
          strokeWidth: 4,
        ),
        (progress == null || progress! == -1)
            ? Container()
            : Text("${_getPercentage(progress!)}", style: TextStyle(fontSize: 11))
      ]),
    );
  }

  String _getPercentage(double progress) {
    return (progress * 100).floor().toString();
  }
}

/// A custom square [LinearProgressIndicator] with the progress displayed below and centered.
/// If no progress value is available, i.e. [progress] is [Null], then a [CircularProgressIndicator] is shown.
/// The size can be adjusted with [indicatorSize].
class LinearProgressIndicatorWithNumber extends StatelessWidget {
  final double? progress;
  final double indicatorSize;

  LinearProgressIndicatorWithNumber(this.progress, {this.indicatorSize = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: indicatorSize,
      width: indicatorSize,
      child: Stack(alignment: Alignment.center, children: [
        progress == null
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: LinearProgressIndicator(
                  value: progress,
                ),
              ),
        (progress == null || progress! == -1)
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text("${_getPercentage(progress!)}%", style: TextStyle(fontSize: 10)),
              )
      ]),
    );
  }

  String _getPercentage(double progress) {
    return (progress * 100).floor().toString();
  }
}
