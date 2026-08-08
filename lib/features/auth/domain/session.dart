import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';

@freezed
abstract class Session with _$Session {
  const factory Session({
    required String token,
    required int userId,
    required String username,
  }) = _Session;
}