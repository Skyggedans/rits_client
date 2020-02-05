import 'package:flutter/material.dart';

import '../models/filter_groups/filter_groups.dart';

class FilterGroupsSelectionScreen extends StatefulWidget {
  final List<FilterGroup> filterGroups;
  final String userToken;

  FilterGroupsSelectionScreen({
    Key key,
    @required this.filterGroups,
    @required this.userToken,
  })  : assert(filterGroups != null),
        assert(userToken != null);

  @override
  State createState() => FilterGroupsSelectionScreenState();
}

class FilterGroupsSelectionScreenState
    extends State<FilterGroupsSelectionScreen> {
  FilterGroup _selectedFilterGroup;

  List<FilterGroup> get _filterGroups => widget.filterGroups;

  @override
  void initState() {
    super.initState();
    // _selectedFilterGroup =
    //     _filterGroups.singleWhere((filterGroup) => filterGroup.isActive);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Filter Group'),
        actions: <Widget>[
          FlatButton(
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                Text(
                  'ACCEPT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.pop(context, _selectedFilterGroup);
            },
          )
        ],
      ),
      body: Center(
        child: ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: _filterGroups.length,
          itemBuilder: (context, index) {
            final filterGroup = _filterGroups[index];

            return InkWell(
              child: Semantics(
                button: true,
                value: filterGroup.name,
                child: RadioListTile(
                  title: Text(filterGroup.name),
                  value: filterGroup,
                  groupValue: _selectedFilterGroup,
                  onChanged: (FilterGroup value) {
                    setState(() {
                      _selectedFilterGroup = value;
                    });
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
