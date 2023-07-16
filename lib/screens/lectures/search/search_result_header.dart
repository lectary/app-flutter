import 'package:flutter/material.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';

class SearchResultHeader extends StatelessWidget {
  final String title;

  const SearchResultHeader(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingUppercase = context.select((SettingViewModel model) => model.settingUppercase);
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        color: ColorsLectary.white,
        child: ListTile(
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(settingUppercase ? title.toUpperCase() : title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold, color: ColorsLectary.lightBlue)),
          ),
        ),
      ),
    );
  }
}
