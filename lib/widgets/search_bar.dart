import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/utils/colors.dart';

class SearchBar extends StatefulWidget {
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final bool initOpen;
  final Function filterFunction;

  SearchBar({this.textEditingController, this.focusNode, this.initOpen=false, this.filterFunction, Key key}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  void initState() {
    if (widget.initOpen) {
      // open keyboard after widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(widget.focusNode);
        setState(() {});
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorsLectary.white,
      child: Row(
        children: <Widget>[
          SizedBox(width: 15),
          Icon(Icons.search),
          SizedBox(width: 10),
          Expanded( // needed because textField has no intrinsic width, that the row wants to know!
            child: TextField(
              style: TextStyle(color: Colors.black),
              onTap: () => setState(() {}),
              onChanged: (value) {
                widget.filterFunction(value);
              },
              focusNode: widget.focusNode,
              controller: widget.textEditingController,
              decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).screenManagementSearchHint,
                  border: InputBorder.none
              ),
            ),
          ),
          Visibility(
            visible: widget.textEditingController.text.isNotEmpty ? true : false,
            child: IconButton(
              onPressed: () {
                widget.textEditingController.clear();
                widget.filterFunction("");
              },
              icon: Icon(Icons.cancel),
            ),
          ),
          Visibility(
            visible: widget.focusNode.hasFocus ? true : false,
            child: FlatButton(
              onPressed: () {
                final FocusScopeNode currentScope = FocusScope.of(context);
                if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                  FocusManager.instance.primaryFocus.unfocus();
                }
              },
              child: Text("Cancel", style: TextStyle(color: ColorsLectary.lightBlue),),
            ),
          )
        ],
      ),
    );
  }
}
