import 'package:flutter/foundation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/live_stream_entity.dart';
import '../../domain/usecases/get_live_streams.dart';

/// Discrete UI states the View renders against. Keeps the View free of
/// imperative loading/error flags.
enum HomeStatus { initial, loading, success, error }

/// Top-level content tabs shown under the app bar.
enum HomeTab { stream, hot, follow }

/// MVVM ViewModel for the Home screen. Depends only on the domain use case
/// (injected), exposes immutable view state, and notifies listeners on change.
class HomeViewModel extends ChangeNotifier {
  final GetLiveStreams _getLiveStreams;

  HomeViewModel(this._getLiveStreams);

  HomeStatus _status = HomeStatus.initial;
  List<LiveStreamEntity> _streams = const [];
  String? _errorMessage;

  // Presentation-only selection state.
  HomeTab _selectedTab = HomeTab.stream;
  int _selectedCountry = 0; // index into [countries]

  /// Country filter options (label + emoji flag; 🌐 = Global).
  static const List<({String label, String flag})> countries = [
    (label: 'Global', flag: '🌐'),
    (label: 'India', flag: '🇮🇳'),
    (label: 'Philippines', flag: '🇵🇭'),
    (label: 'Brazil', flag: '🇧🇷'),
    (label: 'Vietnam', flag: '🇻🇳'),
    (label: 'USA', flag: '🇺🇸'),
  ];

  HomeStatus get status => _status;
  List<LiveStreamEntity> get streams => _streams;
  String? get errorMessage => _errorMessage;
  HomeTab get selectedTab => _selectedTab;
  int get selectedCountry => _selectedCountry;

  void selectTab(HomeTab tab) {
    if (_selectedTab == tab) return;
    _selectedTab = tab;
    notifyListeners();
  }

  void selectCountry(int index) {
    if (_selectedCountry == index) return;
    _selectedCountry = index;
    notifyListeners();
  }

  /// Toggles the follow state of a stream's host locally.
  void toggleFollow(String id) {
    _streams = [
      for (final s in _streams)
        if (s.id == id) s.copyWith(isFollowed: !s.isFollowed) else s,
    ];
    notifyListeners();
  }

  /// Loads live streams via the use case and maps the `Either` result to state.
  Future<void> loadLiveStreams() async {
    _status = HomeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _getLiveStreams(const NoParams());

    result.fold(
      (failure) {
        _status = HomeStatus.error;
        _errorMessage = failure.message;
      },
      (streams) {
        _status = HomeStatus.success;
        _streams = streams;
      },
    );

    notifyListeners();
  }
}
