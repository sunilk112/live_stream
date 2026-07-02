// Verifies the login flow links to the Home screen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:live_stream/core/di/injection_container.dart';
import 'package:live_stream/core/routing/app_router.dart';
import 'package:live_stream/core/routing/app_routes.dart';
import 'package:live_stream/core/theme/app_theme.dart';
import 'package:live_stream/features/auth/presentation/view/login_page.dart';
import 'package:live_stream/features/home/presentation/view/home_page.dart';

void main() {
  testWidgets('valid login navigates from Login to Home', (tester) async {
    // Ignore irrelevant network-image failures (test sandbox has no network).
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception.toString().contains('NetworkImage')) return;
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    SharedPreferences.setMockInitialValues({});
    await initDependencies();

    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: AppRouter.router),
    );
    await tester.pump();

    // Splash auto-routes to Login after its timer.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    // Enter valid demo credentials.
    await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');

    // Tap Login and let the mock auth (900ms) + navigation + transition resolve.
    await tester.tap(find.text('Login'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 600));

    // We should now be on the Home route/screen.
    expect(
      AppRouter.router.routerDelegate.currentConfiguration.uri.path,
      AppRoutes.home,
    );
    expect(find.byType(HomePage), findsOneWidget);
  });
}
