class NoInternetException implements Exception {
  String _message;

  NoInternetException(this._message);

  @override
  String toString() {
    return _message;
  }
}