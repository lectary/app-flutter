import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';

class MainDrawer extends StatelessWidget {

  final List<String> items = List<String>.generate(20, (i) => "Lektion $i");

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
                    icon: Icon(Icons.arrow_back),
                  ),
                  Text("Drawer-Header")
                ],
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Container(
              child: _generateListView(),
            ),
          ),
          Divider(height: 1, thickness: 1),
          _buildButton(Icons.cloud_download, AppLocalizations.of(context).buttonLectureManagement),
          Divider(height: 1, thickness: 1),
          _buildButton(Icons.settings, AppLocalizations.of(context).buttonSettings),
          Divider(height: 1, thickness: 1),
        ],
      ),
    );
  }

  // builds a listView with ListTiles based on the generated item-list
  ListView _generateListView() {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text("${items[index]}"),
        );
      },
    );
  }

  // creates a max size button with desired icon and text
  Expanded _buildButton(icon, text) {
    return Expanded(
        flex: 1,
        child: RaisedButton(
          onPressed: () {},
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
