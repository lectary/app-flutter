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
            'CREATE TABLE IF NOT EXISTS `lectures` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `file_name` TEXT NOT NULL, `file_size` INTEGER NOT NULL, `vocable_count` INTEGER NOT NULL, `pack` TEXT NOT NULL, `lesson` TEXT NOT NULL, `lang` TEXT NOT NULL, `audio` TEXT, `date` TEXT, `sort` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `vocable` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `lecture_id` INTEGER NOT NULL, `vocable` TEXT NOT NULL, `media_type` TEXT NOT NULL, `media` TEXT NOT NULL, FOREIGN KEY (`lecture_id`) REFERENCES `lectures` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  LectureDao get lectureDao {
    return _lectureDaoInstance ??= _$LectureDao(database, changeListener);
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
                  'lang': item.lang,
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
                  'lang': item.lang,
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
                  'lang': item.lang,
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
      lang: row['lang'] as String,
      audio: row['audio'] as String,
      date: row['date'] as String,
      sort: row['sort'] as int);

  final InsertionAdapter<Lecture> _lectureInsertionAdapter;

  final UpdateAdapter<Lecture> _lectureUpdateAdapter;

  final DeletionAdapter<Lecture> _lectureDeletionAdapter;

  @override
  Stream<List<Lecture>> findAllLectures() {
    return _queryAdapter.queryListStream('SELECT * FROM lectures',
        queryableName: 'lectures', isView: false, mapper: _lecturesMapper);
  }

  @override
  Future<void> insertLecture(Lecture lecture) async {
    await _lectureInsertionAdapter.insert(lecture, OnConflictStrategy.abort);
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
