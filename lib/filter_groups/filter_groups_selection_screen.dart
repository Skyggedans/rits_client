import 'package:flutter/material.dart';
import 'package:rits_client/models/filter_groups/filter_groups.dart';

class FilterGroupsSelectionScreen extends StatefulWidget {
  final FilterGroup filterGroup;

  FilterGroupsSelectionScreen({
    Key key,
    @required this.filterGroup,
  })  : assert(filterGroup != null),
        super();

  @override
  State createState() => FilterGroupsSelectionScreenState();
}

class FilterGroupsSelectionScreenState
    extends State<FilterGroupsSelectionScreen> {
  FilterGroup get _filterGroup => widget.filterGroup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_filterGroup.name} - Select Filter'),
      ),
      body: Center(
        child: ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: _filterGroup.filters.length,
          itemBuilder: (context, index) {
            final filter = _filterGroup.filters[index];

            return InkWell(
              child: Semantics(
                button: true,
                value: filter.name,
                child: ListTile(
                  title: Text(filter.displayName),
                  onTap: () => Navigator.pop(context, filter),
                ),
                onTap: () => Navigator.pop(context, filter),
              ),
            );
          },
        ),
      ),
    );
  }
}
