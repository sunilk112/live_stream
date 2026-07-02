import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/presentation/viewmodel/login_viewmodel.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_live_streams.dart';
import '../../features/home/presentation/viewmodel/home_viewmodel.dart';
import '../network/dio_client.dart';

/// Global service locator.
final GetIt sl = GetIt.instance;

/// Wires up every dependency, outer layer depending on inner. Call once from
/// `main()` before `runApp`.
Future<void> initDependencies() async {
  // ---------------------------------------------------------------------------
  // External / third-party singletons
  // ---------------------------------------------------------------------------
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<DioClient>(() => DioClient(sl<Dio>()));

  // Firebase / Google (singletons provided by their SDKs).
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);

  // ---------------------------------------------------------------------------
  // Feature: Auth
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      // Passed as lazy providers so Firebase/Google are only touched when the
      // user actually taps "Continue with Google".
      firebaseAuth: () => sl<FirebaseAuth>(),
      googleSignIn: () => sl<GoogleSignIn>(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton<LoginUser>(
    () => LoginUser(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignInWithGoogle>(
    () => SignInWithGoogle(sl<AuthRepository>()),
  );
  sl.registerFactory<LoginViewModel>(
    () => LoginViewModel(sl<LoginUser>(), sl<SignInWithGoogle>()),
  );

  // ---------------------------------------------------------------------------
  // Feature: Home
  // ---------------------------------------------------------------------------

  // Data sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl<HomeRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton<GetLiveStreams>(
    () => GetLiveStreams(sl<HomeRepository>()),
  );

  // ViewModels — factory so each screen gets a fresh, disposable instance.
  sl.registerFactory<HomeViewModel>(
    () => HomeViewModel(sl<GetLiveStreams>()),
  );
}
