import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:rits_client/models/gallery/gallery_entry.dart';

@immutable
abstract class MediaGalleryState extends Equatable {
  MediaGalleryState([List props = const []]) : super(props);
}

class MediaGalleryUninitialized extends MediaGalleryState {
  @override
  String toString() => 'MediaGalleryUninitialized';
}

class MediaGalleryLoaded extends MediaGalleryState {
  final List<MediaEntry> entries;

  @protected
  final int version = Random().nextInt(1 << 32);

  MediaGalleryLoaded({@required this.entries})
      : assert(entries != null),
        super([entries]);

  @override
  bool operator ==(covariant MediaGalleryLoaded other) =>
      super == (other) && this.version == other.version;

  @override
  String toString() =>
      'MediaGalleryLoaded { entries: ${entries.length}, version: $version }';
}

class MediaGalleryError extends MediaGalleryState {
  @override
  String toString() => 'MediaGalleryError';
}
