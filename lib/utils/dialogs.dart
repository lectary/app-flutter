import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/utils/colors.dart';


class Dialogs {

  /// A simple [AlertDialog] for loading actions
  static Future<void> showLoadingDialog(
      {required BuildContext context, required String text}) async {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(children: <Widget>[
                Center(
                  child: Column(children: [
                    Text(text),
                    SizedBox(
                      height: 10,
                    ),
                    CircularProgressIndicator(),
                  ]),
                )
              ]));
        });
  }

  /// A simple [AlertDialog] for confirming user action
  static Future<void> showAlertDialog(
      {required BuildContext context,
      required String title,
      required String submitText,
      required Function submitFunc}) async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            FlatButton(
                child: Text(
                  AppLocalizations.of(context).cancel,
                  style: TextStyle(color: ColorsLectary.lightBlue),
                ),
                onPressed: () => Navigator.of(context).pop()),
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

  static Future<void> showAlertDialogThreeButtons(
      {required BuildContext context,
        required String title,
        required String submitText1,
        required String submitText2,
        required Function submitFunc1,
        required Function submitFunc2}) async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FlatButton(
                  child: Text(
                    submitText1,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: ColorsLectary.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    submitFunc1();
                  },
                ),
                FlatButton(
                  child: Text(
                    submitText2,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: ColorsLectary.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    submitFunc2();
                  },
                ),
                FlatButton(
                    child: Text(
                      AppLocalizations.of(context).cancel,
                      style: TextStyle(color: ColorsLectary.lightBlue),
                    ),
                    onPressed: () => Navigator.of(context).pop()
                )
              ],
            ),
          ],
        );
      },
    );
  }


  /// A simple [AlertDialog], which automatically calls the passed [reportCallback].
  static Future<void> showErrorReportDialog(
      {required BuildContext context,
      required String errorContext,
      required String? errorMessage,
      required reportCallback}) async {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        // send the report automatically
        reportCallback(errorMessage);
        return AlertDialog(
          title: Text(AppLocalizations.of(context).oops),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(errorContext),
                Divider(),
                Text(AppLocalizations.of(context).reportErrorText),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
                child: Text(
                  AppLocalizations.of(context).close,
                  style: TextStyle(color: ColorsLectary.lightBlue),
                ),
                onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }
}
