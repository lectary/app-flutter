import 'package:flutter/material.dart';
import 'package:lectary/utils/colors.dart';

class Dialogs {
  static Future<void> showLoadingDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(children: <Widget>[
                Center(
                  child: Column(children: [
                    Text("Deleting lectures..."),
                    SizedBox(
                      height: 10,
                    ),
                    CircularProgressIndicator(),
                  ]),
                )
              ]));
        });
  }

  static Future<void> showAlertDialog(
      {@required BuildContext context,
      @required String title,
      @required String submitText,
      @required Function submitFunc}) async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Abbrechen',
                style: TextStyle(color: ColorsLectary.lightBlue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                submitText,
                style: TextStyle(color: ColorsLectary.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                submitFunc();
              },
            ),
          ],
        );
      },
    );
  }
}
