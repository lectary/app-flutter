import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/screens/lectures/main_screen.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/selection_type.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';


/// Helper class for realizing categorization of [Lecture] by its package name.
/// Creates for every [LecturePackageItem] one special header [ListTile] and maps
/// its children list of [Lecture] to a standard [ListTile].
class LecturePackageItem extends StatelessWidget {
  const LecturePackageItem(this.context, this.entry);

  final BuildContext context;
  final LecturePackage entry;

  @override
  Widget build(BuildContext context) {
    final settingUppercase = context.select((SettingViewModel model) => model.settingUppercase);
    return _buildTiles(entry, settingUppercase);
  }

  // builds the header tile for the package and standard tiles for the children
  Widget _buildTiles(LecturePackage pack, bool uppercase) {
    Selection selection = Provider.of<CarouselViewModel>(context, listen: false).currentSelection;
    // return when there are no children, although this should never happen
    if (pack.children.isEmpty) return ListTile(title: Text(pack.title));
    List<Widget> childs = List<Widget>();
    childs.add(Container(
        height: 70,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: selection != null && selection.packTitle == pack.title
              ? ColorsLectary.lightBlue
              : ColorsLectary.white,
        ),
        child: ListTile(
          title: Text(uppercase ? pack.title.toUpperCase() : pack.title,
              style: Theme.of(context).textTheme.headline6.copyWith(
                  color: selection != null && selection.packTitle == pack.title
                      ? ColorsLectary.white
                      : ColorsLectary.lightBlue)),
          onTap: () {
            Provider.of<CarouselViewModel>(context, listen: false).loadVocablesOfPackage(pack.title);
            Navigator.pop(context); // close drawer first to avoid unwanted behaviour!
            Navigator.popUntil(context, ModalRoute.withName(LectureMainScreen.routeName));
          },
        ))
    );
    pack.children.map((e) => _buildChildren(e, uppercase)).forEach((element) {childs.addAll(element);});

    Column column = Column(
        children: childs
    );
    return column;
  }

  // builds the children of an package
  List<Widget> _buildChildren(Lecture lecture, bool uppercase) {
    Selection selection = Provider.of<CarouselViewModel>(context, listen: false).currentSelection;
    return <Widget>[
      Divider(height: 1,thickness: 1),
      Container(
        color: selection != null && selection.lesson == lecture.lesson
            ? ColorsLectary.lightBlue
            : ColorsLectary.white,
        child: ListTile(
          title: Text(uppercase ? lecture.lesson.toUpperCase() : lecture.lesson,
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                  color:
                      selection != null && selection.lesson == lecture.lesson
                          ? ColorsLectary.white
                          : Colors.black)),
          onTap: () {
            Provider.of<CarouselViewModel>(context, listen: false).loadVocablesOfLecture(lecture.id, lecture.lesson);
            Navigator.pop(context); // close drawer first to avoid unwanted behaviour!
            Navigator.popUntil(context, ModalRoute.withName(LectureMainScreen.routeName));
          },
        ),
      ),
    ];
  }
}