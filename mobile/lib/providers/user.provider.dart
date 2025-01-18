import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/domain/dtos/store.dto.dart';
import 'package:immich_mobile/domain/dtos/user.dto.dart';
import 'package:immich_mobile/domain/utils/store.dart';
import 'package:immich_mobile/entities/user.entity.dart';
import 'package:immich_mobile/providers/api.provider.dart';
import 'package:immich_mobile/providers/db.provider.dart';
import 'package:immich_mobile/repositories/user.repository.dart';
import 'package:immich_mobile/services/api.service.dart';
import 'package:isar/isar.dart';

class CurrentUserProvider extends StateNotifier<User?> {
  CurrentUserProvider(this._apiService, this._ref) : super(null) {
    state = Store.I.tryGet(StoreKey.currentUser)?.toOldEntity();
    streamSub = Store.I
        .watch(StoreKey.currentUser)
        .listen((user) => state = user?.toOldEntity());
  }

  final ApiService _apiService;
  final Ref _ref;
  late final StreamSubscription<UserDto?> streamSub;

  refresh() async {
    try {
      final userDto = await _apiService.usersApi.getMyUser();
      if (userDto != null) {
        final userPreferences = await _apiService.usersApi.getMyPreferences();
        final user = User.fromUserDto(userDto, userPreferences);
        await _ref.read(userRepositoryProvider).update(user);
        await Store.I.put(StoreKey.currentUser, user.toDTO());
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    streamSub.cancel();
    super.dispose();
  }
}

final currentUserProvider =
    StateNotifierProvider<CurrentUserProvider, User?>((ref) {
  return CurrentUserProvider(ref.watch(apiServiceProvider), ref);
});

class TimelineUserIdsProvider extends StateNotifier<List<int>> {
  TimelineUserIdsProvider(Isar db, User? currentUser) : super([]) {
    final query = db.users
        .filter()
        .inTimelineEqualTo(true)
        .or()
        .idEqualTo(currentUser?.id ?? '')
        .isarIdProperty();
    query.findAll().then((users) => state = users);
    streamSub = query.watch().listen((users) => state = users);
  }

  late final StreamSubscription<List<int>> streamSub;

  @override
  void dispose() {
    streamSub.cancel();
    super.dispose();
  }
}

final timelineUsersIdsProvider =
    StateNotifierProvider<TimelineUserIdsProvider, List<int>>((ref) {
  return TimelineUserIdsProvider(
    ref.watch(dbProvider),
    ref.watch(currentUserProvider),
  );
});
