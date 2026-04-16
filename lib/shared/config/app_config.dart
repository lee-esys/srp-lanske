class AppConfig {
  static const coreApiBaseUrl = String.fromEnvironment(
    'LANSKE_CORE_API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
