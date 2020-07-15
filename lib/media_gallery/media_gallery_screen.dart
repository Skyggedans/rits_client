import 'dart:isolate';
import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_config.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/gallery/gallery_entry.dart';
import 'package:rits_client/utils/rest_client.dart';
import 'package:rw_help/rw_help.dart';

import 'media_gallery.dart';

class MediaGalleryScreen extends StatefulWidget {
  @override
  State createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends State {
  ReceivePort _port = ReceivePort();
  MediaGalleryBloc _bloc;
  bool isRealWearDevice;

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      _bloc.add(DownloadTaskStatusChanged(
        taskId: data[0] as String,
        status: data[1] as DownloadTaskStatus,
        progress: data[2] as int,
      ));
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_bloc == null) {
      isRealWearDevice = Provider.of<AppConfig>(context).isRealWearDevice;

      if (isRealWearDevice) {
        RwHelp.setCommands(['Select image N']);
      }

      _bloc = MediaGalleryBloc(
        restClient: Provider.of<RestClient>(context),
        appContext: Provider.of<AppContext>(context),
      )..add(FetchMedia());
    }
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');

    if (isRealWearDevice) {
      RwHelp.setCommands([]);
    }

    _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Gallery'),
      ),
      body: Center(
        child: BlocBuilder(
          bloc: _bloc,
          builder: (context, MediaGalleryState state) {
            if (state is MediaGalleryUninitialized) {
              return CircularProgressIndicator();
            } else if (state is MediaGalleryLoaded) {
              return Padding(
                padding: EdgeInsets.all(5),
                child: GridView.builder(
                  itemCount: state.entries.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 140,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                  ),
                  itemBuilder: (context, index) {
                    final entry = state.entries[index];

                    final getBadgeContent = () {
                      switch (entry.status) {
                        case MediaEntryStatus.online:
                          {
                            return const Icon(Icons.save_alt);
                          }
                        case MediaEntryStatus.fetching_real_url:
                          {
                            return const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ));
                          }
                        case MediaEntryStatus.download_in_progress:
                          {
                            return SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  value: entry.progress / 100,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ));
                          }
                        case MediaEntryStatus.offline:
                          {
                            return const Icon(Icons.offline_pin);
                          }
                      }

                      return const SizedBox.shrink();
                    };

                    return InkWell(
                      child: Semantics(
                        button: true,
                        value:
                            'hf_commands:Select Image ${index + 1}|hf_show_text|hf_persists',
                        child: entry.isVideo
                            ? Badge(
                                badgeContent: getBadgeContent(),
                                position: BadgePosition.bottomRight(
                                  bottom: 20,
                                  right: 5,
                                ),
                                badgeColor: Colors.transparent,
                                child: Container(
                                  width: 140,
                                  height: 105,
                                  color: Colors.black,
                                  // child: Column(
                                  //   mainAxisAlignment: MainAxisAlignment.end,
                                  //   children: [
                                  //     Container(

                                  //constraints: BoxConstraints.expand(),
                                  child: Icon(entry.isYoutube
                                      ? FontAwesomeIcons.youtube
                                      : Icons.video_library),
                                ),
                                //       LinearProgressIndicator(
                                //           value: entry.progress / 100),
                                //     ],
                                //   ),
                                // ),
                              )
                            : Image.network(
                                entry.url,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress?.cumulativeBytesLoaded !=
                                      loadingProgress?.expectedTotalBytes) {
                                    return Center(
                                      child: const CircularProgressIndicator(),
                                    );
                                  }

                                  return child;
                                },
                              ),
                        onTap: () =>
                            _bloc.add(ProcessEntrySelection(entry: entry)),
                        // onTap: () async {
                        //   if (entry.isVideo) {
                        //     await RwMovie.playYoutube(entry.url);
                        //   } else {
                        //     await Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => ImageScreen(
                        //           images: state.entries
                        //               .map((entry) => entry.url)
                        //               .toList(),
                        //           index: index,
                        //         ),
                        //       ),
                        //     );
                        //   }
                        // },
                      ),
                      onTap: () =>
                          _bloc.add(ProcessEntrySelection(entry: entry)),
                      // onTap: () async {
                      //   if (entry.isVideo) {
                      //     await RwMovie.playYoutube(entry.url);
                      //   } else {
                      //     await Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => ImageScreen(
                      //           images: state.entries
                      //               .map((entry) => entry.url)
                      //               .toList(),
                      //           index: index,
                      //         ),
                      //       ),
                      //     );
                      //   }
                      // },
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
