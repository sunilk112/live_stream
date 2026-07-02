/// Single source of truth for route names and paths.
/// Reference these constants instead of hard-coding strings at call sites.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String splashName = 'splash';

  static const String login = '/login';
  static const String loginName = 'login';

  static const String home = '/home';
  static const String homeName = 'home';
}
