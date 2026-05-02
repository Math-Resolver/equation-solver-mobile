import 'package:equation_solver_mobile/core/auth/secure_token_storage.dart';
import 'package:equation_solver_mobile/core/auth/token_storage_interface.dart';
import 'package:equation_solver_mobile/core/config/api_config.dart';
import 'package:equation_solver_mobile/core/http/http_client_factory.dart';
import 'package:equation_solver_mobile/core/http/http_client_interface.dart';
import 'package:equation_solver_mobile/features/auth/repository/auth_repository_impl.dart';
import 'package:equation_solver_mobile/features/auth/repository/auth_repository_interface.dart';
import 'package:equation_solver_mobile/features/chat_assistant/repository/chat_assistant_repository_impl.dart';
import 'package:equation_solver_mobile/features/chat_assistant/repository/chat_assistant_repository_interface.dart';
import 'package:equation_solver_mobile/features/equation_solver/repository/equation_solver_repository_impl.dart';
import 'package:equation_solver_mobile/features/equation_solver/repository/equation_solver_repository_interface.dart';

class AppDependencies {
  AppDependencies._({
    required this.tokenStorage,
    required this.httpClient,
    required this.equationRepository,
    required this.authRepository,
    required this.chatRepository,
  });

  final ITokenStorageInterface tokenStorage;
  final IHttpClientInterface httpClient;
  final IEquationSolverRepositoryInterface equationRepository;
  final IAuthRepositoryInterface authRepository;
  final IChatAssistantRepositoryInterface chatRepository;

  static AppDependencies? _instance;

  static AppDependencies get instance {
    _instance ??= create();
    return _instance!;
  }

  static AppDependencies create() {
    final tokenStorage = SecureTokenStorage();
    final httpClient = buildApiHttpClient(
      baseUrl: ApiConfig.baseUrl,
      tokenStorage: tokenStorage,
    );
    return AppDependencies._(
      tokenStorage: tokenStorage,
      httpClient: httpClient,
      equationRepository: EquationSolverRepositoryImpl(httpClient: httpClient),
      authRepository: AuthRepositoryImpl(
        httpClient: httpClient,
        tokenStorage: tokenStorage,
      ),
      chatRepository: ChatAssistantRepositoryImpl(httpClient: httpClient),
    );
  }
}
