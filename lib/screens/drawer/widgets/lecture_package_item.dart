import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/screens/lectures/main_screen.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
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
    return _buildTiles(entry);
  }

  // builds the header tile for the package and standard tiles for the children
  Widget _buildTiles(LecturePackage pack) {
    // return when there are no children, although this should never happen
    if (pack.children.isEmpty) return ListTile(title: Text(pack.title));
    List<Widget> childs = List<Widget>();
    childs.add(Container(
        height: 70,
        alignment: Alignment.centerLeft,
        child: ListTile(
          title: Text(pack.title, style: Theme.of(context).textTheme.headline6),
          onTap: () {
            Provider.of<CarouselViewModel>(context, listen: false).loadVocablesOfPackage(pack.title);
            Navigator.pop(context); // close drawer first to avoid unwanted behaviour!
            Navigator.popUntil(context, ModalRoute.withName(LectureMainScreen.routeName));
          },
        ))
    );
    pack.children.map(_buildChildren).forEach((element) {childs.addAll(element);});

    Column column = Column(
        children: childs
    );
    return column;
  }

  // builds the children of an package
  List<Widget> _buildChildren(Lecture lecture) {
    return <Widget>[
      Divider(height: 1,thickness: 1),
      ListTile(
        title: Text(lecture.lesson),
        onTap: () {
          Provider.of<CarouselViewModel>(context, listen: false).loadVocablesOfLecture(lecture.id, lecture.lesson);
          Navigator.pop(context); // close drawer first to avoid unwanted behaviour!
          Navigator.popUntil(context, ModalRoute.withName(LectureMainScreen.routeName));
        },
      ),
    ];
  }
}