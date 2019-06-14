import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../models/projects/projects.dart';
import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import 'project.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final RestClient restClient;

  ProjectBloc({@required this.restClient});

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
    } else if (event is PhotoTaken) {
      yield ProjectLoading();
      await _postPhoto(event.bytes);
      yield prevState;
    } else if (event is VideoRecorded) {
      yield ProjectLoading();
      await _postVideo(event.filePath);
      yield prevState;
    }
  }

  Future<String> _getUserTokenForProject(Project project) async {
    const userId = 'default-user';
    const skypeId = 'User';
    final url =
        '${settings.backendUrl}/StartSkypeSession/$skypeId/$userId/${Uri.encodeFull(project.name)}';
    final response = await restClient.get(url);

    return json.decode(response.body);
  }

  Future<void> _postPhoto(bytes) async {
    final url = 'https://109.86.209.81:44312/api/upload';
    final fileName =
        'IMG_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.png';

    await restClient.uploadFile(
      url,
      bytes: bytes,
      field: 'photo',
      fileName: fileName,
      contentType: MediaType('image', 'png'),
    );
  }

  Future<void> _postVideo(filePath) async {
    final url = 'https://109.86.209.81:44312/api/upload';

    await restClient.uploadFile(
      url,
      field: 'movie',
      filePath: filePath,
      contentType: MediaType('video', 'mp4'),
    );
  }
}
