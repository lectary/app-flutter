import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/drawer/main_drawer.dart';
import 'package:lectary/utils/colors.dart';
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
          onTap: () => settings.resetLearningProgress()),
      ListTile(
        title: Text("App-Language auswählen"),
        trailing: DropdownButton(
            value: context.select((SettingViewModel model) => model.settingAppLanguage),
            items: SettingViewModel.appLanguagesList
                .map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
            onChanged: (value) => settings.setSettingAppLanguage(value)),
      ),
      ListTile(
        title: Text("Lernsprache auswählen"),
        trailing: DropdownButton(
          value: context.select((SettingViewModel model) => model.settingLearningLanguage),
          items: SettingViewModel.learningLanguagesList
              .map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
          onChanged: (value) => settings.setSettingLearningLanguage(value),
        ),
      ),
      ListTile(
          title: Text("Alle Einstellungen zurücksetzen"),
          onTap: () => settings.resetAllSettings()),
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
