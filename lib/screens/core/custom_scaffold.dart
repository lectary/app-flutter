import 'package:flutter/material.dart';
import 'package:lectary/screens/core/drawer/custom_drawer.dart';

import 'custom_app_bar.dart';

class CustomScaffold extends StatelessWidget {
  final Widget? appBarTitle;
  final List<Widget>? appBarActions;
  final Widget body;

  /// See [Scaffold.resizeToAvoidBottomInset].
  final bool? resizeToAvoidBottomInset;

  const CustomScaffold({
    Key? key,
    this.appBarTitle,
    this.appBarActions,
    required this.body,
    this.resizeToAvoidBottomInset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: CustomAppBar(
        title: appBarTitle,
        actions: appBarActions,
      ),
      drawer: CustomDrawer(),
      body: body,
    );
  }
}
