class CodingException implements Exception {
  String _message;

  CodingException(this._message);

  @override
  String toString() {
    return _message;
  }
}