// Smoke test for the Splash screen: it renders the logo + tagline, then after
// the splash duration navigates to the Login route.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:live_stream/features/splash/presentation/view/splash_page.dart';

void main() {
  testWidgets('Splash shows logo then routes to Login', (tester) async {
    // A minimal router (splash -> stub login) so navigation has a destination
    // without pulling in get_it-backed pages.
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (_, _) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (_, _) => const Scaffold(body: Text('LOGIN')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Go Live • Stay Alive'), findsOneWidget);

    // Let the splash timer elapse and the navigation settle.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
  });
}
