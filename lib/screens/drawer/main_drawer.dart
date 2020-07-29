import 'package:flutter/material.dart';
import 'package:lectary/data/entities/lecture.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/viewmodels/lecture_viewmodel.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 80, // ToDo replace with relative placement?
            child: DrawerHeader(
              margin: EdgeInsets.all(0.0),
              padding: EdgeInsets.all(0.0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios),
                  ),
                  Text("Drawer-Header")
                ],
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Container(
              child: _generateListView(context),
            ),
          ),
          Divider(height: 1, thickness: 1),
          _buildButton(Icons.cloud_download, AppLocalizations.of(context).buttonLectureManagement,
              context, '/lectureManagement'),
          Divider(height: 1, thickness: 1),
          _buildButton(Icons.settings, AppLocalizations.of(context).buttonSettings,
              context, '/settings'),
          Divider(height: 1, thickness: 1),
        ],
      ),
    );
  }

  // creates a max size button with desired icon and text
  Expanded _buildButton(icon, text, context, route) {
    return Expanded(
        flex: 1,
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context); // close drawer first to avoid unwanted behaviour!
            Navigator.pushNamedAndRemoveUntil(context, route, ModalRoute.withName('/'));
          },
          child: Container(
            child: Row(
              children: <Widget>[
                Icon(icon, color: ColorsLectary.lightBlue,),
                SizedBox(width: 10), // spacer
                Text(text),
              ],
            ),
          ),
        )
    );
  }

  // builds a listView with ListTiles based on the generated item-list
  Widget _generateListView(BuildContext context) {
    return StreamBuilder<List<LecturePackage>>(
      stream: Provider.of<LectureViewModel>(context, listen: false).loadLocalLecturesAsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            return ListView.separated(
                separatorBuilder: (context, index) =>
                    Divider(height: 1, thickness: 1),
                padding: EdgeInsets.all(0),
                itemCount: snapshot.data.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) return ListTile(title: Text("Alle Vokabel"));
                  return LecturePackageItem(snapshot.data[index-1], context);
                }
            );
          } else {
            return Center(
              child: Text("Keine offline Lektionen vorhanden!"),
            );
          }
        } else {
          return CircularProgressIndicator();
        }
      }
    );
  }
}

class LecturePackageItem extends StatelessWidget {
  const LecturePackageItem(this.entry, this.context);

  final LecturePackage entry;
  final BuildContext context;

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