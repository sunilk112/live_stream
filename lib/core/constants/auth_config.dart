class AuthConfig {
  AuthConfig._();
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    // Web client ID (client_type 3) from android/app/google-services.json.
    defaultValue:
        '137193605855-2vpok47343rgkou43d9qilhcvep2gdna.apps.googleusercontent.com',
  );
}
