import '../models/view_objects/view_objects.dart';
import '../view_object/view_object.dart';

class ChartPresentation extends ViewObjectState {
  final ViewObject viewObject;
  final String url;
  final String userToken;

  ChartPresentation({this.viewObject, this.url, this.userToken})
      : super([viewObject, url, userToken]);

  @override
  String toString() => 'ChartGenerated';
}
