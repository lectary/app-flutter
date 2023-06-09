import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/management/lecture_management_screen.dart';
import 'package:lectary/utils/colors.dart';


/// Lecture screen if no lectures are available.
/// Shows a corresponding message and a button linked with the
/// [LectureManagementScreen]
class LectureNotAvailableScreen extends StatelessWidget {
  LectureNotAvailableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
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
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, LectureManagementScreen.routeName),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsLectary.lightBlue,
                padding: EdgeInsets.all(15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
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
    );
  }
}