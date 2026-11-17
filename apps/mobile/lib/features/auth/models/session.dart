import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';

/// 로그인 세션. 토큰이 로그에 찍히지 않게 toString을 만들지 않는다.
@Freezed(toStringOverride: false)
abstract class Session with _$Session {
  const factory Session({required String accessToken, String? refreshToken}) =
      _Session;
}
