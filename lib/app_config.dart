import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget {
  bool _isRealWearDevice = false;

  bool get isRealWearDevice => _isRealWearDevice;

  AppConfig({Widget child}) : super(child: child) {
    _checkDevice().then((value) {
      _isRealWearDevice = value;
    });
  }

  static AppConfig of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(AppConfig);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  static Future<bool> _checkDevice() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    return androidInfo?.brand == 'RealWear';
  }
}
