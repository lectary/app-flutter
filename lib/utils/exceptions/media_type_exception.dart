class MediaTypeException implements Exception {
  String _message;

  MediaTypeException(this._message);

  @override
  String toString() {
    return _message;
  }
}