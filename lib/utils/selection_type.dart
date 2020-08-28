/// A helper class representing a selection of vocables.
/// Contains the [SelectionType] and the corresponding constructors to which additional
/// arguments may have to be passed:
/// [Selection.all] if all vocables are selected
/// [Selection.package] if a package is selected, which also needs the [packTitle]
/// [Selection.lecture] if a lecture is selected, which als needs the [lectureId] and [lesson]
/// Each constructor initializes [type] with its corresponding [SelectionType].
class Selection {
  SelectionType type;
  String packTitle;
  int lectureId;
  String lesson;

  Selection.all() : type = SelectionType.all;
  Selection.package(this.packTitle) : type = SelectionType.package;
  Selection.lecture(this.lectureId, this.lesson) : type = SelectionType.lecture;

  @override
  String toString() {
    return 'Selection{type: $type, packTitle: $packTitle, lectureId: $lectureId, lesson: $lesson}';
  }
}

enum SelectionType { all, package, lecture }
