import 'dart:convert';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/gallery/gallery_entry.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/rest_client.dart';
import 'package:rw_movie/rw_movie.dart';

import 'media_gallery.dart';

class MediaGalleryBloc extends Bloc<MediaGalleryEvent, MediaGalleryState> {
  final RestClient restClient;
  final AppContext appContext;

  MediaGalleryBloc({
    @required this.restClient,
    @required this.appContext,
  })  : assert(restClient != null),
        assert(appContext != null),
        super();

  MediaGalleryState get initialState => MediaGalleryUninitialized();

  @override
  Stream<MediaGalleryState> mapEventToState(MediaGalleryEvent event) async* {
    final currentState = state;

    if (event is FetchMedia) {
      try {
        final entries = await _fetchGalleryEntries();

        yield MediaGalleryLoaded(entries: entries
            /*.where((entry) =>
                    entry.fileName == 'TearsOfSteel.mp4' ||
                    entry.fileName == 'Tears of Steel')
                .toList()*/
            );
      } on ApiError {
        yield MediaGalleryError();
      }
    } else if (event is ProcessEntrySelection &&
        currentState is MediaGalleryLoaded) {
      if (event.entry.status == MediaEntryStatus.offline) {
        AndroidIntent intent = AndroidIntent(
          action: 'action_view',
          data: Uri.encodeFull('file://' + event.entry.localFileName),
          flags: [0x10000000, 0x00000001],
          //type: 'video/mp4',
        );

        await intent.launch();
      } else {
        final directory = await getExternalStorageDirectory();
        final saveDirPath = join(directory.path, 'Documents', 'AdvisoryStudio',
            appContext.sessionContext);

        if (FileSystemEntity.typeSync(saveDirPath) ==
            FileSystemEntityType.notFound) {
          await Directory(saveDirPath).create(recursive: true);
        }

        final downloadTaskId = await FlutterDownloader.enqueue(
          url: event.entry.url,
          fileName:
              event.entry.isYoutube ? event.entry.fileName + '.mp4' : null,
          savedDir: saveDirPath,
          showNotification: true,
          openFileFromNotification: true,
        );

        final entries = currentState.entries;
        final entryIdx = entries.indexOf(event.entry);

        entries.replaceRange(entryIdx, entryIdx + 1, [
          event.entry.copyWith(
            downloadTaskId: downloadTaskId,
            status: MediaEntryStatus.download_in_progress,
          )
        ]);

        yield MediaGalleryLoaded(entries: entries);
      }
    } else if (event is DownloadTaskStatusChanged &&
        currentState is MediaGalleryLoaded) {
      final entries = currentState.entries;
      final runningEntry = entries.firstWhere(
          (entry) => entry.downloadTaskId == event.taskId,
          orElse: () => null);

      if (runningEntry != null && event.status == DownloadTaskStatus.complete) {
        final entryIdx = entries.indexOf(runningEntry);

        entries.replaceRange(entryIdx, entryIdx + 1,
            [runningEntry.copyWith(status: MediaEntryStatus.offline)]);

        yield MediaGalleryLoaded(entries: entries);
      }
    } else if (event is YoutubeStreamsFetched &&
        currentState is MediaGalleryLoaded) {
      final entries = currentState.entries;
      final entryIdx = entries.indexOf(event.entry);
      var maxHeight = 0;
      var url = '';

      event.files.forEach((file) {
        if (file.ext == 'mp4' && file.height > maxHeight) {
          maxHeight = file.height;
          url = file.url;
        }
      });

      if (url.isNotEmpty) {
        entries.replaceRange(entryIdx, entryIdx + 1, [
          event.entry.copyWith(
            url: url,
            status: MediaEntryStatus.online,
          )
        ]);

        yield MediaGalleryLoaded(entries: entries);
      }
    }
  }

  Future<List<MediaEntry>> _fetchGalleryEntries() async {
    final url =
        '${settings.backendUrl}/GetGalleryFileList/${appContext.userToken}/False/${appContext.sessionContextName}';

    final response = await restClient.get(url);

    final body = List<Map<String, dynamic>>.from(
            json.decode(response.body)['FilesList'] as List)
        .where(
            (entryJson) => (entryJson['FileURL'] as String).startsWith('http'));

    final directory = await getExternalStorageDirectory();

    final dirPath = join(directory.path, 'Documents', 'AdvisoryStudio',
        appContext.sessionContext);

    final downloadTasks = await FlutterDownloader.loadTasks();

    return body.map((entryJson) {
      var entry = MediaEntry.fromJson(entryJson);

      final completeDownloadTask = downloadTasks.firstWhere(
          (task) =>
              task.url == entry.url &&
              task.status == DownloadTaskStatus.complete,
          orElse: () => null);

      final runningDownloadTask = downloadTasks.firstWhere(
          (task) =>
              task.url == entry.url &&
              task.status == DownloadTaskStatus.running,
          orElse: () => null);

      if (completeDownloadTask != null &&
          FileSystemEntity.typeSync(
                  join(dirPath, completeDownloadTask.filename)) ==
              FileSystemEntityType.file) {
        entry = entry.copyWith(
          fileName: completeDownloadTask.filename,
          localFileName: join(dirPath, completeDownloadTask.filename),
          downloadTaskId: completeDownloadTask.taskId,
          status: MediaEntryStatus.offline,
        );
      } else if (runningDownloadTask != null) {
        entry = entry.copyWith(
          fileName: runningDownloadTask.filename,
          downloadTaskId: runningDownloadTask.taskId,
          status: MediaEntryStatus.download_in_progress,
        );
      } else if (entry.isVideo && entry.isYoutube) {
        entry = entry.copyWith(
          status: MediaEntryStatus.fetching_real_url,
        );

        RwMovie.getYoutubeStreams(entry.url).then((files) {
          add(YoutubeStreamsFetched(
            entry: entry,
            files: files,
          ));
        });
      }

      return entry;
    }).toList();
  }
}
