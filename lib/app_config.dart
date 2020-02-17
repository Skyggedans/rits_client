import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppConfig extends ChangeNotifier {
  bool _isRealWearDevice = false;

  bool get isRealWearDevice => _isRealWearDevice;

  AppConfig() {
    _checkDevice().then((value) {
      _isRealWearDevice = value;
      notifyListeners();
    });
  }

  static Future<bool> _checkDevice() async {
    WidgetsFlutterBinding.ensureInitialized();

    final deviceInfo = DeviceInfoPlugin();

    try {
      final androidInfo = await deviceInfo.androidInfo;

      return androidInfo?.brand == 'RealWear';
    } on MissingPluginException {
      return false;
    }
  }
}
