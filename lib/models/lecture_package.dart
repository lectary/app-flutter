import 'package:lectary/data/entities/lecture.dart';

/// Helper model class containing lectures grouped by pack
class LecturePackage {
  LecturePackage(this.title, [this.children = const <Lecture>[]]);

  final String title;
  final List<Lecture> children;
}