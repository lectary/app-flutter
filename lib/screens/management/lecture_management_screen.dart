import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/screens/drawer/main_drawer.dart';
import 'package:lectary/screens/management/widgets/lecture_package_item.dart';
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

    switch (lectureViewModel.availableLectureStatus.status) {
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
        return RefreshIndicator(
          color: ColorsLectary.lightBlue,
          onRefresh: () async {
            Provider.of<LectureViewModel>(context, listen: false)
                .loadLectures();
          },
          // refreshIndicator needs a scrollable child widget
          // using stack with listView to retain center position of error text
          // TODO review and maybe find better solution
          child: Stack(
            children: <Widget>[
              ListView(),
              Center(child: Text(lectureViewModel.availableLectureStatus.message)),
            ],
          ),
        );

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
            child: LecturePackageItem(context, lectures[index]),
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