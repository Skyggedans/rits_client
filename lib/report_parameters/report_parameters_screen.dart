import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/rest_client.dart';
import '../models/reports/reports.dart';
import '../models/report_parameters/report_parameters.dart';
import '../widgets/widgets.dart';
import 'selection/selection.dart';
import 'report_parameters.dart';

class ReportParametersScreen extends StatefulWidget {
  final Report report;
  final String userToken;

  ReportParametersScreen(
      {Key key, @required this.report, @required this.userToken})
      : super(key: key);

  @override
  State createState() => _ReportParametersScreenState();
}

class _ReportParametersScreenState extends State<ReportParametersScreen> {
  final ReportParametersBloc _projectsBloc =
      ReportParametersBloc(restClient: RestClient());

  Report get _report => widget.report;

  String get _userToken => widget.userToken;

  @override
  void initState() {
    super.initState();
    _projectsBloc.dispatch(FetchReportParameters(
      report: _report,
      userToken: _userToken,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Parameters'),
      ),
      body: Center(
        child: BlocBuilder(
          bloc: _projectsBloc,
          builder: (BuildContext context, ReportParametersState state) {
            if (state is ReportParametersInProgress) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is ReportParametersLoaded) {
              return BlocProvider(
                bloc: _projectsBloc,
                child: _ReportParameters(),
              );
            } else if (state is ReportParametersError) {
              return Center(
                child: Text('Failed to fetch or save report parameters'),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _projectsBloc.dispose();
    super.dispose();
  }
}

class _ReportParameters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _reportParametersBloc =
        BlocProvider.of<ReportParametersBloc>(context);

    return BlocBuilder(
      bloc: _reportParametersBloc,
      builder: (BuildContext context, ReportParametersState state) {
        final concreteState = (state as ReportParametersLoaded);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: concreteState.parameters.map((param) {
            if (param.selectionMode == 'none') {
              switch (param.dataType) {
                case 'datetime':
                  {
                    return DateTimePicker(
                      labelText: param.title,
                      helperText: param.title,
                      selectedDate: param.value,
                      selectDate: (value) {
                        _reportParametersBloc.dispatch(SaveReportParameter(
                          report: concreteState.report,
                          userToken: concreteState.userToken,
                          parameter: param.copyWith(value: value),
                        ));
                      },
                    );
                  }
                default:
                  {
                    final textField = TextFormField(
                      initialValue: param.value.toString(),
                      keyboardType: param.dataType == 'numeric'
                          ? TextInputType.number
                          : TextInputType.text,
                      enabled: !param.readOnly,
                      decoration: InputDecoration(
                        labelText: param.title,
                        helperText: param.title,
                        helperStyle: TextStyle(
                          fontSize: 1,
                          color: Color.fromARGB(0, 0, 0, 0),
                        ),
                      ),
                      onFieldSubmitted: (text) {
                        _reportParametersBloc.dispatch(SaveReportParameter(
                          report: concreteState.report,
                          userToken: concreteState.userToken,
                          parameter: param.copyWith(value: text),
                        ));
                      },
                    );

                    return textField;
                  }
              }
            } else if (param.selectionMode == 'one') {
              return Semantics(
                button: true,
                value: param.title,
                hint: param.title,
                child: RaisedButton(
                  child: Text('${param.title}: ${param.value}'),
                  onPressed: !param.readOnly
                      ? () async {
                          final selection = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SingleSelection(
                                    param: param,
                                    userToken: concreteState.userToken,
                                  ),
                            ),
                          );

                          if (selection != null) {
                            _reportParametersBloc.dispatch(SaveReportParameter(
                              report: concreteState.report,
                              userToken: concreteState.userToken,
                              parameter: param.copyWith(value: selection),
                            ));
                          }
                        }
                      : null,
                ),
              );
            } else if (param.selectionMode == 'multiselect') {
              return Semantics(
                button: true,
                value: param.title,
                hint: param.title,
                child: RaisedButton(
                  child: Text('${param.title}: ...'),
                  onPressed: !param.readOnly
                      ? () async {
                          final selection = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MultiSelection(
                                    param: param,
                                    userToken: concreteState.userToken,
                                  ),
                            ),
                          );

                          if (selection is List<Filter>) {
                            _reportParametersBloc.dispatch(SaveReportParameter(
                              report: concreteState.report,
                              userToken: concreteState.userToken,
                              parameter: param.copyWith(value: selection),
                            ));
                          }
                        }
                      : null,
                ),
              );
            }
          }).toList(),
        );
      },
    );
  }
}
