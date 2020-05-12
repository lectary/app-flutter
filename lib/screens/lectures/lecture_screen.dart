import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';

class LecturePage extends StatelessWidget {
  LecturePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appTitle),
      ),
      body: Center(
          child: Text('Lecture Page - work in progress...'),
      ),
    );
  }
}