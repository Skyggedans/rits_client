class ViewObjectType {
  final String _value;
  final String _route;
  const ViewObjectType._internal(this._value, this._route);

  toString() => _value;
  toStringPlural() => '${_value}s';

  String get route => _route;

  static const Report = const ViewObjectType._internal('Report', '/report');
  static const Chart = const ViewObjectType._internal('Chart', '/chart');
  static const Kpi = const ViewObjectType._internal('KPI', 'kpi');
}
