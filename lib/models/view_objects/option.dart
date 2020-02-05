import 'package:equatable/equatable.dart';

class Option extends Equatable {
  final String title;
  final bool state;

  Option({this.title, this.state}) : super([title, state]);

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      title: json['FilterTitle'] as String,
      state: json['State'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FilterTitle': title,
      'State': state,
    };
  }

  Option copyWith({
    bool state,
  }) {
    return Option(
      title: title,
      state: state ?? this.state,
    );
  }
}
