// ignore_for_file: avoid-dynamic

import 'dart:async';

import 'package:immich_mobile/domain/dtos/store.dto.dart';

abstract class IStoreConverter<T> {
  const IStoreConverter();

  /// Converts the value back to T? from the primitive type U from the db
  FutureOr<T?> fromPrimitive(dynamic value, dynamic db);

  /// Converts the value T to the primitive type U supported by the Store
  dynamic toPrimitive(T value);
}

abstract interface class IStoreRepository {
  Future<bool> insert<T>(StoreKey<T> key, T value);

  Future<T> get<T>(StoreKey<T> key);

  Future<T?> tryGet<T>(StoreKey<T> key);

  Stream<T?> watch<T>(StoreKey<T> key);

  Stream<StoreUpdateEvent> watchAll();

  Future<bool> update<T>(StoreKey<T> key, T value);

  Future<void> delete<T>(StoreKey<T> key);

  Future<void> deleteAll();
}
