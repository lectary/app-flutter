import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/utils/colors.dart';

class Dialogs {
  /// A simple [AlertDialog] for loading actions
  static Future<void> showLoadingDialog({
    required BuildContext context,
    required String text,
  }) async {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(children: <Widget>[
                Center(
                  child: Column(children: [
                    Text(text),
                    const SizedBox(
                      height: 10,
                    ),
                    const CircularProgressIndicator(),
                  ]),
                )
              ]));
        });
  }

  /// A simple [AlertDialog] for confirming user actions, with an optional secondary submit button.
  static Future<void> showAlert({
    required BuildContext context,
    required String title,
    String? content,
    required String submitText,
    required Function submitFunc,
    String? submitTextSecondary,
    Function? submitFuncSecondary,
  }) async {
    final primaryButton = TextButton(
      child: Text(
        submitText,
        textAlign: TextAlign.right,
        style: const TextStyle(color: ColorsLectary.red),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        submitFunc();
      },
    );
    final cancelButton = TextButton(
      child: Text(
        AppLocalizations.of(context).cancel,
        style: const TextStyle(color: ColorsLectary.lightBlue),
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: content == null ? null : Text(content),
          actions: submitTextSecondary != null && submitFuncSecondary != null
              ? [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      primaryButton,
                      TextButton(
                        child: Text(
                          submitTextSecondary,
                          textAlign: TextAlign.right,
                          style: const TextStyle(color: ColorsLectary.red),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          submitFuncSecondary();
                        },
                      ),
                      cancelButton
                    ],
                  )
                ]
              : [primaryButton, cancelButton],
        );
      },
    );
  }

  /// A simple [AlertDialog], which automatically calls the passed [reportCallback].
  static Future<void> showErrorReportDialog({
    required BuildContext context,
    required String errorContext,
    required String? errorMessage,
    required reportCallback,
  }) async {
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
                const Divider(),
                Text(AppLocalizations.of(context).reportErrorText),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text(
                  AppLocalizations.of(context).close,
                  style: const TextStyle(color: ColorsLectary.lightBlue),
                ),
                onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }
}
