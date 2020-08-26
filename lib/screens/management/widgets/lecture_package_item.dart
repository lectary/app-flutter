import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/dialogs.dart';
import 'package:lectary/utils/response_type.dart';
import 'package:lectary/viewmodels/lecture_viewmodel.dart';
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
    return _buildTiles(entry);
  }

  // builds the header tile for the package and standard tiles for the children
  Widget _buildTiles(LecturePackage pack) {
    // return when there are no children, although this should never happen
    if (pack.children.isEmpty) return ListTile(title: Text(pack.title));
    List<Widget> childs = List<Widget>();
    childs.add(
      Container(
        height: 70,
        alignment: Alignment.centerLeft,
        child: ListTile(
          title: Text(pack.title, style: Theme.of(context).textTheme.headline6),
          trailing: IconButton(
              onPressed: () => _showAbstract(pack.title, pack.abstract),
              icon: Icon(Icons.more_horiz)),
        ),
      ),
    );
    pack.children.map(_buildChildren).forEach((element) {childs.addAll(element);});

    Column column = Column(
        children: childs
    );
    return column;
  }

  // builds the bottom-modal-sheet for the abstract
  _showAbstract(String packTitle, String abstractText) {
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return Wrap(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Text(packTitle,
                    style: Theme.of(context).textTheme.headline6)),
            Divider(thickness: 1, height: 1),
            abstractText != null
                ? Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Html(
                      customTextStyle: (dom.Node node, TextStyle baseStyle) {
                        return baseStyle.merge(Theme.of(context).textTheme.bodyText1);
                      },
                      data: abstractText,
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
  List<Widget> _buildChildren(Lecture lecture) {
    return <Widget>[
      Divider(height: 1,thickness: 1),
      ListTile(
          leading: _getIconForLectureStatus(lecture.lectureStatus),
          title: Text(lecture.lesson),
          trailing: IconButton(
              onPressed: () => _showLectureMenu(lecture),
              icon: Icon(Icons.more_horiz))),
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
    final lecturesProvider = Provider.of<LectureViewModel>(context, listen: false);
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return ChangeNotifierProvider(
          create: (context) => lecturesProvider,
          child: Wrap(
            children: <Widget>[
              _buildLectureInfoWidget(lecture),
              Divider(height: 1, thickness: 1),
              _buildButtonForLectureStatus(lecture, lecturesProvider),
              Divider(height: 1, thickness: 1),
              _buildButton(icon: Icons.close, text: AppLocalizations.of(context).cancel,
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
  Container _buildLectureInfoWidget(Lecture lecture) {
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
                AppLocalizations.of(context).lectureInfoLecture +
                    lecture.lesson,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(AppLocalizations.of(context).lectureInfoPack + lecture.pack,
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
