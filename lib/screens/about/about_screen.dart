import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/drawer/main_drawer.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/utils/global_theme.dart';
import 'package:url_launcher/url_launcher.dart';


/// About-Screen with credits, links and further information about the application and
/// the Lectary-team
class AboutScreen extends StatefulWidget {
  static const String routeName  = '/about';

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  List<TapGestureRecognizer> _tapGestureRecognizerList = List();

  @override
  void dispose() {
    _tapGestureRecognizerList.forEach((recognizer) => recognizer.dispose());
    super.dispose();
  }

  _buildTapGestureRecognizer(String link) {
    final recognizer = TapGestureRecognizer()..onTap = () => launch(link);
    _tapGestureRecognizerList.add(recognizer);
    return recognizer;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).screenAboutTitle),
      ),
      drawer: MainDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: ColorsLectary.logoDarkBlue,
                child: Center(
                    child: Image.asset("assets/images/logo_1024.png",
                        height: height / 4, fit: BoxFit.fitHeight))),
            Container(
              padding: EdgeInsets.all(15),
              child: RichText(
                text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText1,
                    children: [
                      TextSpan(
                          text: AppLocalizations.of(context).aboutIntroductionPart1,
                          children: [
                            TextSpan(
                              text: "Lectary.net.\n",
                              style: CustomTextStyle.hyperlink(context),
                              recognizer: _buildTapGestureRecognizer('https://lectary.net'),
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
                              style: CustomTextStyle.hyperlink(context),
                              recognizer: _buildTapGestureRecognizer('mailto:info@lectary.net')
                            ),
                          ]),
                      TextSpan(
                          text: AppLocalizations.of(context).aboutInstruction,
                          children: [
                            TextSpan(
                              text: "lectary.net/anleitung\n\n",
                              style: CustomTextStyle.hyperlink(context),
                              recognizer:_buildTapGestureRecognizer('https://lectary.net/anleitung4.html')
                            ),
                          ]),
                      TextSpan(
                          text: AppLocalizations.of(context).aboutCredits,
                          children: [
                            TextSpan(
                              text: "Flutter.dev.\n\n",
                              style: CustomTextStyle.hyperlink(context),
                              recognizer: _buildTapGestureRecognizer('https://flutter.dev')
                            ),
                            TextSpan(
                                text: AppLocalizations.of(context).aboutIconCredit,
                                children: [
                                  TextSpan(
                                    text: "Material Icons",
                                    style: CustomTextStyle.hyperlink(context),
                                    recognizer: _buildTapGestureRecognizer('https://material.io/resources/icons/')
                                  ),
                                  TextSpan(text: " & "),
                                  TextSpan(
                                    text: "FontAwesome\n\n",
                                    style: CustomTextStyle.hyperlink(context),
                                    recognizer: _buildTapGestureRecognizer('https://fontawesome.com/')
                                  ),
                                ]),
                            TextSpan(
                                text: AppLocalizations.of(context).aboutIconCreationCreditPart1,
                                children: [
                                  TextSpan(
                                    text: "FreePik ",
                                    style: CustomTextStyle.hyperlink(context),
                                    recognizer: _buildTapGestureRecognizer('https://www.flaticon.com/authors/freepik')
                                  ),
                                  TextSpan(
                                      text: AppLocalizations.of(context)
                                          .aboutIconCreationCreditPart2),
                                  TextSpan(
                                    text: "flaticon.com",
                                    style: CustomTextStyle.hyperlink(context),
                                    recognizer: _buildTapGestureRecognizer('https://flaticon.com')
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
                  text: AppLocalizations.of(context).aboutVersion
                  + Constants.versionCommitHash,
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
