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

class PhotoTaken extends ProjectEvent {
  final Uint8List bytes;

  PhotoTaken(this.bytes) : super([bytes]);

  @override
  String toString() => 'PhotoTaken { size: ${bytes.length} bytes }';
}

class VideoRecorded extends ProjectEvent {
  final String filePath;

  VideoRecorded(this.filePath) : super([filePath]);

  @override
  String toString() => 'VideoRecorded { file: $filePath }';
}
