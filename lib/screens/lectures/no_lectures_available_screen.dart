import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';

class LectureEmptyPage extends StatelessWidget {
  LectureEmptyPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appTitle,)
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).emptyLectures,
            ),
          ],
        ),
      ),
    );
  }
}