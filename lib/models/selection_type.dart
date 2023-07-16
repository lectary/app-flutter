/// A helper class representing a selection of vocables.
/// Contains the [SelectionType] and the corresponding constructors to which additional
/// arguments may have to be passed:
/// [Selection.all] if all vocables are selected
/// [Selection.package] if a package is selected, which also needs the [packTitle]
/// [Selection.lecture] if a lecture is selected, which also needs the [lectureId] and [lesson]
/// [Selection.search] if a search is performed, which needs [filter]
/// Each constructor initializes [type] with its corresponding [SelectionType].
class Selection {
  SelectionType type;

  // for package
  String? packTitle;

  // for lecture
  int? lectureId;
  String? lesson;

  // for search
  String? filter;
  Selection? originSelection;

  Selection.all() : type = SelectionType.all;

  Selection.package(this.packTitle) : type = SelectionType.package;

  Selection.lecture(this.lectureId, this.lesson) : type = SelectionType.lecture;

  Selection.search(this.filter, this.originSelection) : type = SelectionType.search;

  @override
  String toString() {
    return 'Selection{type: $type, packTitle: $packTitle, lectureId: $lectureId, lesson: $lesson, filter: $filter}';
  }
}

enum SelectionType { all, package, lecture, search }
