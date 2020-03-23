import 'package:equatable/equatable.dart';

class Filter extends Equatable {
  final String name;
  final String displayName;
  int level;
  final bool isSelected;

  Filter({
    this.name,
    this.displayName,
    this.level,
    this.isSelected,
  }) : super([
          name,
          displayName,
          isSelected,
        ]);

  factory Filter.fromJson(Map<String, dynamic> json) {
    final splittedName = (json['Title'] as String ?? '').split('/');
    final name = splittedName[splittedName.length - 1];
    final displayName = splittedName.join(' > ');

    return Filter(
      name: name,
      displayName: displayName,
      level: splittedName.length,
      isSelected: json['IsSelected'] as bool,
    );
  }

  Filter copyWith({
    bool isSelected,
  }) {
    return Filter(
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
