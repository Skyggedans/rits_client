import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:rits_client/models/gallery/gallery_entry.dart';

@immutable
abstract class ImageGalleryState extends Equatable {
  ImageGalleryState([List props = const []]) : super(props);
}

class ImageGalleryUninitialized extends ImageGalleryState {
  @override
  String toString() => 'ImageGalleryUninitialized';
}

class ImageGalleryLoaded extends ImageGalleryState {
  final List<GalleryEntry> entries;

  ImageGalleryLoaded({@required this.entries})
      : assert(entries != null),
        super([entries]);

  @override
  String toString() => 'ImageGalleryLoaded { entries: ${entries.length} }';
}

class ImageGalleryError extends ImageGalleryState {
  @override
  String toString() => 'ImageGalleryError';
}
