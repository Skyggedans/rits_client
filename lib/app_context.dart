import 'package:flutter/foundation.dart';
import 'package:rits_client/models/projects/project.dart';
import 'package:rits_client/settings.dart' as settings;

class AppContext extends ChangeNotifier {
  Project _project;
  String _userToken;
  Map<String, dynamic> _sessionContext;

  Project get project => _project;
  String get userToken => _userToken;
  Map<String, dynamic> get sessionContext => _sessionContext;

  String get breadCrumbs => [
        project.name,
        ...(sessionContext != null
            ? settings.breadcrumbsKeys.map((key) => sessionContext[key])
            : [])
      ].join(' > ');

  String get observedItem => sessionContext != null
      ? sessionContext[settings.observedItemKey] as String
      : '';

  String get hierarchyParam => sessionContext != null
      ? sessionContext[settings.hierarchyParam] as String
      : null;

  bool get hasSessionContext => sessionContext != null;

  set project(Project value) {
    _project = value;
    notifyListeners();
  }

  set userToken(String value) {
    _userToken = value;
    notifyListeners();
  }

  set sessionContext(Map<String, dynamic> value) {
    _sessionContext = value;
    notifyListeners();
  }
}
