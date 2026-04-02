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
    super.key,
    this.appBarTitle,
    this.appBarActions,
    required this.body,
    this.resizeToAvoidBottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return EdgeToEdgeContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: CustomAppBar(
          title: appBarTitle,
          actions: appBarActions,
        ),
        drawer: const CustomDrawer(),
        body: body,
      ),
    );
  }
}

/// Adds padding to bottom to account for system navigation bars used for EdgeToEdge system mode.
class EdgeToEdgeContainer extends StatelessWidget {
  final Widget child;

  const EdgeToEdgeContainer({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    double bottomSafeAreaPadding = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomSafeAreaPadding),
      child: child,
    );
  }
}
