import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/models/selection_type.dart';
import 'package:lectary/screens/lectures/main_screen.dart';
import 'package:lectary/screens/management/lecture_management_screen.dart';
import 'package:lectary/screens/settings/settings_screen.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/global_theme.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';

import 'lecture_package_item.dart';

/// Drawer screen, handling the navigation and loading of local [Lecture]s
/// Used for further navigation to [LectureManagementScreen] and [SettingsScreen]
class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late CarouselViewModel _carouselViewModel;

  /// Listening to drawer init(opened) and disposed(closed) to interrupt
  /// medias corresponding.
  /// Using [WidgetsBinding.instance.addPostFrameCallback] to ensure the action
  /// is performed after the build, to avoid build-errors.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carouselViewModel = Provider.of<CarouselViewModel>(context, listen: false);
      _carouselViewModel.interrupted = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_carouselViewModel.interruptedCauseNavigation) _carouselViewModel.interrupted = false;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String learningLanguage =
        context.select((SettingViewModel model) => model.settingLearningLanguage);
    return Theme(
      data: CustomAppTheme.defaultLightTheme,
      child: Builder(builder: (context) {
        final paddingTop = MediaQuery.paddingOf(context).top;
        return Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: paddingTop),
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_ios),
                      ),
                      Text(
                        learningLanguage,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold, color: ColorsLectary.lightBlue),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: _generateListView(context),
                ),
              ),
              const Divider(height: 1, thickness: 1),
              _buildButton(
                  context: context,
                  flex: 1,
                  icon: Icons.cloud_download,
                  text: AppLocalizations.of(context).drawerButtonLectureManagement,
                  routeName: LectureManagementScreen.routeName),
              const Divider(height: 1, thickness: 1),
              _buildButton(
                  context: context,
                  flex: 1,
                  icon: Icons.settings,
                  text: AppLocalizations.of(context).drawerButtonSettings,
                  routeName: SettingsScreen.routeName),
              const Divider(height: 1, thickness: 1),
            ],
          ),
        );
      }),
    );
  }

  /// Creates a horizontal stretched button with passed icon, text and route navigation tapEvent
  Widget _buildButton({
    required BuildContext context,
    required int flex,
    required IconData icon,
    required String text,
    required String routeName,
  }) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context); // close drawer first to avoid unwanted behaviour!
          Navigator.pushNamedAndRemoveUntil(
              context, routeName, ModalRoute.withName(LectureMainScreen.routeName));
        },
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: ColorsLectary.lightBlue,
            ),
            const SizedBox(width: 10), // spacer
            Text(text),
          ],
        ),
      ),
    );
  }

  /// Builds a [ListView] with [ListTile] based on the local persisted lectures, provided
  /// as [Stream], via a [StreamBuilder]. Retrieves the stream from the viewModel [CarouselViewModel]
  /// The items of the [ListView] are of type [LecturePackage]
  Widget _generateListView(BuildContext context) {
    Selection? selection = context.select((CarouselViewModel model) => model.currentSelection);
    return StreamBuilder<List<LecturePackage>>(
        stream: Provider.of<CarouselViewModel>(context, listen: false).loadLocalLecturesAsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context).drawerNoLecturesAvailable),
            );
          }
          return ListView.separated(
              padding: const EdgeInsets.all(0),
              separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
              itemCount: snapshot.data!.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    color: selection != null && selection.type == SelectionType.all
                        ? ColorsLectary.lightBlue
                        : ColorsLectary.white,
                    child: ListTile(
                      title: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          AppLocalizations.of(context).allVocables,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: selection != null && selection.type == SelectionType.all
                                  ? ColorsLectary.white
                                  : Colors.black),
                        ),
                      ),
                      onTap: () {
                        Provider.of<CarouselViewModel>(context, listen: false).loadAllVocables();
                        Navigator.pop(context); // close drawer first to avoid unwanted behaviour!
                        Navigator.popUntil(
                            context, ModalRoute.withName(LectureMainScreen.routeName));
                      },
                    ),
                  );
                }
                return LecturePackageItem(context, snapshot.data![index - 1]);
              });
        });
  }
}
