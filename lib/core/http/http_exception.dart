class HttpException implements Exception {
  const HttpException({required this.statusCode, this.message = ''});

  final int statusCode;
  final String message;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'HttpException($statusCode): $message';
}
