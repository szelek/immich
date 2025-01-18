import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart' hide Store;
import 'package:immich_mobile/domain/utils/store.dart';
import 'package:immich_mobile/services/app_settings.service.dart';

ValueNotifier<T> useAppSettingsState<T>(
  AppSettingsEnum<T> key,
) {
  final notifier = useState<T>(Store.I.get(key.storeKey, key.defaultValue));

  // Listen to changes to the notifier and update app settings
  useValueChanged(
    notifier.value,
    (_, __) => Store.I.put(key.storeKey, notifier.value),
  );

  return notifier;
}
