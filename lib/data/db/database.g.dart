// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorLectureDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$LectureDatabaseBuilder databaseBuilder(String name) =>
      _$LectureDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$LectureDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$LectureDatabaseBuilder(null);
}

class _$LectureDatabaseBuilder {
  _$LectureDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$LectureDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$LectureDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<LectureDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name)
        : ':memory:';
    final database = _$LectureDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$LectureDatabase extends LectureDatabase {
  _$LectureDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  LectureDao _lectureDaoInstance;

  VocableDao _vocableDaoInstance;

  AbstractDao _abstractDaoInstance;

  CodingDao _codingDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `lectures` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `file_name` TEXT NOT NULL, `file_size` INTEGER NOT NULL, `vocable_count` INTEGER NOT NULL, `pack` TEXT NOT NULL, `lesson` TEXT NOT NULL, `lesson_sort` TEXT NOT NULL, `lang_media` TEXT NOT NULL, `lang_vocable` TEXT NOT NULL, `audio` TEXT, `date` TEXT NOT NULL, `sort` TEXT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `vocables` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `lecture_id` INTEGER NOT NULL, `vocable` TEXT NOT NULL, `vocable_sort` TEXT NOT NULL, `media_type` TEXT NOT NULL, `media` TEXT NOT NULL, `vocable_progress` INTEGER NOT NULL, FOREIGN KEY (`lecture_id`) REFERENCES `lectures` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `abstracts` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `file_name` TEXT NOT NULL, `pack` TEXT NOT NULL, `text` TEXT NOT NULL, `date` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `codings` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `file_name` TEXT NOT NULL, `lang` TEXT NOT NULL, `date` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `coding_entries` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `coding_id` INTEGER NOT NULL, `char` TEXT NOT NULL, `ascii` TEXT NOT NULL, FOREIGN KEY (`coding_id`) REFERENCES `codings` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  LectureDao get lectureDao {
    return _lectureDaoInstance ??= _$LectureDao(database, changeListener);
  }

  @override
  VocableDao get vocableDao {
    return _vocableDaoInstance ??= _$VocableDao(database, changeListener);
  }

  @override
  AbstractDao get abstractDao {
    return _abstractDaoInstance ??= _$AbstractDao(database, changeListener);
  }

  @override
  CodingDao get codingDao {
    return _codingDaoInstance ??= _$CodingDao(database, changeListener);
  }
}

class _$LectureDao extends LectureDao {
  _$LectureDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _lectureInsertionAdapter = InsertionAdapter(
            database,
            'lectures',
            (Lecture item) => <String, dynamic>{
                  'id': item.id,
                  'file_name': item.fileName,
                  'file_size': item.fileSize,
                  'vocable_count': item.vocableCount,
                  'pack': item.pack,
                  'lesson': item.lesson,
                  'lesson_sort': item.lessonSort,
                  'lang_media': item.langMedia,
                  'lang_vocable': item.langVocable,
                  'audio': item.audio,
                  'date': item.date,
                  'sort': item.sort
                },
            changeListener),
        _lectureUpdateAdapter = UpdateAdapter(
            database,
            'lectures',
            ['id'],
            (Lecture item) => <String, dynamic>{
                  'id': item.id,
                  'file_name': item.fileName,
                  'file_size': item.fileSize,
                  'vocable_count': item.vocableCount,
                  'pack': item.pack,
                  'lesson': item.lesson,
                  'lesson_sort': item.lessonSort,
                  'lang_media': item.langMedia,
                  'lang_vocable': item.langVocable,
                  'audio': item.audio,
                  'date': item.date,
                  'sort': item.sort
                },
            changeListener),
        _lectureDeletionAdapter = DeletionAdapter(
            database,
            'lectures',
            ['id'],
            (Lecture item) => <String, dynamic>{
                  'id': item.id,
                  'file_name': item.fileName,
                  'file_size': item.fileSize,
                  'vocable_count': item.vocableCount,
                  'pack': item.pack,
                  'lesson': item.lesson,
                  'lesson_sort': item.lessonSort,
                  'lang_media': item.langMedia,
                  'lang_vocable': item.langVocable,
                  'audio': item.audio,
                  'date': item.date,
                  'sort': item.sort
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _lecturesMapper = (Map<String, dynamic> row) => Lecture(
      id: row['id'] as int,
      fileName: row['file_name'] as String,
      fileSize: row['file_size'] as int,
      vocableCount: row['vocable_count'] as int,
      pack: row['pack'] as String,
      lesson: row['lesson'] as String,
      lessonSort: row['lesson_sort'] as String,
      langMedia: row['lang_media'] as String,
      langVocable: row['lang_vocable'] as String,
      audio: row['audio'] as String,
      date: row['date'] as String,
      sort: row['sort'] as String);

  final InsertionAdapter<Lecture> _lectureInsertionAdapter;

  final UpdateAdapter<Lecture> _lectureUpdateAdapter;

  final DeletionAdapter<Lecture> _lectureDeletionAdapter;

  @override
  Stream<List<Lecture>> watchAllLectures() {
    return _queryAdapter.queryListStream('SELECT * FROM lectures',
        queryableName: 'lectures', isView: false, mapper: _lecturesMapper);
  }

  @override
  Future<List<Lecture>> findAllLectures() async {
    return _queryAdapter.queryList('SELECT * FROM lectures',
        mapper: _lecturesMapper);
  }

  @override
  Future<List<Lecture>> findAllLecturesWithLang(String lang) async {
    return _queryAdapter.queryList(
        'SELECT * FROM lectures WHERE lang_vocable = ?',
        arguments: <dynamic>[lang],
        mapper: _lecturesMapper);
  }

  @override
  Future<void> deleteAllLectures() async {
    await _queryAdapter.queryNoReturn('DELETE FROM lectures');
  }

  @override
  Future<int> insertLecture(Lecture lecture) {
    return _lectureInsertionAdapter.insertAndReturnId(
        lecture, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateLecture(Lecture lecture) async {
    await _lectureUpdateAdapter.update(lecture, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteLecture(Lecture lecture) async {
    await _lectureDeletionAdapter.delete(lecture);
  }
}

class _$VocableDao extends VocableDao {
  _$VocableDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _vocableInsertionAdapter = InsertionAdapter(
            database,
            'vocables',
            (Vocable item) => <String, dynamic>{
                  'id': item.id,
                  'lecture_id': item.lectureId,
                  'vocable': item.vocable,
                  'vocable_sort': item.vocableSort,
                  'media_type': item.mediaType,
                  'media': item.media,
                  'vocable_progress': item.vocableProgress
                }),
        _vocableUpdateAdapter = UpdateAdapter(
            database,
            'vocables',
            ['id'],
            (Vocable item) => <String, dynamic>{
                  'id': item.id,
                  'lecture_id': item.lectureId,
                  'vocable': item.vocable,
                  'vocable_sort': item.vocableSort,
                  'media_type': item.mediaType,
                  'media': item.media,
                  'vocable_progress': item.vocableProgress
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _vocablesMapper = (Map<String, dynamic> row) => Vocable(
      id: row['id'] as int,
      lectureId: row['lecture_id'] as int,
      vocable: row['vocable'] as String,
      vocableSort: row['vocable_sort'] as String,
      mediaType: row['media_type'] as String,
      media: row['media'] as String,
      vocableProgress: row['vocable_progress'] as int);

  final InsertionAdapter<Vocable> _vocableInsertionAdapter;

  final UpdateAdapter<Vocable> _vocableUpdateAdapter;

  @override
  Future<List<Vocable>> findAllVocables() async {
    return _queryAdapter.queryList('SELECT * FROM vocables',
        mapper: _vocablesMapper);
  }

  @override
  Future<List<Vocable>> findVocablesByLectureId(int lectureId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM vocables WHERE lecture_id = ?',
        arguments: <dynamic>[lectureId],
        mapper: _vocablesMapper);
  }

  @override
  Future<List<Vocable>> findVocablesByLecturePack(String lecturePack) async {
    return _queryAdapter.queryList(
        'SELECT * FROM vocables JOIN lectures ON vocables.lecture_id = lectures.id WHERE pack = ?',
        arguments: <dynamic>[lecturePack],
        mapper: _vocablesMapper);
  }

  @override
  Future<void> deleteVocablesByLectureId(int lectureId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM vocables WHERE lecture_id = ?',
        arguments: <dynamic>[lectureId]);
  }

  @override
  Future<void> deleteAllVocables() async {
    await _queryAdapter.queryNoReturn('DELETE FROM vocables');
  }

  @override
  Future<void> resetAllVocableProgress() async {
    await _queryAdapter
        .queryNoReturn('UPDATE vocables SET vocable_progress = 0');
  }

  @override
  Future<List<int>> insertVocables(List<Vocable> vocables) {
    return _vocableInsertionAdapter.insertListAndReturnIds(
        vocables, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateVocable(Vocable vocable) async {
    await _vocableUpdateAdapter.update(vocable, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateVocables(List<Vocable> vocables) async {
    await _vocableUpdateAdapter.updateList(vocables, OnConflictStrategy.abort);
  }
}

class _$AbstractDao extends AbstractDao {
  _$AbstractDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _abstractInsertionAdapter = InsertionAdapter(
            database,
            'abstracts',
            (Abstract item) => <String, dynamic>{
                  'id': item.id,
                  'file_name': item.fileName,
                  'pack': item.pack,
                  'text': item.text,
                  'date': item.date
                }),
        _abstractUpdateAdapter = UpdateAdapter(
            database,
            'abstracts',
            ['id'],
            (Abstract item) => <String, dynamic>{
                  'id': item.id,
                  'file_name': item.fileName,
                  'pack': item.pack,
                  'text': item.text,
                  'date': item.date
                }),
        _abstractDeletionAdapter = DeletionAdapter(
            database,
            'abstracts',
            ['id'],
            (Abstract item) => <String, dynamic>{
                  'id': item.id,
                  'file_name': item.fileName,
                  'pack': item.pack,
                  'text': item.text,
                  'date': item.date
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _abstractsMapper = (Map<String, dynamic> row) => Abstract(
      id: row['id'] as int,
      fileName: row['file_name'] as String,
      pack: row['pack'] as String,
      text: row['text'] as String,
      date: row['date'] as String);

  final InsertionAdapter<Abstract> _abstractInsertionAdapter;

  final UpdateAdapter<Abstract> _abstractUpdateAdapter;

  final DeletionAdapter<Abstract> _abstractDeletionAdapter;

  @override
  Future<List<Abstract>> findAllAbstracts() async {
    return _queryAdapter.queryList('SELECT * FROM abstracts',
        mapper: _abstractsMapper);
  }

  @override
  Future<int> insertAbstract(Abstract abstract) {
    return _abstractInsertionAdapter.insertAndReturnId(
        abstract, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAbstract(Abstract abstract) async {
    await _abstractUpdateAdapter.update(abstract, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAbstract(Abstract abstract) async {
    await _abstractDeletionAdapter.delete(abstract);
  }
}

class _$CodingDao extends CodingDao {
  _$CodingDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _codingInsertionAdapter = InsertionAdapter(
            database,
            'codings',
            (Coding item) => <String, dynamic>{
                  'id': item.id,
                  'file_name': item.fileName,
                  'lang': item.lang,
                  'date': item.date
                }),
        _codingEntryInsertionAdapter = InsertionAdapter(
            database,
            'coding_entries',
            (CodingEntry item) => <String, dynamic>{
                  'id': item.id,
                  'coding_id': item.codingId,
                  'char': item.char,
                  'ascii': item.ascii
                }),
        _codingUpdateAdapter = UpdateAdapter(
            database,
            'codings',
            ['id'],
            (Coding item) => <String, dynamic>{
                  'id': item.id,
                  'file_name': item.fileName,
                  'lang': item.lang,
                  'date': item.date
                }),
        _codingEntryUpdateAdapter = UpdateAdapter(
            database,
            'coding_entries',
            ['id'],
            (CodingEntry item) => <String, dynamic>{
                  'id': item.id,
                  'coding_id': item.codingId,
                  'char': item.char,
                  'ascii': item.ascii
                }),
        _codingDeletionAdapter = DeletionAdapter(
            database,
            'codings',
            ['id'],
            (Coding item) => <String, dynamic>{
                  'id': item.id,
                  'file_name': item.fileName,
                  'lang': item.lang,
                  'date': item.date
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _codingsMapper = (Map<String, dynamic> row) => Coding(
      id: row['id'] as int,
      fileName: row['file_name'] as String,
      lang: row['lang'] as String,
      date: row['date'] as String);

  static final _coding_entriesMapper = (Map<String, dynamic> row) =>
      CodingEntry(
          id: row['id'] as int,
          codingId: row['coding_id'] as int,
          char: row['char'] as String,
          ascii: row['ascii'] as String);

  final InsertionAdapter<Coding> _codingInsertionAdapter;

  final InsertionAdapter<CodingEntry> _codingEntryInsertionAdapter;

  final UpdateAdapter<Coding> _codingUpdateAdapter;

  final UpdateAdapter<CodingEntry> _codingEntryUpdateAdapter;

  final DeletionAdapter<Coding> _codingDeletionAdapter;

  @override
  Future<List<Coding>> findAllCodings() async {
    return _queryAdapter.queryList('SELECT * FROM codings',
        mapper: _codingsMapper);
  }

  @override
  Future<void> deleteAllCodings() async {
    await _queryAdapter.queryNoReturn('DELETE FROM codings');
  }

  @override
  Future<List<CodingEntry>> findAllCodingEntries() async {
    return _queryAdapter.queryList('SELECT * FROM coding_entries',
        mapper: _coding_entriesMapper);
  }

  @override
  Future<List<CodingEntry>> findAllCodingEntriesByCodingId(int codingId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM coding_entries WHERE coding_id = ?',
        arguments: <dynamic>[codingId],
        mapper: _coding_entriesMapper);
  }

  @override
  Future<void> deleteCodingEntriesByCodingId(int codingId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM coding_entries WHERE coding_id = ?',
        arguments: <dynamic>[codingId]);
  }

  @override
  Future<void> deleteAllCodingEntries() async {
    await _queryAdapter.queryNoReturn('DELETE FROM coding_entries');
  }

  @override
  Future<int> insertCoding(Coding coding) {
    return _codingInsertionAdapter.insertAndReturnId(
        coding, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertCodingEntries(List<CodingEntry> codingEntries) {
    return _codingEntryInsertionAdapter.insertListAndReturnIds(
        codingEntries, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCoding(Coding coding) async {
    await _codingUpdateAdapter.update(coding, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCodingEntry(CodingEntry codingEntry) async {
    await _codingEntryUpdateAdapter.update(
        codingEntry, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCoding(Coding coding) async {
    await _codingDeletionAdapter.delete(coding);
  }
}
