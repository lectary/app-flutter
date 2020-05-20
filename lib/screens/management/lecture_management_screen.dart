import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/drawer/main_drawer.dart';

class LectureManagementScreen extends StatefulWidget {
  @override
  _LectureManagementScreenState createState() => _LectureManagementScreenState();
}

class _LectureManagementScreenState extends State<LectureManagementScreen> {

  List<String> items = List<String>.generate(20, (i) => "Lektion $i");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).screenManagementTitle),
      ),
      drawer: MainDrawer(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _generateListView(),
          ),
        ],
      ),
    );
  }

  // builds a listView with ListTiles based on the generated item-list
  ListView _generateListView() {
    return ListView.separated(
      padding: EdgeInsets.all(0),
      separatorBuilder: (context, index) => Divider(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Visibility(
            visible: _checkDownloadStatus(),
            child: Icon(Icons.check_circle),
          ),
          title: Text("${items[index]}"),
          trailing: Icon(Icons.more_horiz),
        );
      },
    );
  }

  bool _checkDownloadStatus() {
    // TODO connect with real data
    final random = Random();
    return random.nextBool();
  }

}
