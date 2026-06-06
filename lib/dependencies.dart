import 'package:equation_solver_mobile/core/auth/mock_passkey_client_impl.dart';
import 'package:equation_solver_mobile/core/auth/passkey_client_impl.dart';
import 'package:equation_solver_mobile/core/auth/passkey_client_interface.dart';
import 'package:equation_solver_mobile/core/auth/secure_token_storage.dart';
import 'package:equation_solver_mobile/core/auth/token_storage_interface.dart';
import 'package:equation_solver_mobile/core/device/device_model_provider.dart';
import 'package:equation_solver_mobile/core/config/api_config.dart';
import 'package:equation_solver_mobile/core/http/http_client_factory.dart';
import 'package:equation_solver_mobile/core/http/http_client_interface.dart';
import 'package:equation_solver_mobile/core/http/mock_api_http_client.dart';
import 'package:equation_solver_mobile/core/localization/app_locale_controller.dart';
import 'package:equation_solver_mobile/features/auth/repository/auth_repository_impl.dart';
import 'package:equation_solver_mobile/features/auth/repository/auth_repository_interface.dart';
import 'package:equation_solver_mobile/features/chat_assistant/repository/chat_assistant_repository_impl.dart';
import 'package:equation_solver_mobile/features/chat_assistant/repository/chat_assistant_repository_interface.dart';
import 'package:equation_solver_mobile/features/equation_solver/repository/equation_solver_repository_impl.dart';
import 'package:equation_solver_mobile/features/equation_solver/repository/equation_solver_repository_interface.dart';
import 'package:equation_solver_mobile/features/menu/repository/language_preferences_repository_impl.dart';
import 'package:equation_solver_mobile/features/menu/repository/language_preferences_repository_interface.dart';

class AppDependencies {
  AppDependencies._({
    required this.tokenStorage,
    required this.deviceModelProvider,
    required this.passkeyClient,
    required this.httpClient,
    required this.equationRepository,
    required this.authRepository,
    required this.chatRepository,
    required this.languagePreferencesRepository,
    required this.localeController,
  });

  final ITokenStorageInterface tokenStorage;
  final IDeviceModelProvider deviceModelProvider;
  final IPasskeyClientInterface passkeyClient;
  final IHttpClientInterface httpClient;
  final IEquationSolverRepositoryInterface equationRepository;
  final IAuthRepositoryInterface authRepository;
  final IChatAssistantRepositoryInterface chatRepository;
  final ILanguagePreferencesRepository languagePreferencesRepository;
  final AppLocaleController localeController;

  static AppDependencies? _instance;

  static AppDependencies get instance {
    _instance ??= create();
    return _instance!;
  }

  static AppDependencies create() {
    final tokenStorage = SecureTokenStorage();
    final deviceModelProvider = DeviceModelProvider();
    final passkeyClient = ApiConfig.useApiMock
        ? MockPasskeyClientImpl()
        : PasskeyClientImpl();
    final httpClient = ApiConfig.useApiMock
        ? MockApiHttpClient(
            scenario: ApiConfig.mockApiScenario,
            latencyMs: ApiConfig.mockApiLatencyMs,
            latencyJitterMs: ApiConfig.mockApiLatencyJitterMs,
          )
        : buildApiHttpClient(
            baseUrl: ApiConfig.baseUrl,
            tokenStorage: tokenStorage,
          );
    final languagePreferencesRepository = LanguagePreferencesRepositoryImpl();
    final localeController = AppLocaleController(
      repository: languagePreferencesRepository,
    );
    return AppDependencies._(
      tokenStorage: tokenStorage,
      deviceModelProvider: deviceModelProvider,
      passkeyClient: passkeyClient,
      httpClient: httpClient,
      equationRepository: EquationSolverRepositoryImpl(httpClient: httpClient),
      authRepository: AuthRepositoryImpl(
        httpClient: httpClient,
        tokenStorage: tokenStorage,
      ),
      chatRepository: ChatAssistantRepositoryImpl(httpClient: httpClient),
      languagePreferencesRepository: languagePreferencesRepository,
      localeController: localeController,
    );
  }
}
