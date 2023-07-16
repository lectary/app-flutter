import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/main.dart';
import 'package:lectary/screens/about/about_screen.dart';
import 'package:lectary/screens/core/custom_scaffold.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/utils/dialogs.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';

/// Setting-screen for changing various application settings
class SettingsScreen extends StatefulWidget {
  static const String routeName = '/settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingViewModel>(context);

    // defining the list of settings
    final List<Widget> settingWidgetList = List.of({
      SwitchListTile(
          value: context.select((SettingViewModel model) => model.settingPlayMediaWithSound),
          title: Text(AppLocalizations.of(context).settingMediaWithSound),
          onChanged: (value) => settings.toggleSettingPlayMediaWithSound()),
      SwitchListTile(
          value: context.select((SettingViewModel model) => model.settingShowVideoTimeline),
          title: Text(AppLocalizations.of(context).settingVideoTimeLine),
          onChanged: (value) => settings.toggleSettingShowVideoTimeline()),
      SwitchListTile(
          value: context.select((SettingViewModel model) => model.settingShowMediaOverlay),
          title: Text(AppLocalizations.of(context).settingMediaOverlay),
          onChanged: (value) => settings.toggleSettingShowMediaOverlay()),
      SwitchListTile(
          value: context.select((SettingViewModel model) => model.settingUppercase),
          title: Text(AppLocalizations.of(context).settingUppercase),
          onChanged: (value) => settings.toggleSettingUppercase()),
      ListTile(
          title: Text(AppLocalizations.of(context).settingResetLearningProgress),
          onTap: () => Dialogs.showAlertDialog(
              context: context,
              title: AppLocalizations.of(context).settingResetLearningProgressQuestion,
              submitText: AppLocalizations.of(context).reset,
              submitFunc: () {
                settings.resetLearningProgress();
                Provider.of<CarouselViewModel>(context, listen: false).reloadCurrentSelection();
              })),
      ListTile(
        title: Text(AppLocalizations.of(context).settingChooseAppLanguage),
        trailing: DropdownButton(
            value: context.select((SettingViewModel model) => model.settingAppLanguage),
            items: Constants.appLanguagesList
                .map((e) => DropdownMenuItem(child: Text(e.toUpperCase()), value: e))
                .toList(),
            onChanged: (dynamic value) async {
              if (settings.settingAppLanguage != value) {
                await settings.setSettingAppLanguage(value);
                log("setting new locale: $value");
                LocalizedApp.setLocale(context, Locale(value, ''));
              }
            }),
      ),
      ListTile(
        title: Text(AppLocalizations.of(context).settingChooseLearningLanguage),
        trailing: context.select((SettingViewModel model) => model.isUpdatingLanguages)
            ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator())
            : DropdownButton<String>(
                value: context.select((SettingViewModel model) => model.settingLearningLanguage),
                items: _buildDropdownItems(settings),
                onChanged: (String? value) {
                  if (value != null && value != "_update") {
                    // filter the update value
                    settings.setSettingLearningLanguage(value);
                  }
                }),
        onTap: () {},
      ),
      ListTile(
        title: Text(AppLocalizations.of(context).settingResetSettings),
        onTap: () => Dialogs.showAlertDialog(
            context: context,
            title: AppLocalizations.of(context).settingResetSettingsQuestion,
            submitText: AppLocalizations.of(context).reset,
            submitFunc: () async {
              String oldLang = settings.settingAppLanguage;
              await settings.resetAllSettings();
              String newLang = settings.settingAppLanguage;
              // only switch locale if it actually changed
              if (oldLang != newLang) {
                log("setting default locale: $newLang");
                LocalizedApp.setLocale(context, Locale(settings.settingAppLanguage, ''));
              }
            }),
      ),
      // link to about-screen
      ListTile(
          leading: Icon(
            Icons.info,
            color: ColorsLectary.lightBlue,
          ),
          title: Text(AppLocalizations.of(context).about),
          onTap: () {
            Navigator.pushNamed(context, AboutScreen.routeName);
          }),
    });

    // building body with the listView and the list of setting-widgets
    return CustomScaffold(
      appBarTitle: Text(AppLocalizations.of(context).screenSettingsTitle),
      body: ListView.separated(
          padding: EdgeInsets.all(0),
          separatorBuilder: (context, index) => Divider(height: 1, thickness: 1),
          itemCount: settingWidgetList.length,
          itemBuilder: (BuildContext context, int index) {
            return settingWidgetList[index];
          }),
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(SettingViewModel settings) {
    List<DropdownMenuItem<String>> items = context
        .select((SettingViewModel model) => model.learningLanguagesList)
        .map((e) => DropdownMenuItem<String>(child: Center(child: Text(e)), value: e))
        .toList();
    // adding custom dropdown item for updating languages
    items.add(DropdownMenuItem<String>(
      child: Column(
        children: [
          Divider(),
          Text(AppLocalizations.of(context).update),
        ],
      ),
      value: "_update", // special 'key' value for filtering it later
      onTap: settings.updateLearningLanguages,
    ));
    return items;
  }
}
