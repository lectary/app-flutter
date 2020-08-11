import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/screens/drawer/widgets/lecture_package_item.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
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
      stream: Provider.of<CarouselViewModel>(context, listen: false).loadLocalLecturesAsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            return ListView.separated(
                  separatorBuilder: (context, index) => Divider(height: 1, thickness: 1),
                  padding: EdgeInsets.all(0),
                  itemCount: snapshot.data.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0)
                      return ListTile(
                        title: Text("Alle Vokabel"),
                        onTap: () {
                          Provider.of<CarouselViewModel>(context, listen: false).loadAllVocables();
                          Navigator.pop(context); // close drawer first to avoid unwanted behaviour!
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                        },
                      );
                    return LecturePackageItem(
                        context, snapshot.data[index - 1]);
                  });
            } else {
            return Center(
              child: Text("Keine offline Lektionen vorhanden!"),
            );
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      }
    );
  }
}