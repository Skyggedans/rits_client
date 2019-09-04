import 'package:get_it/get_it.dart';
import 'package:rits_client/authentication/authentication.dart';
import 'package:rits_client/models/app_config.dart';
import 'package:rits_client/utils/rest_client.dart';

import 'settings.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton<AppConfig>(AppConfig(settings: Settings()));
  locator.registerLazySingleton<AuthProvider>(() => AuthProvider());
  locator.registerLazySingleton<AuthRepository>(() => AuthRepository());
  locator.registerSingleton<RestClient>(RitsClient());
}
