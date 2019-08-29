class Settings {
  String get backendUrl =>
      'https://appbuilder.rockwellits.com:8081/api/appbuilder';
  String get webUrl => 'https://appbuilder.rockwellits.com';
  String get luisUrl => 'https://appbuilder.rockwellits.com:8081/api/Luis';

  String get authUrl =>
      'https://appbuilder.rockwellits.com:8087/connect/deviceauthorization';
  String get authTokenUrl =>
      'https://appbuilder.rockwellits.com:8087/connect/token';
  String get authUser => 'skyggedanser@gmail.com';
  String get authPassword => 'Skyggedanser12*';
  String get authClientId => 'device';
  String get authClientSecret => 'secret';

  Map<String, String> get luisConfig => {
        'azureSubKeyId': '59899bd89b634e5ba62fde0a4fb224ca',
        'host': 'https://westus.api.cognitive.microsoft.com',
        'subKeyId': 'a2f96e3b9e474c6d8d3e159b698164e5'
      };
}

const backendUrl = 'https://appbuilder.rockwellits.com:8081/api/appbuilder';
const webUrl = 'https://appbuilder.rockwellits.com';
const luisUrl = 'https://appbuilder.rockwellits.com:8081/api/Luis';

const authUrl =
    'https://appbuilder.rockwellits.com:8087/connect/deviceauthorization';
const authTokenUrl = 'https://appbuilder.rockwellits.com:8087/connect/token';
const authUser = 'skyggedanser@gmail.com';
const authPassword = 'Skyggedanser12*';
const authClientId = 'device';
const authClientSecret = 'secret';

const luisConfig = {
  'azureSubKeyId': '59899bd89b634e5ba62fde0a4fb224ca',
  'host': 'https://westus.api.cognitive.microsoft.com',
  'subKeyId': 'a2f96e3b9e474c6d8d3e159b698164e5'
};
