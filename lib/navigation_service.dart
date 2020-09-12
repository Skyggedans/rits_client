import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(Widget widget) {
    return navigatorKey.currentState.push(MaterialPageRoute(
      builder: (context) => widget,
    ));
  }

  Future<dynamic> navigateToNamed(String routeName) {
    return navigatorKey.currentState.pushNamed(routeName);
  }
}
