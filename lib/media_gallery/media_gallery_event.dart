import 'package:equatable/equatable.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/models/gallery/gallery_entry.dart';
import 'package:rw_movie/rw_movie.dart';

@immutable
abstract class MediaGalleryEvent extends Equatable {
  MediaGalleryEvent([List props = const []]) : super(props);
}

class FetchMedia extends MediaGalleryEvent {
  @override
  String toString() => 'FetchImages';
}

class ProcessEntrySelection extends MediaGalleryEvent {
  final MediaEntry entry;

  ProcessEntrySelection({@required this.entry})
      : assert(entry != null),
        super([entry]);

  @override
  String toString() => 'ProcessEntrySelection { entry: $entry }';
}

class DownloadTaskStatusChanged extends MediaGalleryEvent {
  final String taskId;
  final DownloadTaskStatus status;
  final int progress;

  DownloadTaskStatusChanged({
    @required this.taskId,
    @required this.status,
    @required this.progress,
  })  : assert(taskId != null),
        assert(status != null),
        assert(progress != null),
        super([taskId, status, progress]);

  @override
  String toString() =>
      'DownloadTaskStatusChanged { taskId: $taskId, status: $status, progress: $progress }';
}

class YoutubeStreamsFetched extends MediaGalleryEvent {
  final MediaEntry entry;
  final List<YtFile> files;

  YoutubeStreamsFetched({
    @required this.entry,
    @required this.files,
  })  : assert(entry != null),
        assert(files != null),
        super([files]);

  @override
  String toString() =>
      'YoutubeStreamsFetched { entry: $entry, files: ${files.length} }';
}
