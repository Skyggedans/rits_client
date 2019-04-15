import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/rest_client.dart';
import '../models/reports/reports.dart';
import '../report_parameters/report_parameters.dart';
import 'report.dart';

class ReportScreen extends StatefulWidget {
  final Report report;
  final String userToken;

  ReportScreen({Key key, @required this.report, @required this.userToken})
      : super(key: key);

  @override
  State createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportBloc _reportBloc = ReportBloc(restClient: RestClient());

  Report get _report => widget.report;
  String get _userToken => widget.userToken;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_report.title ?? _report.name),
      ),
      body: Center(
          child: BlocBuilder(
        bloc: _reportBloc,
        builder: (BuildContext context, ReportState state) {
          if (state is ReportGeneration) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
//                  else if (state is ReportGenerated) {
//                    WidgetsBinding.instance.addPostFrameCallback((_){
//                      if (state.reportBytes.lengthInBytes > 0) {
//                        PdfViewer.loadBytes(state.reportBytes);
//                      }
//                    });
//
//                    return Center(
//                      child: Text('Report generated successfully'),
//                    );
//                  }
          else if (state is ReportError) {
            return Center(
              child: Text('Failed to generate report'),
            );
          } else {
            return new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RaisedButton(
                    child: const Text('View Parameters'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportParametersScreen(
                              report: _report, userToken: _userToken),
                        ),
                      );
                    },
                  ),
                  RaisedButton(
                    child: const Text('View Report'),
                    onPressed: () {
                      _reportBloc.dispatch(ViewReport(_report, _userToken));
                    },
                  ),
                ]);
          }
        },
      )),
    );
  }

  @override
  void dispose() {
    _reportBloc.dispose();
    super.dispose();
  }
}
