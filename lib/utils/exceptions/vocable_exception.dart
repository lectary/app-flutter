class VocableException implements Exception {
  String _message;

  VocableException(this._message);

  @override
  String toString() {
    return _message;
  }
}