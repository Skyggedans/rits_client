import 'package:equatable/equatable.dart';

enum MediaEntryStatus {
  online,
  fetching_real_url,
  download_in_progress,
  offline,
}

class MediaEntry extends Equatable {
  final String fileName;
  final String localFileName;
  final String url;
  final int documentId;
  final bool isVideo;
  final bool isYoutube;
  final String downloadTaskId;
  final String mimeType;
  final MediaEntryStatus status;
  final int progress;
  //final Uint8List bytes;

  MediaEntry({
    this.fileName,
    this.localFileName,
    this.url,
    this.documentId,
    this.isVideo,
    this.isYoutube,
    this.downloadTaskId,
    this.mimeType,
    this.status = MediaEntryStatus.online,
    this.progress = 0,
  }) : super([
          fileName,
          localFileName,
          url,
          documentId,
          isVideo,
          isYoutube,
          downloadTaskId,
          mimeType,
          status,
          progress,
        ]);

  factory MediaEntry.fromJson(Map<String, dynamic> json) {
    final uri = Uri.parse(json['FileURL'] as String);

    return MediaEntry(
      fileName: json['FileName'] as String,
      url: json['FileURL'] as String,
      isVideo: json['isVideo'] as bool,
      isYoutube:
          uri.host.contains('youtube.com') || uri.host.contains('youtu.be'),
    );
  }

  MediaEntry copyWith({
    String fileName,
    String localFileName,
    String url,
    String downloadTaskId,
    String mimeType,
    MediaEntryStatus status,
    int progress,
  }) {
    return MediaEntry(
      fileName: fileName ?? this.fileName,
      localFileName: localFileName ?? this.localFileName,
      url: url ?? this.url,
      documentId: this.documentId,
      isVideo: this.isVideo,
      isYoutube: this.isYoutube,
      downloadTaskId: downloadTaskId ?? this.downloadTaskId,
      mimeType: mimeType ?? this.mimeType,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }
}
