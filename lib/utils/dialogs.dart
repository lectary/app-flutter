import 'package:flutter/material.dart';

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
}