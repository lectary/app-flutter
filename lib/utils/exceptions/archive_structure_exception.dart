class ArchiveStructureException implements Exception {
  final String _message;

  ArchiveStructureException(this._message);

  @override
  String toString() {
    return _message;
  }
}
