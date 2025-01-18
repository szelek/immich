// ignore_for_file: avoid-dynamic

import 'package:immich_mobile/domain/dtos/user.dto.dart';
import 'package:immich_mobile/domain/interfaces/store.interface.dart';
import 'package:immich_mobile/domain/repositories/user.repository.dart';
// TODO: Remove this import after migrating User to UserDto
import 'package:immich_mobile/entities/user.entity.dart';
import 'package:isar/isar.dart';

final class StorePrimitiveConverter<T> extends IStoreConverter<T> {
  const StorePrimitiveConverter();

  @override
  T fromPrimitive(dynamic value, [dynamic db]) => value;

  @override
  dynamic toPrimitive(T value) => value;
}

final class StoreStringConverter extends StorePrimitiveConverter<String> {
  const StoreStringConverter();
}

final class StoreIntConverter extends StorePrimitiveConverter<int> {
  const StoreIntConverter();
}

final class StoreBoolConverter extends IStoreConverter<bool> {
  const StoreBoolConverter();

  @override
  bool fromPrimitive(dynamic value, [dynamic db]) => value != 0;

  @override
  int toPrimitive(bool value) => value ? 1 : 0;
}

final class StoreDateTimeConverter extends IStoreConverter<DateTime> {
  const StoreDateTimeConverter();

  @override
  DateTime fromPrimitive(dynamic value, [dynamic db]) =>
      DateTime.fromMicrosecondsSinceEpoch(value);

  @override
  int toPrimitive(DateTime value) => value.microsecondsSinceEpoch;
}

final class StoreUserConverter extends IStoreConverter<UserDto> {
  const StoreUserConverter();

  @override
  Future<UserDto?> fromPrimitive(dynamic value, dynamic db) async {
    if (db is Isar) {
      final userRepository = UserRepository(db: db);
      final user = await userRepository.get(value);
      if (user != null) {
        return user;
      }
      // TODO: Remove this handling after migrating User to UserDto
      final oldUser = await db.users.where().idEqualTo(value).findFirst();
      return oldUser?.toDTO();
    }
    return null;
  }

  @override
  String toPrimitive(UserDto value) => value.id;
}
