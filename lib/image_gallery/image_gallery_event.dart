import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ImageGalleryEvent extends Equatable {
  ImageGalleryEvent([List props = const []]) : super(props);
}

class FetchImages extends ImageGalleryEvent {
  @override
  String toString() => 'FetchImages';
}
