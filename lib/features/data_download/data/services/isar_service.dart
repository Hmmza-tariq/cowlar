import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Import user record model
import '../models/user_record.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDb();
  }
  Future<Isar> openDb() async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [UserRecordSchema],
      directory: dir.path,
      name: 'cowlarDB',
    );
  }

  Future<void> saveRecords(List<UserRecord> records) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.collection<UserRecord>().putAll(records);
    });
  }

  Future<List<UserRecord>> getRecords({int offset = 0, int limit = 50}) async {
    final isar = await db;
    return await isar
        .collection<UserRecord>()
        .where()
        .sortByCreatedAt()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  Future<int> getRecordCount() async {
    final isar = await db;
    return await isar.collection<UserRecord>().count();
  }

  Future<void> clearRecords() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.collection<UserRecord>().clear();
    });
  }
}
