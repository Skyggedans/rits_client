import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:rits_client/models/projects/projects.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/utils/rest_client.dart';
import 'package:rits_client/widgets/widgets.dart';
import 'selection/selection.dart';
import 'view_object_parameters.dart';

class ViewObjectParametersScreen extends StatefulWidget {
  final ViewObject viewObject;

  ViewObjectParametersScreen({
    Key key,
    @required this.viewObject,
  }) : super(key: key);

  @override
  State createState() => _ViewObjectParametersScreenState();
}

class _ViewObjectParametersScreenState
    extends State<ViewObjectParametersScreen> {
  final ViewObjectParametersBloc _projectsBloc = ViewObjectParametersBloc();

  ViewObject get _viewObject => widget.viewObject;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_projectsBloc.currentState == _projectsBloc.initialState) {
      final projectContext = Provider.of<ProjectContext>(context);

      _projectsBloc.dispatch(FetchViewObjectParameters(
        viewObject: _viewObject,
        userToken: projectContext.userToken,
      ));
    }
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
        final projectContext = Provider.of<ProjectContext>(context);

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
                      return DateTimePicker(
                        labelText: param.title,
                        helperText: param.title,
                        selectedDate: param.value,
                        selectDate: (value) {
                          _reportParametersBloc
                              .dispatch(SaveViewObjectParameter(
                            viewObject: concreteState.viewObject,
                            userToken: projectContext.userToken,
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
                          _reportParametersBloc
                              .dispatch(SaveViewObjectParameter(
                            viewObject: concreteState.viewObject,
                            userToken: projectContext.userToken,
                            parameter: param.copyWith(value: text),
                          ));
                        },
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
                            builder: (context) => SingleSelection(param: param),
                          ),
                        );

                        if (selection != null) {
                          _reportParametersBloc
                              .dispatch(SaveViewObjectParameter(
                            viewObject: concreteState.viewObject,
                            userToken: projectContext.userToken,
                            parameter: param.copyWith(value: selection),
                          ));
                        }
                      }
                    : null;

                return Semantics(
                  button: true,
                  value: param.title,
                  onTap: handler,
                  // child: TextFormField(
                  //   initialValue: '${param.value}',
                  //   textInputAction: TextInputAction.continueAction,
                  //   //enabled: false,
                  //   decoration: InputDecoration(
                  //     labelText: '${param.title}',
                  //     helperText: '${param.title}',
                  //     helperStyle: TextStyle(
                  //       fontSize: 1,
                  //       color: Color.fromARGB(0, 0, 0, 0),
                  //     ),
                  //   ),
                  // ),
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
                            builder: (context) => MultiSelection(param: param),
                          ),
                        );

                        if (selection is List<Filter>) {
                          _reportParametersBloc
                              .dispatch(SaveViewObjectParameter(
                            viewObject: concreteState.viewObject,
                            userToken: projectContext.userToken,
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
