import '../../models/next_step.dart';

/// 서버 `nextStep` 문자열 → [NextStep]. 로그인·약관 동의 응답이 같이 쓴다.
/// 모르는 값이면 홈으로 보낸다. 서버가 새 단계를 추가해도 앱이 멈추지 않게 한다.
NextStep nextStepFromJson(String value) => switch (value) {
  'TERMS' => NextStep.terms,
  'PROFILE' => NextStep.profile,
  'BAND_START' => NextStep.bandStart,
  _ => NextStep.home,
};
