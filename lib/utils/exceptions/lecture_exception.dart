class LectureException implements Exception {
  final String _message;

  LectureException(this._message);

  @override
  String toString() {
    return _message;
  }
}