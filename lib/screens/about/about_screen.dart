import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/drawer/main_drawer.dart';
import 'package:lectary/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';


/// About-Screen with credits, links and further information about the application and
/// the Lectary-team
class AboutScreen extends StatefulWidget {
  static const String routeName  = '/about';

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  TapGestureRecognizer tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    tapGestureRecognizer = TapGestureRecognizer();
  }

  @override
  void dispose() {
    tapGestureRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).screenAboutTitle),
      ),
      drawer: MainDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // TODO exchange with the correct Lectary text-logo
            Image.asset("assets/images/Logo1_1024x1024.png"),
            Container(
              padding: EdgeInsets.all(15),
              child: RichText(
                text: TextSpan(
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    children: [
                      TextSpan(
                          text: AppLocalizations.of(context).aboutIntroductionPart1,
                          children: [
                            TextSpan(
                              text: "Lectary.net.\n",
                              style: TextStyle(color: ColorsLectary.red),
                              recognizer: tapGestureRecognizer
                                ..onTap = () => launch('https://lectary.net')
                            ),
                            TextSpan(
                              text: AppLocalizations.of(context).aboutIntroductionPart2,
                            ),
                          ]),
                      TextSpan(
                          text: AppLocalizations.of(context).aboutContact,
                          children: [
                            TextSpan(
                              text: "info@lectary.net.\n\n",
                              style: TextStyle(color: ColorsLectary.red),
                              recognizer: tapGestureRecognizer
                                ..onTap = () => launch('mailto:info@lectary.net')
                            ),
                          ]),
                      TextSpan(
                          text: AppLocalizations.of(context).aboutInstruction,
                          children: [
                            TextSpan(
                              text: "lectary.net/anleitung\n\n",
                              style: TextStyle(color: ColorsLectary.red),
                              recognizer: tapGestureRecognizer
                                ..onTap = () => launch('https://lectary.net/anleitung.html')
                            ),
                          ]),
                      TextSpan(
                          text: AppLocalizations.of(context).aboutCredits,
                          children: [
                            TextSpan(
                              text: "Flutter.dev.\n\n",
                              style: TextStyle(color: ColorsLectary.red),
                              recognizer: tapGestureRecognizer
                                ..onTap = () => launch('https://flutter.dev')
                            ),
                            TextSpan(
                                text: AppLocalizations.of(context).aboutIconCredit,
                                children: [
                                  TextSpan(
                                    text: "Material Icons",
                                    style: TextStyle(color: ColorsLectary.red),
                                    recognizer: tapGestureRecognizer
                                      ..onTap = () => launch('https://material.io/resources/icons/?style=baseline')
                                  ),
                                  TextSpan(text: " & "),
                                  TextSpan(
                                    text: "FontAwesome\n\n",
                                    style: TextStyle(color: ColorsLectary.red),
                                    recognizer: tapGestureRecognizer
                                      ..onTap = () => launch('https://fontawesome.com/')
                                  ),
                                ]),
                            TextSpan(
                                text: AppLocalizations.of(context).aboutIconCreationCreditPart1,
                                children: [
                                  TextSpan(
                                    text: "FreePik ",
                                    style: TextStyle(color: ColorsLectary.red),
                                    recognizer: tapGestureRecognizer
                                      ..onTap = () => launch('https://www.freepik.com/')
                                  ),
                                  TextSpan(
                                      text: AppLocalizations.of(context)
                                          .aboutIconCreationCreditPart2),
                                  TextSpan(
                                    text: "flaticon.com",
                                    style: TextStyle(color: ColorsLectary.red),
                                    recognizer: tapGestureRecognizer
                                      ..onTap = () => launch('https://flaticon.com')
                                  ),
                                ]),
                          ]),
                    ]),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: RichText(
                textAlign: TextAlign.right,
                text: TextSpan(
                  text: AppLocalizations.of(context).aboutVersion,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Container(
              height: 70,
              child: RaisedButton(
                color: ColorsLectary.lightBlue,
                child: Text(
                  AppLocalizations.of(context).okUppercase,
                  style: TextStyle(color: Colors.black, fontSize: 32),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
