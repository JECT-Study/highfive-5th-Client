import 'package:freezed_annotation/freezed_annotation.dart';

import 'next_step.dart';

part 'session.freezed.dart';

/// 로그인 세션. 토큰이 로그에 찍히지 않게 toString을 만들지 않는다.
@Freezed(toStringOverride: false)
abstract class Session with _$Session {
  const factory Session({
    required String accessToken,
    String? refreshToken,

    /// 로그인 뒤 거쳐야 할 화면 (서버 `nextStep`). 라우터가 이것으로 약관 동의 등을 고른다.
    /// 로그인·약관 동의 응답에서만 받는다. 모르면 홈.
    @Default(NextStep.home) NextStep nextStep,
  }) = _Session;
}
