import 'package:floor/floor.dart';
import 'package:lectary/data/db/entities/coding.dart';

@dao
abstract class CodingDao {

  @Query("SELECT * FROM codings")
  Future<List<Coding>> findAllCodings();

  @insert
  Future<int> insertCoding(Coding coding);

  @update
  Future<void> updateCoding(Coding coding);

  @delete
  Future<void> deleteCoding(Coding coding);



  @Query("SELECT * FROM coding_entries")
  Future<List<CodingEntry>> findAllCodingEntries();

  @insert
  Future<List<int>> insertCodingEntries(List<CodingEntry> codingEntries);

  @update
  Future<void> updateCodingEntry(CodingEntry codingEntry);

  @Query("DELETE FROM coding_entries WHERE coding_id = :codingId")
  Future<void> deleteCodingEntriesByCodingId(int codingId);

  @Query("DELETE FROM coding_entries")
  Future<void> deleteAllCodingEntries();
}