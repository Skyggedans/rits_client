import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/kpi/kpi.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/utils/rest_client.dart';
import 'package:rits_client/view_object/view_object.dart';

import 'kpi.dart';

Card buildKpiCard(Kpi kpi) {
  var color = 'green';
  var direction = 'up';

  if (kpi.previousValue != null &&
      kpi.previousValue is Comparable &&
      kpi.value is Comparable) {
    if ((kpi.previousValue as Comparable).compareTo(kpi.value as Comparable) >
        0) {
      direction = 'down';
    } else if ((kpi.previousValue as Comparable)
            .compareTo(kpi.value as Comparable) <
        0) {
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

  final targetText =
      kpi.targetValue != null ? ', Target: ${kpi.targetValue}' : null;

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
      subtitle: kpi.value != null && kpi.value != ''
          ? Text('Value: ${kpi.value}' +
              (targetText != null ? targetText : '') +
              (userText1 != null ? userText1 : '') +
              (userText2 != null ? userText2 : ''))
          : null,
    ),
  );
}

class KpiScreen extends ViewObjectScreen {
  static String route = '/kpi';

  KpiScreen({
    Key key,
    @required ViewObject viewObject,
  })  : assert(viewObject != null),
        super(key: key, viewObject: viewObject);

  @override
  State createState() => _KpiScreenState();
}

class _KpiScreenState extends ViewObjectScreenState<KpiBloc, KpiGenerated> {
  @override
  KpiBloc createBloc() {
    return KpiBloc(
      restClient: Provider.of<RestClient>(context),
      appContext: Provider.of<AppContext>(context),
    );
  }

  @override
  Widget buildOutputWidget(BuildContext context, KpiGenerated state) {
    final kpis = state.kpis;

    if (kpis.isNotEmpty) {
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
