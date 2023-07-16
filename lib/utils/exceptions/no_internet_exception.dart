class NoInternetException implements Exception {
  final String _message;

  NoInternetException(this._message);

  @override
  String toString() {
    return _message;
  }
}