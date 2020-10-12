class LectureException implements Exception {
  String _message;

  LectureException(this._message);

  @override
  String toString() {
    return _message;
  }
}