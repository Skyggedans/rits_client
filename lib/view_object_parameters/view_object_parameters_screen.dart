import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

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
  final ViewObjectParametersBloc _projectsBloc =
      ViewObjectParametersBloc(restClient: RestClient());

  ViewObject get _viewObject => widget.viewObject;

  String get _userToken => widget.userToken;

  @override
  void initState() {
    super.initState();
    _projectsBloc.dispatch(FetchViewObjectParameters(
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
          bloc: _projectsBloc,
          builder: (BuildContext context, ViewObjectParametersState state) {
            if (state is ViewObjectParametersInProgress) {
              return CircularProgressIndicator();
            } else if (state is ViewObjectParametersLoaded) {
              return BlocProvider(
                bloc: _projectsBloc,
                child: _ReportParameters(),
              );
            } else if (state is ViewObjectParametersError) {
              return const Text(
                  'Failed to fetch or save view object parameters');
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
        BlocProvider.of<ViewObjectParametersBloc>(context);

    return BlocBuilder(
      bloc: _reportParametersBloc,
      builder: (BuildContext context, ViewObjectParametersState state) {
        final concreteState = (state as ViewObjectParametersLoaded);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: concreteState.parameters
              .where((param) => !param.readOnly)
              .map((param) {
            if (param.selectionMode == 'none') {
              switch (param.dataType) {
                case 'datetime':
                  {
                    return DateTimePicker(
                      labelText: param.title,
                      helperText: param.title,
                      selectedDate: param.value,
                      selectDate: (value) {
                        _reportParametersBloc.dispatch(SaveViewObjectParameter(
                          viewObject: concreteState.viewObject,
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
                        _reportParametersBloc.dispatch(SaveViewObjectParameter(
                          viewObject: concreteState.viewObject,
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
                            _reportParametersBloc
                                .dispatch(SaveViewObjectParameter(
                              viewObject: concreteState.viewObject,
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
                            _reportParametersBloc
                                .dispatch(SaveViewObjectParameter(
                              viewObject: concreteState.viewObject,
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
