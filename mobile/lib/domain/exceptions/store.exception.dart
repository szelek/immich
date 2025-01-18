import 'package:immich_mobile/domain/dtos/store.dto.dart';

class StoreUnInitializedException implements Exception {
  const StoreUnInitializedException();

  @override
  String toString() => "Store not initialized. Call init()";
}

class StoreKeyNotFoundException implements Exception {
  final StoreKey key;
  const StoreKeyNotFoundException(this.key);

  @override
  String toString() => "Key <'${key.name}'> not found in Store";
}

class StoreUnkownConverterException implements Exception {
  final StoreKey key;
  final Type type;
  const StoreUnkownConverterException(this.key, this.type);

  @override
  String toString() =>
      "Key <'${key.name}'> of type <$type> do not have an IStoreConverter";
}

class StoreUnkownPrimitiveTypeException implements Exception {
  final StoreKey key;
  final Type type;
  const StoreUnkownPrimitiveTypeException(this.key, this.type);

  @override
  String toString() =>
      "Cannot determine the primitive type for Key <'${key.name}'> of type <$type>";
}
