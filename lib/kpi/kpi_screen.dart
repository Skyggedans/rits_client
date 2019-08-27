import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../models/view_objects/view_objects.dart';
import '../models/kpi/kpi.dart';
import '../view_object/view_object.dart';
import 'kpi.dart';

Card buildKpiCard(Kpi kpi) {
  var color = 'green';
  var direction = 'up';

  if (kpi.previousValue != null) {
    if (kpi.previousValue > kpi.value) {
      direction = 'down';
    } else if (kpi.previousValue == kpi.value) {
      direction = 'neutral';
    }
  }

  if (kpi.indicator != null) {
    if (kpi.indicator == 0) {
      color = 'red';
    } else if (kpi.indicator == 1) {
      color = 'green';
    } else {
      color = 'yellow';
    }
  }

  final targetText = kpi.targetValue != null && kpi.targetValue > 0
      ? ', Target: ${kpi.targetValue}'
      : null;

  final userText1 =
      kpi.userText1 != null ? '\n${kpi.userText1}: ${kpi.extraData1}' : null;

  final userText2 =
      kpi.userText2 != null ? '\n${kpi.userText2}: ${kpi.extraData2}' : null;

  return Card(
    child: ListTile(
      trailing: Image(
        image: AssetImage('assets/${color}_$direction.png'),
        width: 90,
        height: 90,
      ),
      title: Text(kpi.name),
      subtitle: Text('Value: ${kpi.value}' +
          (targetText != null ? targetText : '') +
          (userText1 != null ? userText1 : '') +
          (userText2 != null ? userText2 : '')),
    ),
  );
}

class KpiScreen extends ViewObjectScreen {
  static String route = '/kpi';

  KpiScreen({
    Key key,
    @required ViewObject viewObject,
  }) : super(
          key: key,
          viewObject: viewObject,
        );

  @override
  State createState() => _KpiScreenState();
}

class _KpiScreenState extends ViewObjectScreenState<KpiBloc, KpiGenerated> {
  KpiBloc viewObjectBloc = KpiBloc();

  @override
  Widget buildOutputWidget(BuildContext context, KpiGenerated state) {
    final kpis = state.kpis;

    if (kpis.length > 0) {
      return ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: kpis.length,
        itemBuilder: (context, index) {
          return buildKpiCard(kpis[index]);
        },
      );
    } else {
      return const Text('No data');
    }
  }
}
