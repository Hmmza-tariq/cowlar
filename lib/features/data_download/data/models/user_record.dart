import 'package:isar/isar.dart';

part 'user_record.g.dart';

@collection
class UserRecord {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String userId;

  late String name;
  late String email;
  String? phone;
  String? location;
  String? profileImage;
  int? age;
  String? gender;
  String? nationality;

  @Index(type: IndexType.value)
  late DateTime createdAt;

  UserRecord();

  @override
  String toString() {
    return 'UserRecord(id: $id, userId: $userId, name: $name, email: $email, nationality: $nationality)';
  }
}
