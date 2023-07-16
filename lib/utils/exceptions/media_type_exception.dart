class MediaTypeException implements Exception {
  final String _message;

  MediaTypeException(this._message);

  @override
  String toString() {
    return _message;
  }
}