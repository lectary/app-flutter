import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lectary/data/entities/lecture.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/drawer/main_drawer.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/viewmodels/lecture_viewmodel.dart';
import 'package:provider/provider.dart';


class LectureManagementScreen extends StatefulWidget {
  @override
  _LectureManagementScreenState createState() => _LectureManagementScreenState();
}

class _LectureManagementScreenState extends State<LectureManagementScreen> {

  @override
  void initState() {
    super.initState();
    /// Callback for loading lectures on first frame once the layout is finished completely
    WidgetsBinding.instance.addPostFrameCallback((_) =>
      Provider.of<LectureViewModel>(context, listen: false).loadLectures()
    );
  }

  @override
  Widget build(BuildContext context) {
    final lectureViewModel = Provider.of<LectureViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).screenManagementTitle),
      ),
      drawer: MainDrawer(),
      body: (() {
        switch (lectureViewModel.status) {
          case Status.loading:
            return Center(child: CircularProgressIndicator(backgroundColor: ColorsLectary.darkBlue,));

          case Status.completed:
            return lectureViewModel.availableLectures.isEmpty
                ? null
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: _generateListView(lectureViewModel.availableLectures),
                      ),
                      Divider(height: 1, thickness: 1),
                      Container(
                        height: 60,
                        child: _buildSearchBar(),
                      ),
                    ],
                  );

          case Status.error:
            return Center(child: Text(lectureViewModel.message));
        }
      } ()),
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
              leading: _getIconForLectureStatus(lectures[index].lectureStatus),
              title: Text("${lectures[index].lesson}"),
              trailing: IconButton(
                  onPressed: () => _showLectureMenu(index),
                  icon: Icon(Icons.more_horiz))),
        );
      },
    );
  }

  Widget _getIconForLectureStatus(LectureStatus lectureStatus) {
    switch (lectureStatus) {
      case LectureStatus.downloading:
        return CircularProgressIndicator(backgroundColor: ColorsLectary.lightBlue,);
      case LectureStatus.persisted:
        return Icon(Icons.check_circle);
      case LectureStatus.removed:
        return Icon(Icons.error, color: ColorsLectary.red,);
      case LectureStatus.updateAvailable:
        return Icon(Icons.loop);
      default:
        return Icon(null);
    }
  }

  _showLectureMenu(int index) {
    final lecturesProvider = Provider.of<LectureViewModel>(context, listen: false);
    return showModalBottomSheet(
        context: context,
        builder: (_) {
          return ChangeNotifierProvider(
            create: (context) => lecturesProvider,
            child: Wrap(
              children: <Widget>[
                _buildLectureInfoWidget(lecturesProvider.availableLectures[index]),
                Divider(height: 1, thickness: 1),
                _buildButton(Icons.cloud_download, "Herunterladen",
                func: () => lecturesProvider.loadSingleLectureFromServer(index)
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
