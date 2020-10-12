import 'package:floor/floor.dart';
import 'package:lectary/data/db/entities/abstract.dart';


@dao
abstract class AbstractDao {

  @Query("SELECT * FROM abstracts")
  Future<List<Abstract>> findAllAbstracts();

  @insert
  Future<int> insertAbstract(Abstract abstract);

  @update
  Future<void> updateAbstract(Abstract abstract);

  @delete
  Future<void> deleteAbstract(Abstract abstract);
}