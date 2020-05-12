import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';

class NoLecturesAvailableScreen extends StatelessWidget {
  NoLecturesAvailableScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appTitle,)
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                AppLocalizations.of(context).emptyLectures,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 10,), // separator
              RaisedButton(
                onPressed: (){},
                padding: EdgeInsets.all(15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).downloadAndManageLectures,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Icon(
                          Icons.cloud_download,
                          size: 55,
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 10,), // separator
              Text(
                AppLocalizations.of(context).minMaxLectureSizes,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}