import 'dart:async';

import 'package:immich_mobile/domain/dtos/store.dto.dart';
import 'package:immich_mobile/domain/entities/store.entity.dart';
import 'package:immich_mobile/domain/exceptions/store.exception.dart';
import 'package:immich_mobile/domain/interfaces/database.interface.dart';
import 'package:immich_mobile/domain/interfaces/store.interface.dart';
import 'package:immich_mobile/domain/repositories/database.repository.dart';
import 'package:isar/isar.dart';

class StoreRepository extends IsarDatabaseRepository
    implements IStoreRepository, IDatabaseRepository {
  final Isar _db;
  const StoreRepository({required super.db}) : _db = db;

  @override
  Future<bool> insert<T>(StoreKey<T> key, T value) async {
    await nestTxn(() async => await _db.store.put(key.toEntity(value)));
    return true;
  }

  @override
  Future<T> get<T>(StoreKey<T> key) async {
    final value = await tryGet(key);
    if (value == null) {
      throw StoreKeyNotFoundException(key);
    }
    return value;
  }

  @override
  Future<T?> tryGet<T>(StoreKey<T> key) {
    return nestTxn(() async {
      final entity = await _db.store.get(key.id);
      return entity?.toValue(key, _db);
    });
  }

  @override
  Stream<T?> watch<T>(StoreKey<T> key) {
    return _db.store.watchObject(key.id).asyncMap((e) => e?.toValue(key, _db));
  }

  @override
  Stream<StoreUpdateEvent> watchAll() {
    return _db.store.where().watch().asyncExpand(
          (entities) =>
              Stream.fromFutures(entities.map((e) => e.toUpdateEvent(_db))),
        );
  }

  @override
  Future<bool> update<T>(StoreKey<T> key, T value) async {
    await nestTxn(() async => await _db.store.put(key.toEntity(value)));
    return true;
  }

  @override
  Future<void> delete<T>(StoreKey<T> key) {
    return nestTxn(() async {
      await _db.store.delete(key.id);
    });
  }

  @override
  Future<void> deleteAll() {
    return nestTxn(() async {
      await _db.store.clear();
    });
  }
}

extension _ModelToEntity<T> on StoreKey<T> {
  StoreEntity toEntity(T value) {
    final storeValue = converter.toPrimitive(value);
    final intValue = (storeValue is int) ? storeValue : null;
    final strValue = (storeValue is String) ? storeValue : null;
    return StoreEntity(id: id, intValue: intValue, strValue: strValue);
  }
}

extension _EntityToDto on StoreEntity {
  Future<StoreUpdateEvent> toUpdateEvent(Isar db) async {
    final key = StoreKey.values.firstWhere((e) => e.id == id);
    final value = await toValue(key, db);
    return StoreUpdateEvent(key, value);
  }

  Future<T?> toValue<T, U>(StoreKey<T> key, Isar db) async {
    final primitive = switch (key.primitiveType) {
      const (int) => intValue,
      const (String) => strValue,
      _ => null,
    } as U?;
    if (primitive != null) {
      return await key.converter.fromPrimitive(primitive, db);
    }
    return null;
  }
}
