import 'package:equation_solver_mobile/core/auth/token_pair.dart';

import 'models/auth_challenge.dart';

abstract class IAuthRepositoryInterface {
  Future<AuthChallenge> startLogin();
  Future<TokenPair> finishLogin({required String credential});
  Future<AuthChallenge> startRegister();
  Future<TokenPair> finishRegister({required String credential});
}
