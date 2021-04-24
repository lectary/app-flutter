import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/lectures/lecture_not_available_screen.dart';
import 'package:lectary/screens/management/lecture_management_screen.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';


/// Lecture screen similar to [LectureNotAvailableScreen], but which is meant to be shown only once after app-installation.
/// Features additional buttons for each available language of [SettingViewModel.learningLanguagesList],
/// pointing to [LectureManagementScreen] and setting the corresponding [SettingViewModel.learningLanguagesList]
/// at the same time.
class LectureStartupScreen extends StatelessWidget {
  LectureStartupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> languages = Provider.of<SettingViewModel>(context, listen: false).learningLanguagesList;
    // build button list
    final List<Widget> buttons = languages.map((langMedia) => _buildButtonWithLang(context, langMedia)).toList();
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
            Flexible( // expand only if needed and there is available space
              child: ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, index) => SizedBox(height: 10),
                itemBuilder: (context, index) => buttons[index],
                itemCount: buttons.length,
              ),
            ),
            SizedBox(height: 10,), // separator
            Text(
              AppLocalizations.of(context).minMaxLectureSizes,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 10,), // separator
            Text(
              AppLocalizations.of(context).learningLanguageCanBeChanged,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme
                  .subtitle1!
                  .copyWith(fontSize: Theme.of(context).textTheme
                  .subtitle1!
                  .fontSize! - 2),
            )
          ],
        ),
      ),
    );
  }

  /// Builds a button for a specific language.
  /// Navigates to [LectureManagementScreen] when pressed.
  /// Loads async a corresponding flag-image for the passed language.
  RaisedButton _buildButtonWithLang(BuildContext context, String langMedia) {
    final double flagHeight = 60;
    final double flagWidth = 100;
    return RaisedButton(
      onPressed: () {
        Provider.of<SettingViewModel>(context, listen: false).setSettingLearningLanguage(langMedia);
        Navigator.pushNamed(context, LectureManagementScreen.routeName);
      },
      padding: EdgeInsets.all(15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            AppLocalizations.of(context).downloadAndManageLecturesFromLangPart1 +
                langMedia +
                AppLocalizations.of(context).downloadAndManageLecturesFromLangPart2,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6,
          ),
          // FutureBuilder for loading the corresponding flag-widget asynchronously
          FutureBuilder(
            future: _buildFlagWidget(langMedia, flagHeight, flagWidth),
            builder: (BuildContext context, AsyncSnapshot<Widget?> snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      snapshot.data == null ? Container() : SizedBox(width: flagWidth),
                      Icon(
                        Icons.cloud_download,
                        size: flagHeight,
                      ),
                      snapshot.data!
                    ]);
              } else {
                return Icon(
                  Icons.cloud_download,
                  size: flagHeight,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// Creates an [Image.asset] widget based on the passed langMedia, which will be used as country-isoCode to
  /// load the corresponding flag.
  /// Maps languages "ÖGS" to "AT" and "DGS" to "DE.
  /// Returns [Null] if langMedia does not match an country isoCode.
  Future<Widget?> _buildFlagWidget(String langMedia, double flagHeight, double flagWidth) async {
    String isoCode;
    switch (langMedia) {
      case "ÖGS":
        isoCode = "AT";
        break;
      case "DGS":
        isoCode = "DE";
        break;
      default:
        isoCode = langMedia;
        break;
    }
    // check if an corresponding flag-image exists for the calculated isoCode
    // catches any asset exceptions and returns null
    String imageAssetPath = 'icons/flags/png/${isoCode.toLowerCase()}.png';
    bool assetExists = await checkIfAssetExists(imageAssetPath, package: "country_icons");
    if (!assetExists) {
      print("flag image asset does not exist for $isoCode");
      return null;
    }
    final image = Image.asset(imageAssetPath, package: 'country_icons');
    return Container(
        height: flagHeight,
        width: flagWidth,
        child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 16.0),
              child: image,
            )));
  }

  /// Utility function to check if an asset with the passed path exists
  /// and to catch any possible exception to handle them gracefully.
  Future<bool> checkIfAssetExists(String assetPath, {String? package}) async {
    try {
      String path = package == null ? assetPath : "packages/$package/$assetPath";
      await rootBundle.load(path);
      return true;
    } catch(_) {
      return false;
    }
  }
}
