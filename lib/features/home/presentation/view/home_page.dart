import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/app_routes.dart';
import '../viewmodel/home_viewmodel.dart';
import '../widgets/alive_bottom_nav_bar.dart';
import '../widgets/country_filter_bar.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/stream_grid_card.dart';
import '../widgets/stream_tab_bar.dart';

/// Home View. Owns no business logic — it creates its [HomeViewModel] from the
/// service locator and renders whatever state the ViewModel exposes.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeViewModel>(
      create: (_) => sl<HomeViewModel>()..loadLiveStreams(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  // Home edge margin == the grid's center gap (14) so the two columns look
  // symmetric from the screen edges and down the middle.
  static const double _hPad = 14;
  static const double _gridGap = 14;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    // Hardware back on Home goes to Login (instead of exiting the app).
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.goNamed(AppRoutes.loginName);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        bottomNavigationBar: AliveBottomNavBar(
          current: AliveNavTab.home,
          onSelected: (_) {},
          onGoLive: () {},
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _hPad),
                child: HomeAppBar(notificationCount: 3),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _hPad),
                child: StreamTabBar(
                  selected: vm.selectedTab,
                  onSelected: vm.selectTab,
                ),
              ),
              const SizedBox(height: 18),
              CountryFilterBar(
                countries: HomeViewModel.countries,
                selectedIndex: vm.selectedCountry,
                onSelected: vm.selectCountry,
                padding: const EdgeInsets.symmetric(horizontal: _hPad),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildBody(context, vm)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel vm) {
    switch (vm.status) {
      case HomeStatus.initial:
      case HomeStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case HomeStatus.error:
        return _ErrorView(
          message: vm.errorMessage ?? 'Something went wrong.',
          onRetry: vm.loadLiveStreams,
        );

      case HomeStatus.success:
        if (vm.streams.isEmpty) {
          return const Center(child: Text('No live streams right now.'));
        }
        final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
        return RefreshIndicator(
          onRefresh: vm.loadLiveStreams,
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(_hPad, 0, _hPad, 110 + bottomInset),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: _gridGap,
              mainAxisSpacing: _gridGap,
              childAspectRatio: 0.74,
            ),
            itemCount: vm.streams.length,
            itemBuilder: (context, index) {
              final stream = vm.streams[index];
              return StreamGridCard(
                stream: stream,
                onTap: () {},
                onFollowTap: () => vm.toggleFollow(stream.id),
              );
            },
          ),
        );
    }
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
