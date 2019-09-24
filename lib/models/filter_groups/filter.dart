import 'package:equatable/equatable.dart';

class Filter extends Equatable {
  final String title;
  final bool isSelected;

  Filter({
    this.title,
    this.isSelected,
  }) : super([
          title,
          isSelected,
        ]);

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
      title: json['Title'],
      isSelected: json['IsSelected'],
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
