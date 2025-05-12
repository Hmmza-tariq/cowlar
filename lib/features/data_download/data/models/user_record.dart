import 'package:isar/isar.dart';

part 'user_record.g.dart';

@collection
class UserRecord {
  Id id = Isar.autoIncrement; // Auto increment id

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

  // Default constructor required for Isar
  UserRecord();

  // Factory to create a dummy record
  factory UserRecord.dummy(int index) {
    return UserRecord()
      ..userId = 'user_$index'
      ..name = 'User $index'
      ..email = 'user$index@example.com'
      ..createdAt = DateTime.now();
  }

  @override
  String toString() {
    return 'UserRecord(id: $id, userId: $userId, name: $name, email: $email, nationality: $nationality)';
  }
}
