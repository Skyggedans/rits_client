import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rw_speech_recognizer/rw_speech_recognizer.dart';

class ImageScreen extends StatefulWidget {
  final List<String> images;
  final int index;

  ImageScreen({
    @required this.images,
    @required this.index,
  })  : assert(images != null),
        assert(index != null),
        super();

  @override
  State createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  PageController _pageController;

  List<String> get _images => widget.images;
  int get _index => widget.index;

  @override
  void initState() {
    super.initState();

    RwSpeechRecognizer.setCommands([
      'Previous Image',
      'Next Image',
      'Back',
    ], (command) {
      switch (command) {
        case 'Previous Image':
          {
            if (_pageController.hasClients && _pageController.page > 0) {
              _pageController.animateToPage(
                _pageController.page.toInt() - 1,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }

            break;
          }
        case 'Next Image':
          {
            if (_pageController.hasClients &&
                _pageController.page < _images.length - 1) {
              _pageController.animateToPage(
                _pageController.page.toInt() + 1,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }

            break;
          }
        case 'Back':
          {
            Navigator.pop(context);
          }
      }
    });

    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    RwSpeechRecognizer.restoreCommands();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      pageSnapping: true,
      itemCount: _images.length,
      itemBuilder: (context, index) {
        return Image.network(
          _images[index],
          loadingBuilder: (
            context,
            child,
            ImageChunkEvent loadingProgress,
          ) {
            if (loadingProgress?.cumulativeBytesLoaded !=
                loadingProgress?.expectedTotalBytes) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return child;
          },
        );
      },
    );
  }
}
