import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/core/custom_scaffold.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/utils/global_theme.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// About-Screen with credits, links and further information about the application and
/// the Lectary-team
class AboutScreen extends StatefulWidget {
  static const String routeName = '/about';

  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final List<TapGestureRecognizer> _tapGestureRecognizerList = [];

  @override
  void dispose() {
    _tapGestureRecognizerList.forEach((recognizer) => recognizer.dispose());
    super.dispose();
  }

  _buildTapGestureRecognizer(String link) {
    final recognizer = TapGestureRecognizer()..onTap = () => launchUrlString(link);
    _tapGestureRecognizerList.add(recognizer);
    return recognizer;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return CustomScaffold(
      appBarTitle: Text(AppLocalizations.of(context).screenAboutTitle),
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
              padding: const EdgeInsets.all(15),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge,
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context).aboutIntroductionPart1,
                      children: [
                        TextSpan(
                          text: "Lectary.net.\n",
                          style: CustomAppTheme.hyperlink(context),
                          recognizer: _buildTapGestureRecognizer('https://lectary.net'),
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context).aboutIntroductionPart2,
                        ),
                      ],
                    ),
                    TextSpan(text: AppLocalizations.of(context).aboutContact, children: [
                      TextSpan(
                          text: "info@lectary.net.\n\n",
                          style: CustomAppTheme.hyperlink(context),
                          recognizer: _buildTapGestureRecognizer('mailto:info@lectary.net')),
                    ]),
                    TextSpan(text: AppLocalizations.of(context).aboutInstruction, children: [
                      TextSpan(
                          text: "lectary.net/anleitung\n\n",
                          style: CustomAppTheme.hyperlink(context),
                          recognizer:
                              _buildTapGestureRecognizer('https://lectary.net/anleitung4.html')),
                    ]),
                    TextSpan(
                      text: AppLocalizations.of(context).aboutCredits,
                      children: [
                        TextSpan(
                            text: "Flutter.dev.\n\n",
                            style: CustomAppTheme.hyperlink(context),
                            recognizer: _buildTapGestureRecognizer('https://flutter.dev')),
                        TextSpan(
                          text: AppLocalizations.of(context).aboutIconCredit,
                          children: [
                            TextSpan(
                                text: "Material Icons",
                                style: CustomAppTheme.hyperlink(context),
                                recognizer: _buildTapGestureRecognizer(
                                    'https://material.io/resources/icons/')),
                            const TextSpan(text: " & "),
                            TextSpan(
                                text: "FontAwesome\n\n",
                                style: CustomAppTheme.hyperlink(context),
                                recognizer: _buildTapGestureRecognizer('https://fontawesome.com/')),
                          ],
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context).aboutIconCreationCreditPart1,
                          children: [
                            TextSpan(
                                text: "FreePik ",
                                style: CustomAppTheme.hyperlink(context),
                                recognizer: _buildTapGestureRecognizer(
                                    'https://www.flaticon.com/authors/freepik')),
                            TextSpan(
                                text: AppLocalizations.of(context).aboutIconCreationCreditPart2),
                            TextSpan(
                                text: "flaticon.com",
                                style: CustomAppTheme.hyperlink(context),
                                recognizer: _buildTapGestureRecognizer('https://flaticon.com')),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: RichText(
                textAlign: TextAlign.right,
                text: TextSpan(
                  text: AppLocalizations.of(context).aboutVersion + Constants.versionCommitHash,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 70,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: ColorsLectary.lightBlue),
                child: Text(
                  AppLocalizations.of(context).okUppercase,
                  style: const TextStyle(color: Colors.black, fontSize: 32),
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
