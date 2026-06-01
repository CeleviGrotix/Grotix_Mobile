class Env {
  static const apiBase = String.fromEnvironment(
    'API_BASE',
    //defaultValue: ,
    defaultValue: 'http://192.168.1.33:5100',
  );
}
