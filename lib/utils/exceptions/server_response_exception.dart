class ServerResponseException implements Exception {
  final String _message;

  ServerResponseException(this._message);

  @override
  String toString() {
    return _message;
  }
}
