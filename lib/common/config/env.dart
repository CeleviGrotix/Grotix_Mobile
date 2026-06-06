class Env {
  static const apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://grotixgateway1-hrftg6a4gqf0fqhd.chilecentral-01.azurewebsites.net',
    //defaultValue: 'http://192.168.1.33:5100',
  );
}

