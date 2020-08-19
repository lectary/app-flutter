import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/main.dart';
import 'package:lectary/screens/drawer/main_drawer.dart';
import 'package:lectary/utils/dialogs.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';


class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingViewModel>(context);

    final List<Widget> settingWidgetList = List.of({
      SwitchListTile(
          value: context.select((SettingViewModel model) => model.settingPlayMediaWithSound),
          title: Text("Medien mit Ton abspielen"),
          onChanged: (value) => settings.toggleSettingPlayMediaWithSound()),
      SwitchListTile(
          value: context.select((SettingViewModel model) => model.settingShowVideoTimeline),
          title: Text("Video-Zeitleiste anzeigen"),
          onChanged: (value) => settings.toggleSettingShowVideoTimeline()),
      SwitchListTile(
          value: context.select((SettingViewModel model) => model.settingShowMediaOverlay),
          title: Text("Medien-Overlay anzeigen"),
          onChanged: (value) => settings.toggleSettingShowMediaOverlay()),
      SwitchListTile(
          value: context.select((SettingViewModel model) => model.settingUppercase),
          title: Text("GROSSCHREIBEN"),
          onChanged: (value) => settings.toggleSettingUppercase()),
      ListTile(
          title: Text("Lernfortschritt zurücksetzen"),
          onTap: () => Dialogs.showAlertDialog(
              context: context,
              title: "Möchten Sie wirklich Ihren gesamten Lernfortschritt zurücksetzen?",
              submitText: "Zurücksetzen",
              submitFunc: settings.resetLearningProgress)),
      ListTile(
        title: Text("App-Sprache auswählen"),
        trailing: DropdownButton(
            value: context.select((SettingViewModel model) => model.settingAppLanguage),
            items: SettingViewModel.appLanguagesList
                .map((e) => DropdownMenuItem(child: Text(e.toUpperCase()), value: e)).toList(),
            onChanged: (value) async {
              if (settings.settingAppLanguage != value) {
                await settings.setSettingAppLanguage(value);
                log("setting new locale: $value");
                LocalizedApp.setLocale(context, Locale(value, ''));
              }
            }),
      ),
      ListTile(
        title: Text("Lernsprache auswählen"),
        trailing: context.select((SettingViewModel model) => model.isUpdatingLanguages)
            ? CircularProgressIndicator()
            : DropdownButton(
                value: context.select((SettingViewModel model) => model.settingLearningLanguage),
                items: (() {
                  List<DropdownMenuItem> items = context.select((SettingViewModel model) => model.learningLanguagesList)
                      .map((e) => DropdownMenuItem(child: Center(child: Text(e)), value: e)).toList();
                  // adding custom dropdown item for updating languages
                  items.add(DropdownMenuItem<String>(
                    child: Column(
                      children: [
                        Divider(),
                        Text("Aktualisieren"),
                      ],
                    ),
                    value: "_update",
                    onTap: settings.updateLearningLanguages,
                  ));
                  return items;
                })(),
                onChanged: (value) {
                  if (value != "_update") {
                    settings.setSettingLearningLanguage(value);
                  }
                }),
      ),
      ListTile(
        title: Text("Alle Einstellungen zurücksetzen"),
        onTap: () => Dialogs.showAlertDialog(
            context: context,
            title: "Möchten Sie wirklich alle Einstellungen zurücksetzen?",
            submitText: "Zurücksetzen",
            submitFunc: () async {
              String oldLang = settings.settingAppLanguage;
              await settings.resetAllSettings();
              String newLang = settings.settingAppLanguage;
              if (oldLang != newLang) {
                log("setting default locale: $newLang");
                LocalizedApp.setLocale(context, Locale(settings.settingAppLanguage, ''));
              }
            }
            ),
      ),
      ListTile(
          leading: Icon(Icons.info),
          title: Text("Über"),
          onTap: () {
            Navigator.pushNamed(context, '/about');
          }),
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).screenSettingsTitle),
      ),
      drawer: MainDrawer(),
      body: ListView.separated(
        padding: EdgeInsets.all(0),
        separatorBuilder: (context, index) => Divider(height: 1, thickness: 1),
        itemCount: settingWidgetList.length,
        itemBuilder: (BuildContext context, int index) {
          return settingWidgetList[index];
        }
      ),
    );
  }
}
