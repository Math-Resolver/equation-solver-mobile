import 'package:equation_solver_mobile/core/auth/token_pair.dart';

import 'models/auth_challenge.dart';

abstract class IAuthRepositoryInterface {
  Future<AuthChallenge> startLogin({required String email});
  Future<TokenPair> finishLogin({required String credential});
  Future<AuthChallenge> startRegister({
    required String displayName,
    required String deviceFingerprint,
  });
  Future<TokenPair> finishRegister({required String credential});
}
