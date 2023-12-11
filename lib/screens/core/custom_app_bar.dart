import 'package:flutter/material.dart';

typedef AppBarGradientCallback = bool Function(BuildContext context);

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final TabBar? tabs;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.tabs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: actions,
      bottom: tabs,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
