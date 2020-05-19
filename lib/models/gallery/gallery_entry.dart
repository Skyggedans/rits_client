import 'package:equatable/equatable.dart';

class GalleryEntry extends Equatable {
  final String fileName;
  final String url;
  final int documentId;
  final bool isVideo;
  //final Uint8List bytes;

  GalleryEntry({this.fileName, this.url, this.documentId, this.isVideo})
      : super([fileName, url, documentId, isVideo]);

  factory GalleryEntry.fromJson(Map<String, dynamic> json) {
    return GalleryEntry(
      fileName: json['FileName'] as String,
      url: json['FileURL'] as String,
      isVideo: json['isVideo'] as bool,
    );
  }
}
