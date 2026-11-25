import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/auth/data/dto/login_response_dto.dart';
import 'package:highfive/features/auth/models/next_step.dart';

LoginResponseDto _withNextStep(String nextStep) => LoginResponseDto.fromJson({
  'accessToken': 'a',
  'refreshToken': 'r',
  'user': {'id': 1, 'status': 'PENDING', 'nickname': null},
  'nextStep': nextStep,
});

void main() {
  test('서버 nextStep 값을 NextStep으로 바꾼다', () {
    final cases = {
      'TERMS': NextStep.terms,
      'PROFILE': NextStep.profile,
      'BAND_START': NextStep.bandStart,
      'HOME': NextStep.home,
    };
    for (final MapEntry(key: value, value: expected) in cases.entries) {
      expect(_withNextStep(value).nextStepModel, expected, reason: value);
    }
  });

  test('모르는 nextStep 값이면 홈이다', () {
    expect(_withNextStep('SOMETHING_NEW').nextStepModel, NextStep.home);
  });
}
