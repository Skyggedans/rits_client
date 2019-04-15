import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/rest_client.dart';
import 'poi.dart';

class PoiScreen extends StatefulWidget {
  PoiScreen({Key key}) : super(key: key);

  @override
  State createState() => _PoiScreenState();
}

class _PoiScreenState extends State<PoiScreen> {
  final PoiBloc _poiBloc = PoiBloc(restClient: RestClient());

  @override
  void initState() {
    super.initState();
    _poiBloc.dispatch(ScanItem());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('POI'),
        ),
        body: Center(
              child: BlocBuilder(
                bloc: _poiBloc,

                builder: (BuildContext context, PoiState state) {
                  if (state is PoiUninitialized) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  else if (state is ItemScanned) {
                    return new Column (
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Text('Scanned content:\n${state.itemInfo}'),

                          RaisedButton(
                            child: const Text('Reports'),

                            onPressed: () {
//                              Navigator.push(context,
//                                MaterialPageRoute(builder: (context) => ReportsScreen(
//                                    Poi: _Poi,
//                                    userToken: state.userToken),
//                                ),
//                              );
                            },
                          ),
                        ]
                    );
                  }
                  else if (state is PoiError) {
                    return Center(
                      child: Text('Failed to scan POI'),
                    );
                  }
                },
              )
          ),
        );
  }

  @override
  void dispose() {
    _poiBloc.dispose();
    super.dispose();
  }
}