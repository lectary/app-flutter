import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/drawer/main_drawer.dart';


class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).screenSettingsTitle),
      ),
      drawer: MainDrawer(),
      body: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          Divider(height: 1, thickness: 1),
          SwitchListTile(value: false,title: Text("Video mit Ton"),onChanged: (value) {}),
          Divider(height: 1, thickness: 1),
          SwitchListTile(value: false,title: Text("Video-Zeitleiste verbergen"),onChanged: (value) {}),
          Divider(height: 1, thickness: 1),
          SwitchListTile(value: false,title: Text("Video-Overlay verbergen"),onChanged: (value) {}),
          Divider(height: 1, thickness: 1),
          SwitchListTile(value: false,title: Text("GROSSCHREIBEN"),onChanged: (value) {}),
          Divider(height: 1, thickness: 1),
          ListTile(leading: Icon(Icons.info), title: Text("Über"),
              onTap: () {Navigator.pushNamed(context, '/about');}
          ),
          Divider(height: 1, thickness: 1),
        ],
      ),
    );
  }
}
