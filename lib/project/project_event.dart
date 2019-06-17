import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../models/projects/projects.dart';

@immutable
abstract class ProjectEvent extends Equatable {
  ProjectEvent([List props = const []]) : super(props);
}

class LoadProject extends ProjectEvent {
  final Project project;

  LoadProject(this.project) : super([project]);

  @override
  String toString() => 'LoadProject { project: ${project.name} }';
}

class ScanBarcode extends ProjectEvent {
  final String userToken;

  ScanBarcode({@required this.userToken}) : super([userToken]);

  @override
  String toString() => 'ScanBarcode';
}

class PhotoTaken extends ProjectEvent {
  final Uint8List bytes;
  final String userToken;

  PhotoTaken(this.bytes, this.userToken) : super([bytes, userToken]);

  @override
  String toString() => 'PhotoTaken { size: ${bytes.length} bytes }';
}

class VideoRecorded extends ProjectEvent {
  final String filePath;
  final String userToken;

  VideoRecorded(this.filePath, this.userToken) : super([filePath, userToken]);

  @override
  String toString() => 'VideoRecorded { file: $filePath }';
}
