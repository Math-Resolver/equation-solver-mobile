class AuthChallenge {
  const AuthChallenge({
    required this.challenge,
    required this.relyingParty,
    required this.user,
  });

  final String challenge;
  final Map<String, dynamic> relyingParty;
  final Map<String, dynamic> user;

  factory AuthChallenge.fromJson(Map<String, dynamic> json) {
    return AuthChallenge(
      challenge: (json['challenge'] ?? '').toString(),
      relyingParty: (json['relyingParty'] as Map<String, dynamic>? ?? const {}),
      user: (json['user'] as Map<String, dynamic>? ?? const {}),
    );
  }
}
