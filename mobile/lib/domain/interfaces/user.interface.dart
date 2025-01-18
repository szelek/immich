import 'package:immich_mobile/domain/dtos/user.dto.dart';

abstract interface class IUserRepository {
  Future<UserDto?> get(String id);
}
