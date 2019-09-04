import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/view_object/view_object.dart';

class ChartPresentation extends ViewObjectState {
  final ViewObject viewObject;
  final String url;

  ChartPresentation({
    this.viewObject,
    this.url,
  })  : assert(viewObject != null),
        assert(url != null),
        super([
          viewObject,
          url,
        ]);

  @override
  String toString() => 'ChartPresentation';
}
