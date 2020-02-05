import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../utils/rest_client.dart';
import '../models/view_objects/view_objects.dart';
import '../widgets/widgets.dart';
import 'selection/selection.dart';
import 'view_object_parameters.dart';

class ViewObjectParametersScreen extends StatefulWidget {
  final ViewObject viewObject;
  final String userToken;

  ViewObjectParametersScreen(
      {Key key, @required this.viewObject, @required this.userToken})
      : super(key: key);

  @override
  State createState() => _ViewObjectParametersScreenState();
}

class _ViewObjectParametersScreenState
    extends State<ViewObjectParametersScreen> {
  final ViewObjectParametersBloc _viewObjectParametersBloc =
      ViewObjectParametersBloc(restClient: RestClient());

  ViewObject get _viewObject => widget.viewObject;

  String get _userToken => widget.userToken;

  @override
  void initState() {
    super.initState();
    _viewObjectParametersBloc.add(FetchViewObjectParameters(
      viewObject: _viewObject,
      userToken: _userToken,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_viewObject.title} Parameters'),
      ),
      body: Center(
        child: BlocBuilder(
          bloc: _viewObjectParametersBloc,
          builder: (BuildContext context, ViewObjectParametersState state) {
            if (state is ViewObjectParametersInProgress) {
              return CircularProgressIndicator();
            } else if (state is ViewObjectParametersLoaded) {
              return InheritedProvider<ViewObjectParametersBloc>.value(
                value: _viewObjectParametersBloc,
                child: _ReportParameters(),
              );
            }

            return const Text('Failed to fetch or save view object parameters');
          },
        ),
      ),
    );
  }
}

class _ReportParameters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ViewObjectParametersBloc>(
      builder: (BuildContext context, ViewObjectParametersBloc bloc, _) {
        final concreteState = bloc.state as ViewObjectParametersLoaded;

        return Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: concreteState.parameters
                .where((param) => !param.readOnly)
                .map((param) {
              if (param.selectionMode == 'none') {
                switch (param.dataType) {
                  case 'datetime':
                    {
                      return Semantics(
                        textField: true,
                        value: param.title,
                        child: DateTimePicker(
                          labelText: param.title,
                          selectedDate: param.value as DateTime,
                          selectDate: (value) {
                            bloc.add(SaveViewObjectParameter(
                              viewObject: concreteState.viewObject,
                              userToken: concreteState.userToken,
                              parameter: param.copyWith(value: value),
                            ));
                          },
                        ),
                      );
                    }
                  default:
                    {
                      final textField = Semantics(
                        textField: true,
                        value: param.title,
                        child: TextFormField(
                          initialValue: param.value.toString(),
                          keyboardType: param.dataType == 'numeric'
                              ? TextInputType.number
                              : TextInputType.text,
                          enabled: !param.readOnly,
                          decoration: InputDecoration(
                            labelText: param.title,
                          ),
                          onFieldSubmitted: (text) {
                            bloc.add(SaveViewObjectParameter(
                              viewObject: concreteState.viewObject,
                              userToken: concreteState.userToken,
                              parameter: param.copyWith(value: text),
                            ));
                          },
                        ),
                      );

                      return textField;
                    }
                }
              } else if (param.selectionMode == 'one') {
                final handler = !param.readOnly
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
                          bloc.add(SaveViewObjectParameter(
                            viewObject: concreteState.viewObject,
                            userToken: concreteState.userToken,
                            parameter: param.copyWith(value: selection),
                          ));
                        }
                      }
                    : null;

                return Semantics(
                  button: true,
                  value: param.title,
                  onTap: handler,
                  child: RaisedButton(
                    child: Text('${param.title}: ${param.value}'),
                    onPressed: handler,
                  ),
                );
              } else if (param.selectionMode == 'multiselect') {
                final handler = !param.readOnly
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

                        if (selection is List<Option>) {
                          bloc.add(SaveViewObjectParameter(
                            viewObject: concreteState.viewObject,
                            userToken: concreteState.userToken,
                            parameter: param.copyWith(value: selection),
                          ));
                        }
                      }
                    : null;

                return Semantics(
                  button: true,
                  value: param.title,
                  onTap: handler,
                  child: RaisedButton(
                    child: Text('${param.title}: (multiple selection)'),
                    onPressed: handler,
                  ),
                );
              }
            }).toList(),
          ),
        );
      },
    );
  }
}
