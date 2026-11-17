abstract final class AppConfig {
  static const requestTimeout = Duration(seconds: 10);

  static String get apiBaseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    return 'https://deck-scoop-edging.ngrok-free.dev';
  }
}
