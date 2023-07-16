class VocableException implements Exception {
  final String _message;

  VocableException(this._message);

  @override
  String toString() {
    return _message;
  }
}