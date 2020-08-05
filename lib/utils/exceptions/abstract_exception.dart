class AbstractException implements Exception {
  String _message;

  AbstractException(this._message);

  @override
  String toString() {
    return _message;
  }
}