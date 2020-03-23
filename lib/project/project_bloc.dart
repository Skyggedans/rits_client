import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http_parser/http_parser.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/filter_groups/filter.dart';
import 'package:rits_client/models/projects/projects.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/rest_client.dart';
import 'package:rw_barcode_reader/rw_barcode_reader.dart';
import 'package:rw_camera/rw_camera.dart';
import 'package:rxdart/rxdart.dart';

import 'project.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final RestClient restClient;
  final AppContext appContext;

  ProjectBloc({
    @required this.restClient,
    @required this.appContext,
  })  : assert(restClient != null),
        assert(appContext != null),
        super();

  @override
  get initialState => ProjectLoading();

  @override
  Stream<ProjectState> transformStates(Stream<ProjectState> states) {
    return states.debounceTime(Duration(milliseconds: 50));
  }

  @override
  Stream<ProjectState> mapEventToState(ProjectEvent event) async* {
    final prevState = state;

    if (event is LoadProject) {
      try {
        appContext.userToken =
            await _getUserTokenForProject(appContext.project);

        yield ProjectLoaded();
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
              decodedResult['ritsData']['itemId'] as String);

          if (levelName != null) {
            appContext.sessionContext =
                decodedResult['ritsData']['itemId'] as String;
            appContext.sessionContextName = levelName;

            yield ProjectLoaded();
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
        final levelName = await _setContextFromBarCode(event.sessionContext);

        if (levelName != null) {
          appContext.sessionContext = event.sessionContext;
          appContext.sessionContextName = levelName;

          yield ProjectLoaded();
        } else {
          yield ProjectError(message: 'Unable to set context');
        }
      } on ApiError {
        yield ProjectError(
            message: 'Unrecognized context: ${event.sessionContext}');
      }
    } else if (event is SetContextFromSearch) {
      yield ProjectLoading();

      try {
        final levelName = await _setContextFromSearch(event.sessionContext);

        if (levelName != null) {
          appContext.sessionContext = event.sessionContext;
          appContext.sessionContextName = levelName;

          yield ProjectLoaded();
        } else {
          yield ProjectError(message: 'Unable to set context');
        }
      } on ApiError {
        yield ProjectError(
            message: 'Unrecognized context: ${event.sessionContext}');
      }
    } else if (event is SetContextFromFilter) {
      yield ProjectLoading();

      try {
        final levelName = await _setContextFromFilter(event.filter);

        if (levelName != null) {
          appContext.sessionContext = event.filter.name;
          appContext.sessionContextName = event.filter.displayName;

          yield ProjectLoaded();
        } else {
          yield ProjectError(message: 'Unable to set context');
        }
      } on ApiError {
        yield ProjectError(
            message: 'Unrecognized context: ${event.filter.name}');
      }
    } else if (event is TakePhoto) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);

      if (permission != PermissionStatus.granted) {
        final permissions = await PermissionHandler()
            .requestPermissions([PermissionGroup.storage]);

        if (permissions[PermissionGroup.storage] != PermissionStatus.granted) {
          return;
        }
      }

      final filePath = await RwCamera.takePhotoToFile();

      if (filePath != null) {
        yield ProjectLoading();

        try {
          await _postPhoto(filePath);
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
          await _postVideo(filePath);
          yield prevState;
        } on ApiError {
          yield ProjectError(message: 'Unable to save video');
        }
      }
    }
  }

  Future<String> _getUserTokenForProject(Project project) async {
    final url =
        '${settings.backendUrl}/StartWearableSession/${Uri.encodeFull(project.name)}';
    final response = await restClient.get(url);

    return json.decode(response.body) as String;
  }

  Future<String> _setContextFromBarCode(String contextId) async {
    final url =
        '${settings.backendUrl}/SetContextFromBarCode/${appContext.userToken}/${Uri.encodeFull(contextId)}';
    final response = await restClient.get(url);

    return json.decode(response.body) as String;
  }

  Future<String> _setContextFromSearch(String context) async {
    final url =
        '${settings.backendUrl}/SetObservedItemContext/${appContext.userToken}/${Uri.encodeFull(context)}';
    final response = await restClient.get(url);
    final body = json.decode(response.body);

    return body['ResultData'] as String;
  }

  Future<String> _setContextFromFilter(Filter filter) async {
    final url =
        '${settings.backendUrl}/SetObservedItemContext/${appContext.userToken}/${Uri.encodeFull(filter.name)}';
    final response = await restClient.get(url);
    final body = json.decode(response.body);

    return body['ResultData'] as String;
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    print(error);
  }

  Future<void> _postPhoto(String filePath) async {
    final url = '${settings.backendUrl}/uploadFile/${appContext.userToken}';

    await restClient.uploadFile(
      url,
      field: 'photo',
      filePath: filePath,
      contentType: MediaType('video', 'png'),
    );
  }

  Future<void> _postVideo(String filePath) async {
    final url = '${settings.backendUrl}/uploadFile/${appContext.userToken}';

    await restClient.uploadFile(
      url,
      field: 'movie',
      filePath: filePath,
      contentType: MediaType('video', 'mp4'),
    );
  }
}
