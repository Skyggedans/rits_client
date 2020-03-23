import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class MyFavoritesEvent extends Equatable {
  MyFavoritesEvent([List props = const []]) : super(props);
}
