import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/models/lecture_package.dart';

class LecturePackageItem extends StatelessWidget {
  const LecturePackageItem(this.context, this.entry);

  final BuildContext context;
  final LecturePackage entry;

  // root level
  Widget _buildTiles(LecturePackage pack) {
    if (pack.children.isEmpty) return ListTile(title: Text(pack.title));
    List<Widget> childs = List<Widget>();
    childs.add(Container(
        padding: EdgeInsets.only(left: 15, top: 5, bottom: 5),
        alignment: Alignment.centerLeft,
        child: Text(pack.title, style: Theme.of(context).textTheme.caption))
    );
    pack.children.map(_buildChildren).forEach((element) {childs.addAll(element);});

    Column column = Column(
        children: childs
    );
    return column;
  }

  // children of an package
  List<Widget> _buildChildren(Lecture lecture) {
    return <Widget>[
      Divider(height: 1,thickness: 1),
      ListTile(
        title: Text(lecture.lesson),
        onTap: () => {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Tapped!"),
          ))
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}