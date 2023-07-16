class CodingException implements Exception {
  final String _message;

  CodingException(this._message);

  @override
  String toString() {
    return _message;
  }
}
