import 'dart:async';

import 'package:immich_mobile/domain/dtos/store.dto.dart';
import 'package:immich_mobile/domain/exceptions/store.exception.dart';
import 'package:immich_mobile/domain/interfaces/store.interface.dart';

typedef _StoreCache = Map<int, dynamic>;

final class Store {
  final IStoreRepository _storeRepository;
  final _StoreCache _cache = {};
  late final StreamSubscription<StoreUpdateEvent> _subscription;

  Store._(IStoreRepository storeRepository)
      : _storeRepository = storeRepository;

  /// Initializes the store with the given [storeRepository]
  static Future<void> init(IStoreRepository storeRepository) async {
    if (_instance != null) {
      return;
    }
    _instance = Store._(storeRepository);
    await _instance!._populateCache();
    _instance!._subscription = _instance!._listenForChange();
  }

  static Store? _instance;
  static Store get I {
    if (_instance == null) {
      throw const StoreUnInitializedException();
    }
    return _instance!;
  }

  /// Fills the cache with the values from the DB
  Future<void> _populateCache() async {
    for (StoreKey key in StoreKey.values) {
      final value = await _storeRepository.tryGet(key);
      if (value != null) {
        _cache[key.id] = value;
      }
    }
  }

  /// Listens for changes in the DB and updates the cache
  StreamSubscription<StoreUpdateEvent> _listenForChange() =>
      _storeRepository.watchAll().listen((event) {
        _cache[event.key.id] = event.value;
      });

  /// Disposes the store and cancels the subscription. To reuse the store call init() again
  void dispose() async {
    await _subscription.cancel();
    _cache.clear();
  }

  /// Returns the stored value for the given key (possibly null)
  // ignore: avoid-unnecessary-nullable-return-type
  T? tryGet<T>(StoreKey<T> key) => _cache[key.id];

  /// Returns the stored value for the given key or if null the [defaultValue]
  /// Throws a [StoreKeyNotFoundException] if both are null
  T get<T>(StoreKey<T> key, [T? defaultValue]) {
    final value = tryGet(key) ?? defaultValue;
    if (value == null) {
      throw StoreKeyNotFoundException(key);
    }
    return value;
  }

  /// Asynchronously stores the value in the DB and synchronously in the cache
  Future<void> put<T>(StoreKey<T> key, T value) async {
    if (_cache[key.id] == value) return;

    await _storeRepository.insert(key, value);
    _cache[key.id] = value;
  }

  /// Watches a specific key for changes
  Stream<T?> watch<T>(StoreKey<T> key) => _storeRepository.watch(key);

  /// Removes the value asynchronously from the DB and synchronously from the cache
  Future<void> delete<T>(StoreKey<T> key) async {
    await _storeRepository.delete(key);
    _cache.remove(key.id);
  }

  /// Clears all values from this store (cache and DB), only for testing!
  Future<void> clear() async {
    await _storeRepository.deleteAll();
    _cache.clear();
  }
}
