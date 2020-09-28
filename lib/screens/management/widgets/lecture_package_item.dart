import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/models/response_type.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/utils/dialogs.dart';
import 'package:lectary/utils/global_theme.dart';
import 'package:lectary/viewmodels/lecture_viewmodel.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


/// Helper class for realizing categorization of [Lecture] by its package name.
/// Creates for every [LecturePackageItem] one special header [ListTile] and maps
/// its children list of [Lecture] to a standard [ListTile].
class LecturePackageItem extends StatelessWidget {
  const LecturePackageItem(this.context, this.entry);

  final BuildContext context;
  final LecturePackage entry;

  @override
  Widget build(BuildContext context) {
    final settingUppercase = context.select((SettingViewModel model) => model.settingUppercase);
    return _buildTiles(entry, settingUppercase);
  }

  // builds the header tile for the package and standard tiles for the children
  Widget _buildTiles(LecturePackage pack, bool uppercase) {
    // return when there are no children, although this should never happen
    if (pack.children.isEmpty) return ListTile(title: Text(uppercase ? pack.title.toUpperCase() : pack.title));
    List<Widget> childs = List<Widget>();
    childs.add(
      Container(
        height: 70,
        alignment: Alignment.centerLeft,
        child: ListTile(
          title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(uppercase ? pack.title.toUpperCase() : pack.title,
                  style: Theme.of(context).textTheme.headline6)),
          trailing: IconButton(
              onPressed: () =>
                  _showAbstract(pack.title, pack.abstract, uppercase),
              icon: Icon(Icons.more_horiz,
                  semanticLabel: Constants.semanticOpenAbstract)),
        ),
      ),
    );
    pack.children.map((e) => _buildChildren(e, uppercase)).forEach((element) {childs.addAll(element);});

    Column column = Column(
        children: childs
    );
    return column;
  }

  // builds the bottom-modal-sheet for the abstract
  _showAbstract(String packTitle, String abstractText, bool uppercase) {
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return Wrap(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Text(uppercase ? packTitle.toUpperCase() : packTitle,
                    style: Theme.of(context).textTheme.headline6)),
            Divider(thickness: 1, height: 1),
            abstractText != null
                ? Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Html(
                      data: uppercase ? abstractText.toUpperCase() : abstractText,
                      customTextStyle: (dom.Node node, TextStyle baseStyle) {
                        return baseStyle.copyWith(
                          fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                          fontFamily: Theme.of(context).textTheme.bodyText1.fontFamily,
                        );
                      },
                      linkStyle: CustomTextStyle.hyperlink(context),
                      onLinkTap: (url) async {
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          log('Could not launch url: $url of abstract: $abstractText');
                        }
                      },
                    ))
                : Container(
                    padding: EdgeInsets.all(10),
                    child: Center(
                        child: Text(AppLocalizations.of(context).noDescription,
                            style: Theme.of(context).textTheme.bodyText1))),
            Divider(height: 1, thickness: 1),
            _buildButton(icon: Icons.close, text: AppLocalizations.of(context).cancel,
                func: () => Navigator.pop(context)),
          ],
        );
      },
    );
  }

  // builds the children of an package
  List<Widget> _buildChildren(Lecture lecture, bool uppercase) {
    return <Widget>[
      Divider(height: 1,thickness: 1),
      ListTile(
          leading: _getIconForLectureStatus(lecture.lectureStatus),
          title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                  uppercase ? lecture.lesson.toUpperCase() : lecture.lesson)),
          trailing: IconButton(
              onPressed: () => _showLectureMenu(lecture),
              icon: Icon(Icons.more_horiz,
                  semanticLabel: Constants.semanticOpenMenu))),
    ];
  }

  // return the icon for the corresponding lectureStatus
  Widget _getIconForLectureStatus(LectureStatus lectureStatus) {
    switch (lectureStatus) {
      case LectureStatus.downloading:
        return SizedBox(
            width: 24, height: 24, child: CircularProgressIndicator());
      case LectureStatus.persisted:
        return Icon(Icons.check_circle);
      case LectureStatus.removed:
        return Icon(Icons.error, color: ColorsLectary.red,);
      case LectureStatus.updateAvailable:
        return Icon(Icons.loop);
      default:
        return Icon(null);
    }
  }

  // builds the bottom-modal-sheet for the lecture menu
  _showLectureMenu(Lecture lecture) {
    LectureViewModel lectureViewModel = Provider.of<LectureViewModel>(context, listen: false);
    SettingViewModel settingViewModel = Provider.of<SettingViewModel>(context, listen: false);
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return MultiProvider(
          providers: [
            // re-using existing instances of the viewModels via value-constructor
            ChangeNotifierProvider.value(value: lectureViewModel),
            ChangeNotifierProvider.value(value: settingViewModel)
          ],
          child: Wrap(
            children: <Widget>[
              _buildLectureInfoWidget(lecture, settingViewModel),
              Divider(height: 1, thickness: 1),
              _buildButtonForLectureStatus(lecture, lectureViewModel),
              Divider(height: 1, thickness: 1),
              _buildButton(
                  icon: Icons.close,
                  text: AppLocalizations.of(context).cancel,
                  func: () => Navigator.pop(context)),
            ],
          ),
        );
      },
    );
  }

  // builds the correct buttons corresponding to the lecture status
  Widget _buildButtonForLectureStatus(Lecture lecture, LectureViewModel lectureViewModel) {
    switch (lecture.lectureStatus) {
      case LectureStatus.notPersisted:
        return _buildButton(icon: Icons.cloud_download, text: AppLocalizations.of(context).download,
            func: () async {
              Navigator.pop(context);
              Response response = await lectureViewModel.downloadAndSaveLecture(lecture);
              if (response.status == Status.error) {
                Dialogs.showErrorReportDialog(
                    context: context,
                    errorContext: AppLocalizations.of(context).errorDownloadLecture,
                    errorMessage: response.message);
              }
            });
      case LectureStatus.persisted:
      case LectureStatus.removed:
        return _buildButton(icon: Icons.delete, text: AppLocalizations.of(context).delete,
            func: () async {
              Navigator.pop(context);
              Response response = await lectureViewModel.deleteLecture(lecture);
              if (response.status == Status.error) {
                Dialogs.showErrorReportDialog(
                    context: context,
                    errorContext: AppLocalizations.of(context).errorDownloadLecture,
                    errorMessage: response.message);
              }
            });
      case LectureStatus.updateAvailable:
        return _buildButton(icon: Icons.loop, text: AppLocalizations.of(context).update,
            func: () async {
              Navigator.pop(context);
              Response response = await lectureViewModel.updateLecture(lecture);
              if (response.status == Status.error) {
                Dialogs.showErrorReportDialog(
                    context: context,
                    errorContext: AppLocalizations.of(context).errorDownloadLecture,
                    errorMessage: response.message);
              }
            });
      default:
        return Container();
    }
  }

  // builds the text part for the lecture menu bottom-modal-sheet
  Container _buildLectureInfoWidget(Lecture lecture, SettingViewModel settingViewModel) {
    final uppercase = settingViewModel.settingUppercase;
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
                AppLocalizations.of(context).lectureInfoLecture +
                    (uppercase ? lecture.lesson.toUpperCase() : lecture.lesson),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(
                AppLocalizations.of(context).lectureInfoPack +
                    (uppercase ? lecture.pack.toUpperCase() : lecture.pack),
                style: Theme.of(context).textTheme.bodyText1),
            SizedBox(height: 10),
            Text(
                AppLocalizations.of(context).lectureInfoFileSize +
                    lecture.fileSize.toString() +
                    AppLocalizations.of(context).lectureInfoFileSizeUnit,
                style: Theme.of(context).textTheme.bodyText1),
            SizedBox(height: 10),
            Text(
                AppLocalizations.of(context).lectureInfoVocableCount +
                    lecture.vocableCount.toString(),
                style: Theme.of(context).textTheme.bodyText1),
          ],
        ));
  }

  // builds the buttons
  Container _buildButton({IconData icon, String text, Function func=emptyFunction}) {
    return Container(
        height: 50,
        child: RaisedButton(
          onPressed: () => func(),
          child: Container(
            child: Row(
              children: <Widget>[
                Icon(icon, color: ColorsLectary.lightBlue,),
                SizedBox(width: 10), // spacer
                Text(text),
              ],
            ),
          ),
        )
    );
  }
  static emptyFunction() {}
}
