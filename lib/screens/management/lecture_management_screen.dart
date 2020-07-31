import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/screens/drawer/main_drawer.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/response_type.dart';
import 'package:lectary/viewmodels/lecture_viewmodel.dart';
import 'package:provider/provider.dart';


class LectureManagementScreen extends StatefulWidget {
  @override
  _LectureManagementScreenState createState() => _LectureManagementScreenState();
}

class _LectureManagementScreenState extends State<LectureManagementScreen> {

  @override
  void initState() {
    super.initState();
    /// Callback for loading lectures on first frame once the layout is finished completely
    WidgetsBinding.instance.addPostFrameCallback((_) =>
      Provider.of<LectureViewModel>(context, listen: false).loadLectures()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).screenManagementTitle),
      ),
      drawer: MainDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final lectureViewModel = Provider.of<LectureViewModel>(context);

    switch (lectureViewModel.lectureListLoadingStatus) {
      case Status.loading:
        return Center(
            child: CircularProgressIndicator(
          backgroundColor: ColorsLectary.darkBlue,
        ));

      case Status.completed:
        return lectureViewModel.availableLectures.isEmpty
            ? Container()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child:
                        _generateListView(lectureViewModel.availableLectures),
                  ),
                  Divider(height: 1, thickness: 1),
                  Container(
                    height: 60,
                    child: _buildSearchBar(),
                  ),
                ],
              );

      case Status.error:
        return Center(child: Text(lectureViewModel.lectureListLoadingErrorMessage));

      default:
        return Container();
    }
  }

  // builds a listView with ListTiles based on the generated item-list
  Widget _generateListView(List<LecturePackage> lectures) {
    return RefreshIndicator(
      color: ColorsLectary.lightBlue,
      onRefresh: () async {
        Provider.of<LectureViewModel>(context, listen: false).loadLectures();
      },
      child: ListView.separated(
        padding: EdgeInsets.all(0),
        separatorBuilder: (context, index) => Divider(),
        itemCount: lectures.length,
        itemBuilder: (context, index) {
          return ListTileTheme(
            iconColor: ColorsLectary.lightBlue,
            child: LecturePackageItem(lectures[index], context),
          );
        },
      ),
    );
  }

  Row _buildSearchBar() {
    // TODO check for native searchbars
    return Row(
      children: <Widget>[
        SizedBox(width: 15),
        Icon(Icons.search),
        SizedBox(width: 10),
        Expanded( // needed because textField has no intrinsic width, that the row wants to know!
          child: TextField(
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context).screenManagementSearchHint,
                border: InputBorder.none
            ),
          ),
        ),
      ],
    );
  }
}


class LecturePackageItem extends StatelessWidget {
  const LecturePackageItem(this.entry, this.context);

  final LecturePackage entry;
  final BuildContext context;

  // root level
  Widget _buildTiles(LecturePackage pack) {
    if (pack.children.isEmpty) return ListTile(title: Text(pack.title));
    List<Widget> childs = List<Widget>();
    childs.add(Container(
        padding: EdgeInsets.only(left: 15, top: 5, bottom: 5),
        alignment: Alignment.centerLeft,
        child: Text(pack.title, style: Theme.of(context).textTheme.caption))
    );
    pack.children.map(_buildChildren).forEach((element) {childs.addAll(element);});

    Column column = Column(
        children: childs
    );
    return column;
  }

  // children of an package
  List<Widget> _buildChildren(Lecture lecture) {
    return <Widget>[
      Divider(height: 1,thickness: 1),
      ListTile(
          leading: _getIconForLectureStatus(lecture.lectureStatus),
          title: Text("${lecture.lesson}"),
          trailing: IconButton(
              onPressed: () => _showLectureMenu(lecture),
              icon: Icon(Icons.more_horiz))),
    ];
  }

  Widget _getIconForLectureStatus(LectureStatus lectureStatus) {
    switch (lectureStatus) {
      case LectureStatus.downloading:
        return CircularProgressIndicator(backgroundColor: ColorsLectary.lightBlue,);
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
              _buildButton(Icons.close, "Abbrechen",
                  func: () => Navigator.pop(context)),
              Divider(height: 1, thickness: 1),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showMyDialog(String errorMessage) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upps...'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Leider ist beim Download der Lektion ein Fehler aufgetreten!'),
                Divider(),
                Text(errorMessage),
                Divider(),
                Text("Sie können den Fehler an das Lectary Team melden, damit dieser behoben werden kann."),
                FlatButton(
                  child: Text(
                    'Fehler melden',
                    style: TextStyle(color: ColorsLectary.lightBlue),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Schließen', style: TextStyle(color: ColorsLectary.lightBlue),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildButtonForLectureStatus(Lecture lecture, LectureViewModel lectureViewModel) {
      switch (lecture.lectureStatus) {
        case LectureStatus.notPersisted:
          return _buildButton(Icons.cloud_download, "Herunterladen",
              func: () async {
                Navigator.pop(context);
                Response response = await lectureViewModel.downloadAndSaveLecture(lecture);
                if (response.status == Status.error) {
                  _showMyDialog(response.message);
                }
              });
        case LectureStatus.persisted:
        case LectureStatus.removed:
          return _buildButton(Icons.delete, "Löschen",
              func: () {
                Navigator.pop(context);
                lectureViewModel.deleteLecture(lecture);
              });
        case LectureStatus.updateAvailable:
          return _buildButton(Icons.loop, "Aktualisieren",
              func: () {
                Navigator.pop(context);
                lectureViewModel.updateLecture(lecture);
              });
        default:
          return Container();
      }
  }

  Container _buildLectureInfoWidget(Lecture lecture) {
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // TODO replace mock text
            Text("Lektion: " + lecture.lesson),
            SizedBox(height: 10),
            Text("Paket: " + lecture.pack),
            SizedBox(height: 10),
            Text("Dateigröße: " + lecture.fileSize.toString() + " MB"),
            SizedBox(height: 10),
            Text("Vokabel: " + lecture.vocableCount.toString()),
          ],
        )
    );
  }

  Container _buildButton(icon, text, {Function func=emptyFunction}) {
    return Container(
        height: 50, // TODO maybe better use relative values via expanded?
        child: RaisedButton(
          onPressed: () {
            func();
          },
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

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}
