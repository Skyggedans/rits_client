import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/rest_client.dart';
import '../models/projects/projects.dart';
import '../report/report.dart';
import 'reports.dart';

class ReportsScreen extends StatefulWidget {
  final Project project;
  final String userToken;

  ReportsScreen({Key key, @required this.project, @required this.userToken}) : super(key: key);

  @override
  State createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportsBloc _reportsBloc = ReportsBloc(restClient: RestClient());

  Project get _project => widget.project;
  String get _userToken => widget.userToken;

  @override
  void initState() {
    super.initState();
    _reportsBloc.dispatch(FetchReports(project: _project, userToken: _userToken));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Reports'),
        ),
        body: Center(
              child: BlocBuilder(
                bloc: _reportsBloc,

                builder: (BuildContext context, ReportsState state) {
                  if (state is ReportsUninitialized) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  else if (state is ReportsLoaded) {
                    return BlocProvider(
                        bloc: _reportsBloc,
                        child: _ReportButtons()
                    );
                  }
                  else if (state is ReportsError) {
                    return Center(
                      child: Text('Failed to fetch reports'),
                    );
                  }
                },
              )
          ),
        );
  }

  @override
  void dispose() {
    _reportsBloc.dispose();
    super.dispose();
  }
}

class _ReportButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _reportsBloc = BlocProvider.of<ReportsBloc>(context);

    return BlocBuilder(
      bloc: _reportsBloc,
      builder: (BuildContext context, ReportsState state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: (state as ReportsLoaded).reports.map((report) {
            return RaisedButton(
                child: Text(report.title ?? report.name),

                onPressed: () async {
                  Navigator.push(context,
                    MaterialPageRoute(
                      builder: (context) => ReportScreen(
                        report: report,
                        userToken: (state as ReportsLoaded).userToken,
                      ),
                    ),
                  );
                }
            );
          }).toList(),
        );
      },
    );
  }
}