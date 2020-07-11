import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/providers/lectures_provider.dart';
import 'package:lectary/screens/drawer/main_drawer.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/models/lecture.dart';
import 'package:provider/provider.dart';


class LectureManagementScreen extends StatefulWidget {
  @override
  _LectureManagementScreenState createState() => _LectureManagementScreenState();
}

class _LectureManagementScreenState extends State<LectureManagementScreen> {

  @override
  void initState() {
    super.initState();
    Provider.of<LecturesProvider>(context, listen: false).loadLecturesFromServer();
  }

  @override
  Widget build(BuildContext context) {
    LecturesProvider lecturesProvider = Provider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).screenManagementTitle),
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
          future: lecturesProvider.futureLecturesFromServer,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: _generateListView(snapshot.data),
                  ),
                  Divider(height: 1, thickness: 1),
                  Container(
                    height: 60,
                    child: _buildSearchBar(),
                  ),
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator(backgroundColor: ColorsLectary.darkBlue,));
            }
          }),
    );
  }

  // builds a listView with ListTiles based on the generated item-list
  ListView _generateListView(List<Lecture> lectures) {
    return ListView.separated(
      padding: EdgeInsets.all(0),
      separatorBuilder: (context, index) => Divider(),
      itemCount: lectures.length,
      itemBuilder: (context, index) {
        return ListTileTheme(
          iconColor: ColorsLectary.lightBlue,
            child: ListTile(
            leading: Visibility(
            visible: _checkDownloadStatus(),
            child: Icon(Icons.check_circle),
          ),
            title: Text("${lectures[index].lesson}"),
            trailing: IconButton(onPressed: () => _showLectureMenu(lectures[index]), icon: Icon(Icons.more_horiz))
        ),
        );
      },
    );
  }

  _showLectureMenu(Lecture lecture) {
    LecturesProvider lecturesProvider = Provider.of(context, listen: false);
    return showModalBottomSheet(
        context: context,
        builder: (_) {
          return ChangeNotifierProvider(
            create: (context) => lecturesProvider,
            child: Wrap(
              children: <Widget>[
                _buildLectureInfoWidget(lecture),
                Divider(height: 1, thickness: 1),
                _buildButton(Icons.cloud_download, "Herunterladen",
                func: () => Provider.of<LecturesProvider>(context, listen: false).loadLectureFromServer()
                ),
                Divider(height: 1, thickness: 1),
                _buildButton(Icons.close, "Abbrechen",
                func: () => Navigator.pop(context)),
                Divider(height: 1, thickness: 1),
              ],
            ),
          );
        },
    );
  }

  Container _buildLectureInfoWidget(Lecture lecture) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // TODO replace mock text
          Text("Lektion: " + lecture.lesson),
          SizedBox(height: 10),
          Text("Paket: " + lecture.pack),
          SizedBox(height: 10),
          Text("Dateigröße: " + lecture.fileSize.toString() + " MB"),
          SizedBox(height: 10),
          Text("Vokabel: " + lecture.vocableCount.toString()),
        ],
      )
    );
  }


  bool _checkDownloadStatus() {
    // TODO connect with real data
    final random = Random();
    return random.nextBool();
  }

  Row _buildSearchBar() {
    // TODO check for native searchbars
    return Row(
      children: <Widget>[
        SizedBox(width: 15),
        Icon(Icons.search),
        SizedBox(width: 10),
        Expanded( // needed because textField has no intrinsic width, that the row wants to know!
          child: TextField(
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context).screenManagementSearchHint,
                border: InputBorder.none
            ),
          ),
        ),
      ],
    );
  }

  Container _buildButton(icon, text, {Function func=emptyFunction}) {
    return Container(
      height: 50, // TODO maybe better use relative values via expanded?
      child: RaisedButton(
        onPressed: () {
          func();
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
  static emptyFunction() {}

}
