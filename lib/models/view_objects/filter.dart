import 'package:equatable/equatable.dart';

class Filter extends Equatable {
  final String title;
  final bool state;

  Filter({this.title, this.state}) : super([title, state]);

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
      title: json['FilterTitle'],
      state: json['State'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FilterTitle': title,
      'State': state,
    };
  }

  Filter copyWith({
    bool state,
  }) {
    return Filter(
      title: title,
      state: state ?? this.state,
    );
  }
}
