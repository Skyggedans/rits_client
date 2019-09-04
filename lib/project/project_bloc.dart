import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rits_client/locator.dart';
import 'package:rits_client/models/projects/projects.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/utils.dart';
import 'package:rw_barcode_reader/rw_barcode_reader.dart';
import 'package:rw_camera/rw_camera.dart';
import 'package:rxdart/rxdart.dart';

import 'project.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final _restClient = locator<RestClient>();

  @override
  get initialState => ProjectLoading();

  @override
  Stream<ProjectEvent> transform(Stream<ProjectEvent> events) {
    return (events as Observable<ProjectEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  Stream<ProjectState> mapEventToState(ProjectEvent event) async* {
    final prevState = currentState;

    if (event is LoadProject) {
      try {
        final userToken = await _getUserTokenForProject(event.project);

        yield ProjectLoaded(userToken: userToken);
      } on ApiError {
        yield ProjectError();
      }
    } else if (event is ScanBarcode) {
      final String result = await RwBarcodeReader.scanBarcode();

      if (result != null) {
        yield ProjectLoading();

        try {
          dynamic decodedResult = json.decode(result);
          final levelName = await _setContextFromBarCode(
              decodedResult['ritsData']['itemId'], event.userToken);

          if (levelName != null) {
            yield ProjectLoaded(
              hierarchyLevel: levelName,
              context: decodedResult['ritsData']['itemId'],
              userToken: event.userToken,
            );
          } else {
            yield ProjectError(message: 'Unable to set context');
          }
        } on ApiError {
          yield ProjectError(message: 'Unrecognized bar code content: $result');
        }
      }
    } else if (event is SetContextFromBarCode) {
      yield ProjectLoading();

      try {
        final levelName =
            await _setContextFromBarCode(event.context, event.userToken);

        if (levelName != null) {
          yield ProjectLoaded(
            hierarchyLevel: levelName,
            context: event.context,
            userToken: event.userToken,
          );
        } else {
          yield ProjectError(message: 'Unable to set context');
        }
      } on ApiError {
        yield ProjectError(message: 'Unrecognized context: ${event.context}');
      }
    } else if (event is SetContextFromSearch) {
      yield ProjectLoading();

      try {
        final levelName =
            await _setContextFromSearch(event.context, event.userToken);

        if (levelName != null) {
          yield ProjectLoaded(
            hierarchyLevel: levelName,
            context: event.context,
            userToken: event.userToken,
          );
        } else {
          yield ProjectError(message: 'Unable to set context');
        }
      } on ApiError {
        yield ProjectError(message: 'Unrecognized context: ${event.context}');
      }
    } else if (event is TakePhoto) {
      final bytes = await RwCamera.takePhoto();

      if (bytes != null) {
        yield ProjectLoading();

        try {
          await _postPhoto(bytes, event.userToken);
          yield prevState;
        } on ApiError {
          yield ProjectError(message: 'Unable to save photo');
        }
      }
    } else if (event is RecordVideo) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);

      if (permission != PermissionStatus.granted) {
        final permissions = await PermissionHandler()
            .requestPermissions([PermissionGroup.storage]);

        if (permissions[PermissionGroup.storage] != PermissionStatus.granted) {
          return;
        }
      }

      final filePath = await RwCamera.recordVideo();

      if (filePath != null) {
        yield ProjectLoading();

        try {
          await _postVideo(filePath, event.userToken);
          yield prevState;
        } on ApiError {
          yield ProjectError(message: 'Unable to save video');
        }
      }
    }
  }

  Future<String> _getUserTokenForProject(Project project) async {
    const userId = 'default-user';
    const skypeId = 'User';
    final url =
        '${settings.backendUrl}/StartSkypeSession/$skypeId/$userId/${Uri.encodeFull(project.name)}';
    final response = await _restClient.get(url);

    return json.decode(response.body);
  }

  Future<String> _setContextFromBarCode(
      String contextId, String userToken) async {
    final url =
        '${settings.backendUrl}/SetContextFromBarCode/$userToken/${Uri.encodeFull(contextId)}';
    final response = await _restClient.get(url);

    return json.decode(response.body);
  }

  Future<String> _setContextFromSearch(String context, String userToken) async {
    final url =
        '${settings.backendUrl}/SetObservedItemContext/$userToken/${Uri.encodeFull(context)}';
    final response = await _restClient.get(url);
    final body = json.decode(response.body);

    return body['ResultData'];
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    print(error);
  }

  Future<void> _postPhoto(Uint8List bytes, String userToken) async {
    final url = '${settings.backendUrl}/uploadFile/$userToken';
    final fileName =
        'IMG_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.png';

    await _restClient.uploadFile(
      url,
      bytes: bytes,
      field: 'photo',
      fileName: fileName,
      contentType: MediaType('image', 'png'),
    );
  }

  Future<void> _postVideo(filePath, String userToken) async {
    final url = '${settings.backendUrl}/uploadFile/$userToken';

    await _restClient.uploadFile(
      url,
      field: 'movie',
      filePath: filePath,
      contentType: MediaType('video', 'mp4'),
    );
  }
}
