import 'package:device_info/device_info.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../settings.dart';

class AppConfig extends Equatable {
  final Settings settings;
  bool _isRealWearDevice = false;

  bool get isRealWearDevice => _isRealWearDevice;

  AppConfig({@required this.settings}) {
    assert(settings != null);

    _checkDevice().then((value) {
      _isRealWearDevice = value;
    });
  }

  static Future<bool> _checkDevice() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    return androidInfo?.brand == 'RealWear';
  }
}
