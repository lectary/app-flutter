class AbstractException implements Exception {
  final String _message;

  AbstractException(this._message);

  @override
  String toString() {
    return _message;
  }
}