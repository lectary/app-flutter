class ArchiveStructureException implements Exception {
  String _message;

  ArchiveStructureException(this._message);

  @override
  String toString() {
    return _message;
  }
}