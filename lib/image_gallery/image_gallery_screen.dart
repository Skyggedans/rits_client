import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_config.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/utils/rest_client.dart';
import 'package:rw_help/rw_help.dart';
import 'package:rw_movie/rw_movie.dart';

import 'image_gallery.dart';

class ImageGalleryScreen extends StatefulWidget {
  @override
  State createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State {
  ImageGalleryBloc _bloc;
  bool isRealWearDevice;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_bloc == null) {
      isRealWearDevice = Provider.of<AppConfig>(context).isRealWearDevice;

      if (isRealWearDevice) {
        RwHelp.setCommands(['Select image N']);
      }

      _bloc = ImageGalleryBloc(
        restClient: Provider.of<RestClient>(context),
        appContext: Provider.of<AppContext>(context),
      )..add(FetchImages());
    }
  }

  @override
  void dispose() {
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
        title: const Text('Image Gallery'),
      ),
      body: Center(
        child: BlocBuilder(
          bloc: _bloc,
          builder: (context, ImageGalleryState state) {
            if (state is ImageGalleryUninitialized) {
              return CircularProgressIndicator();
            } else if (state is ImageGalleryLoaded) {
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

                    return InkWell(
                      child: Semantics(
                        button: true,
                        value:
                            'hf_commands:Select Image ${index + 1}|hf_show_text|hf_persists',
                        child: entry.isVideo
                            ? Container(
                                width: 140,
                                height: 105,
                                color: Colors.black,
                                child: Icon(Icons.video_library),
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
                        onTap: () async {
                          if (entry.isVideo) {
                            RwMovie.playYoutube(entry.url);
                          } else {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageScreen(
                                  images: state.entries
                                      .map((entry) => entry.url)
                                      .toList(),
                                  index: index,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      onTap: () async {
                        if (entry.isVideo) {
                          RwMovie.playYoutube(entry.url);
                        } else {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageScreen(
                                images: state.entries
                                    .map((entry) => entry.url)
                                    .toList(),
                                index: index,
                              ),
                            ),
                          );
                        }
                      },
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
