import 'dart:math';

import 'package:flutter/cupertino.dart';
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _generateListView(),
          ),
          Divider(height: 1, thickness: 1),
          Container(
            height: 60,
            child: _buildSearchBar(),
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
          trailing: IconButton(onPressed: () => _showLectureMenu(), icon: Icon(Icons.more_horiz))
        );
      },
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

  _showLectureMenu() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: <Widget>[
              _buildLectureInfoWidget(),
              Divider(height: 1, thickness: 1),
              _buildButton(Icons.cloud_download, "Herunterladen"),
              Divider(height: 1, thickness: 1),
              _buildButton(Icons.close, "Abbrechen"),
              Divider(height: 1, thickness: 1),
            ],
          );
        },
    );
  }

  Container _buildLectureInfoWidget() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // TODO replace mock text
          Text("Lektion: AAU Lektion 4"),
          SizedBox(height: 10),
          Text("Paket: Alpen Adria Universität"),
          SizedBox(height: 10),
          Text("Dateigröße: 7MB"),
          SizedBox(height: 10),
          Text("Vokabel: 84"),
        ],
      )
    );
  }

  Container _buildButton(icon, text) {
    return Container(
      height: 50, // TODO maybe better use relative values via expanded?
      child: RaisedButton(
        onPressed: () {
          // TODO perform action
        },
        child: Container(
          child: Row(
            children: <Widget>[
              Icon(icon),
              SizedBox(width: 10), // spacer
              Text(text),
            ],
          ),
        ),
      )
    );
  }

}
