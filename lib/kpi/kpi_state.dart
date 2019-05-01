import '../models/kpi/kpi.dart';
import '../view_object/view_object.dart';

class KpiGenerated extends ViewObjectState {
  final List<Kpi> kpis;

  KpiGenerated({this.kpis}) : super([kpis]);

  @override
  String toString() => 'KpiGenerated';
}
