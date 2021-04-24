import 'package:flutter/material.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/utils/constants.dart';


/// Custom searchBar widget.
/// Opens keyboard and sets focus immediately after initialization if [initOpen] is set to true.
/// The search bar uses a [TextField] with a [TextEditingController] for listening to text input/changes.
/// The input text will then be passed to the custom filter function.
class SearchBar extends StatefulWidget {
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final bool initOpen;
  final Function filterFunction;

  SearchBar(
      {required this.textEditingController,
      required this.focusNode,
      this.initOpen = false,
      required this.filterFunction,
      Key? key})
      : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  void initState() {
    if (widget.initOpen) {
      // open keyboard after widget is built
      WidgetsBinding.instance!.addPostFrameCallback((_) {
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
              onChanged: (value) => widget.filterFunction(value),
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
              icon: Icon(Icons.cancel, semanticLabel: Constants.semanticClearFilter),
            ),
          ),
          Visibility(
            visible: widget.focusNode.hasFocus ? true : false,
            child: TextButton(
              onPressed: () {
                // clears the focus and closes keyboard
                final FocusScopeNode currentScope = FocusScope.of(context);
                if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                  FocusManager.instance.primaryFocus!.unfocus();
                }
              },
              child: Text(
                AppLocalizations.of(context).cancel,
                style: TextStyle(color: ColorsLectary.lightBlue),
              ),
            ),
          )
        ],
      ),
    );
  }
}
