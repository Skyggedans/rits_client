import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/rest_client.dart';
import '../models/reports/reports.dart';
import '../widgets/widgets.dart';
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
  final ReportParametersBloc _projectsBloc = ReportParametersBloc(restClient: RestClient());

  Report get _report => widget.report;
  String get _userToken => widget.userToken;

  @override
  void initState() {
    super.initState();
    _projectsBloc.dispatch(FetchReportParameters(report: _report, userToken: _userToken));
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
              }
              else if (state is ReportParametersLoaded) {
                return BlocProvider(
                    bloc: _projectsBloc,
                    child: _ReportParameters(),
                );
              }
              else if (state is ReportParametersError) {
                return Center(
                  child: Text('Failed to fetch or save report parameters'),
                );
              }
            },
          )
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
    final _reportParametersBloc = BlocProvider.of<ReportParametersBloc>(context);

    return BlocBuilder(
      bloc: _reportParametersBloc,

      builder: (BuildContext context, ReportParametersState state) {
        final concreteState = (state as ReportParametersLoaded);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: concreteState.parameters.map((param) {
            switch (param.dataType) {
              case 'DateTime': {
                //                return DateTimePickerFormField(
                //                  inputType: InputType.date,
                //                  format: DateFormat.yMd(), //'MM/dd/yyyy'),
                //                  editable: !param.readOnly,
                //                  initialValue: DateTime.now(), //param.value,
                //                  initialDatePickerMode: DatePickerMode.year,
                //                  decoration: InputDecoration(
                //                      labelText: param.title,
                //                      helperText: param.title,
                //                      helperStyle: TextStyle(
                //                          fontSize: 1,
                //                          color: Color(0xffffff)
                //                      ),
                //                      hasFloatingPlaceholder: false
                //                  ),
                //                  onChanged: (dt) {},
                //                );

                return DateTimePicker(
                    labelText: param.title,
                    selectedDate: param.value,

                    selectDate: (value) {
                      _reportParametersBloc.dispatch(SaveReportParameter(
                          report: concreteState.report,
                          userToken: concreteState.userToken,
                          parameter: param.copyWith(value: value)
                      ));
                    },
                );
              }
              default: {
                final textController = TextEditingController();

                textController.addListener(() {
                  _reportParametersBloc.dispatch(SaveReportParameter(
                      report: concreteState.report,
                      userToken: concreteState.userToken,
                      parameter: param.copyWith(value: textController.text)
                  ));
                });

                return TextFormField(
                  //controller: textController,
                  initialValue: param.value.toString(),

                  onEditingComplete: () {
                    this;
                    _reportParametersBloc.dispatch(SaveReportParameter(
                        report: concreteState.report,
                        userToken: concreteState.userToken,
                        parameter: param.copyWith(value: textController.text)
                    ));
                  },
                );
              }
            }
          }).toList(),
        );
      }
    );
  }
}