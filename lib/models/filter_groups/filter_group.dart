import 'package:equatable/equatable.dart';
import 'filter_groups.dart';

class FilterGroup extends Equatable {
  final int id;
  final String name;
  final int levelNumber;
  final bool isActive;
  final List<Filter> filters;

  FilterGroup({
    this.id,
    this.name,
    this.levelNumber,
    this.isActive: false,
    this.filters,
  })  : assert(id != null),
        assert(name != null),
        assert(levelNumber != null),
        assert(isActive != null),
        assert(filters != null),
        super([id, name, levelNumber, filters]);

  factory FilterGroup.fromJson(Map<String, dynamic> json) {
    return FilterGroup(
      id: int.tryParse(json['FilterGroupID'] as String),
      name: json['GroupName'] as String,
      levelNumber: int.tryParse(json['LevelNumber'] as String),
      filters: List<Map<String, dynamic>>.from(json['Filter'] as List)
          .map((filterJson) {
        return Filter.fromJson(filterJson);
      }).toList(),
    );
  }

  FilterGroup copyWith({
    bool isActive,
  }) {
    return FilterGroup(
      id: this.id,
      name: this.name,
      levelNumber: this.levelNumber,
      isActive: isActive ?? this.isActive,
      filters: this.filters,
    );
  }
}
