import 'package:flutter/material.dart';
import 'package:lectary/data/api/lectary_api.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/models/response_type.dart';
import 'package:lectary/screens/core/custom_scaffold.dart';
import 'package:lectary/screens/lectures/main_screen.dart';
import 'package:lectary/screens/management/widgets/lecture_package_item.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/dialogs.dart';
import 'package:lectary/viewmodels/lecture_viewmodel.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:lectary/widgets/custom_search_bar.dart';
import 'package:provider/provider.dart';

/// Lecture management screen for downloading, updating and deleting [Lecture].
/// Retrieves all available [Lecture] from the [LectaryApi] and displays on success
/// a [ListView] of [LecturePackage] which are [Lecture] grouped by their package name.
class LectureManagementScreen extends StatefulWidget {
  static const String routeName = '/lectureManagement';

  @override
  _LectureManagementScreenState createState() => _LectureManagementScreenState();
}

class _LectureManagementScreenState extends State<LectureManagementScreen> {
  TextEditingController textEditingController = TextEditingController();

  // needed to control screen focus, i.e. handle the keyboard
  FocusNode focus = FocusNode();
  late LectureViewModel _lectureViewModel;

  @override
  void initState() {
    super.initState();

    /// Callback for loading lectures on first frame once the layout is finished completely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lectureViewModel = Provider.of<LectureViewModel>(context, listen: false);
      _lectureViewModel.loadLectaryData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _lectureViewModel.resetCurrentFilter());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        appBarTitle: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(AppLocalizations.of(context).screenManagementTitle)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: _buildBody(),
            ),
            Column(
              children: <Widget>[
                Divider(height: 1, thickness: 1),
                Container(
                  height: 60,
                  child: CustomSearchBar(
                    textEditingController: textEditingController,
                    focusNode: focus,
                    filterFunction:
                        Provider.of<LectureViewModel>(context, listen: false).filterLectureList,
                  ),
                ),
              ],
            )
          ],
        ));
  }

  // builds the body according to the response status
  Widget _buildBody() {
    final lectureViewModel = Provider.of<LectureViewModel>(context);

    switch (lectureViewModel.availableLectureStatus.status) {
      case Status.loading:
        return Center(child: CircularProgressIndicator());

      case Status.completed:
        // build list of widgets in the body
        List<Widget> bodyWidgets = [];
        // check if widgets for offline-mode are needed
        if (lectureViewModel.offlineMode) {
          bodyWidgets.add(Container(
            color: ColorsLectary.red,
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(AppLocalizations.of(context).noInternetConnection),
                Text(
                  AppLocalizations.of(context).offlineMode,
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ));
        }
        // add lecture-list-view to body widget list
        bodyWidgets.addAll({
          Expanded(
            child: _generateListView(lectureViewModel.availableLectures),
          ),
        });
        return lectureViewModel.availableLectures.isEmpty
            ? RefreshIndicator(
                color: ColorsLectary.lightBlue,
                onRefresh: () async {
                  Provider.of<LectureViewModel>(context, listen: false).loadLectaryData();
                },
                // refreshIndicator needs a scrollable child widget
                // using stack with listView to retain center position of error text
                // TODO review and maybe find better solution
                child: Stack(
                  children: <Widget>[
                    ListView(),
                    Center(
                      child: Text(AppLocalizations.of(context).noLecturesFound),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: bodyWidgets,
              );

      case Status.error:
        return RefreshIndicator(
          color: ColorsLectary.lightBlue,
          onRefresh: () async {
            Provider.of<LectureViewModel>(context, listen: false).loadLectaryData();
          },
          // refreshIndicator needs a scrollable child widget
          // using stack with listView to retain center position of error text
          // TODO review and maybe find better solution
          child: Stack(
            children: <Widget>[
              ListView(),
              Center(child: Text(lectureViewModel.availableLectureStatus.message!)),
            ],
          ),
        );

      default:
        return Container();
    }
  }

  // builds a listView with ListTiles based on the generated item-list
  Widget _generateListView(List<LecturePackage> lectures) {
    final String langMedia =
        Provider.of<SettingViewModel>(context, listen: false).settingLearningLanguage;
    return RefreshIndicator(
      color: ColorsLectary.lightBlue,
      onRefresh: () async {
        Provider.of<LectureViewModel>(context, listen: false).loadLectaryData();
      },
      child: ListView.separated(
        padding: EdgeInsets.all(0),
        separatorBuilder: (context, index) => Divider(height: 1, thickness: 1),
        itemCount: lectures.length + 1, // + 1 due to custom listTile for deleting lectures
        itemBuilder: (context, index) {
          // special last listTile with the option to delete all lectures
          if (index == lectures.length) {
            return Column(
              children: <Widget>[
                Divider(
                  height: 10,
                  thickness: 10,
                ),
                ListTileTheme(
                  iconColor: ColorsLectary.red,
                  textColor: ColorsLectary.red,
                  child: ListTile(
                    leading: Icon(Icons.delete_forever),
                    title: Text(AppLocalizations.of(context).deleteAllLectures),
                    onTap: () => Dialogs.showAlertDialogThreeButtons(
                        context: context,
                        title: AppLocalizations.of(context).deleteAllLecturesQuestion,
                        submitText1: AppLocalizations.of(context).deleteAllLectures,
                        submitText2: AppLocalizations.of(context).deleteOnlyLecturesFromLangPart1 +
                            langMedia +
                            AppLocalizations.of(context).deleteOnlyLecturesFromLangPart2,
                        submitFunc1: () async {
                          Dialogs.showLoadingDialog(
                              context: context,
                              text: AppLocalizations.of(context).deletingLectures);
                          await Provider.of<LectureViewModel>(context, listen: false)
                              .deleteAllLectures();
                          Navigator.popUntil(
                              context, ModalRoute.withName(LectureMainScreen.routeName));
                        },
                        submitFunc2: () async {
                          Dialogs.showLoadingDialog(
                              context: context,
                              text: AppLocalizations.of(context).deletingLectures);
                          await Provider.of<LectureViewModel>(context, listen: false)
                              .deleteAllLecturesFromLangMedia(langMedia);
                          Navigator.popUntil(
                              context, ModalRoute.withName(LectureMainScreen.routeName));
                        }),
                  ),
                ),
              ],
            );
          }
          // regular listTile for lectures
          return ListTileTheme(
            iconColor: ColorsLectary.lightBlue,
            child: LecturePackageItem(context, lectures[index]),
          );
        },
      ),
    );
  }
}
