import 'package:flutter/foundation.dart';
import 'package:rits_client/models/projects/project.dart';

class AppContext extends ChangeNotifier {
  Project _project;
  String _userToken;
  String _sessionContext;
  String _sessionContextName;

  Project get project => _project;
  String get userToken => _userToken;
  String get sessionContext => _sessionContext;
  String get sessionContextName => _sessionContextName;

  set project(Project value) {
    _project = value;
    notifyListeners();
  }

  set userToken(String value) {
    _userToken = value;
    notifyListeners();
  }

  set sessionContext(String value) {
    _sessionContext = value;
    notifyListeners();
  }

  set sessionContextName(String value) {
    _sessionContextName = value;
    notifyListeners();
  }
}
