import 'dart:async';

import 'package:immich_mobile/domain/dtos/store.dto.dart';
import 'package:immich_mobile/domain/utils/store.dart';
import 'package:immich_mobile/entities/store.entity.dart';
import 'package:immich_mobile/utils/db.dart';
import 'package:isar/isar.dart';

const int _ktargetVersion = 9;

Future<void> migrateDatabaseIfNeeded(Isar db) async {
  final int version = StoreOld.getOldValue(StoreKey.version, 1)!;
  if (version < 9) {
    await _migrateSettings();
  }
  if (version < _ktargetVersion) {
    await _migrateTo(db, _ktargetVersion);
  }
}

Future<void> _migrateSettings() async {
  for (StoreKey key in StoreKey.values) {
    final value = StoreOld.getOldValue(key);
    if (value != null) {
      await Store.I.put(key, value);
    }
  }
}

Future<void> _migrateTo(Isar db, int version) async {
  await clearAssetsAndAlbums(db);
  await Store.I.put(StoreKey.version, version);
  await StoreOld.updateVersion(version);
}
