class ArchiveException implements Exception {
  String _message;

  ArchiveException(this._message);

  @override
  String toString() {
    return _message;
  }
}