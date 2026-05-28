/// Backend and feature flags (mirrors REACT_APP_* from the web app).
class AppConfig {
  static const String defaultBackendUrl = 'https://detea-backend.onrender.com';

  static String get backendUrl {
    const fromEnv = String.fromEnvironment('BACKEND_URL');
    if (fromEnv.isNotEmpty) return fromEnv.replaceAll(RegExp(r'/$'), '');
    return defaultBackendUrl;
  }

  static const String appName = 'Deite';
  static const String packageId = 'therapist.deite.app';
}
