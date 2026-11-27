import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/auth/data/dto/nickname_availability_dto.dart';
import 'package:highfive/features/auth/data/dto/profile_dto.dart';
import 'package:highfive/features/auth/data/repositories/profile_repository.dart';
import 'package:highfive/features/auth/data/services/profile_service.dart';
import 'package:highfive/features/auth/models/next_step.dart';
import 'package:highfive/features/auth/models/nickname_check_result.dart';
import 'package:highfive/features/auth/models/profile_draft.dart';
import 'package:highfive/features/auth/models/profile_failure.dart';

/// 서버 대신 정해진 응답이나 [error]를 돌려주고 보낸 요청을 기록한다.
class _FakeProfileService extends ProfileService {
  _FakeProfileService([this.error]) : super(Dio());

  final AppException? error;
  ProfileRequestDto? request;

  @override
  Future<NicknameAvailabilityDto> checkNickname(String nickname) async {
    if (error case final error?) throw error;
    return const NicknameAvailabilityDto(
      available: false,
      reason: 'DUPLICATED',
    );
  }

  @override
  Future<ProfileResponseDto> saveProfile(ProfileRequestDto request) async {
    this.request = request;
    if (error case final error?) throw error;
    return const ProfileResponseDto(status: 'ACTIVE', nextStep: 'BAND_START');
  }
}

void main() {
  test('닉네임 확인 결과를 모델로 돌려준다', () async {
    final repository = ProfileRepository(_FakeProfileService());

    expect(
      await repository.checkNickname('두현'),
      NicknameCheckResult.duplicated,
    );
  });

  test('직접입력을 골랐으면 앞뒤 공백을 뺀 값을 보내고 nextStep을 돌려준다', () async {
    final service = _FakeProfileService();
    final repository = ProfileRepository(service);

    final nextStep = await repository.saveProfile(
      const ProfileDraft(
        nickname: '두현',
        genreCodes: ['ROCK', 'ETC'],
        genreCustomName: '  시티팝 ',
        positionCodes: ['VOCAL', 'CUSTOM'],
        positionCustomName: '하모니카',
      ),
    );

    expect(nextStep, NextStep.bandStart);
    expect(service.request?.toJson(), {
      'nickname': '두현',
      'genreCodes': ['ROCK', 'ETC'],
      'genreCustomName': '시티팝',
      'positionCodes': ['VOCAL', 'CUSTOM'],
      'positionCustomName': '하모니카',
      'profileImageUrl': null,
    });
  });

  test('직접입력을 고르지 않았으면 입력칸에 남은 값이 있어도 null로 보낸다', () async {
    final service = _FakeProfileService();
    final repository = ProfileRepository(service);

    await repository.saveProfile(
      const ProfileDraft(
        nickname: '두현',
        genreCodes: ['ROCK'],
        genreCustomName: '시티팝',
        positionCodes: ['VOCAL'],
        positionCustomName: '하모니카',
        profileImageUrl: 'https://cdn.test/users/12/profile/a.jpg',
      ),
    );

    expect(service.request?.genreCustomName, isNull);
    expect(service.request?.positionCustomName, isNull);
    expect(
      service.request?.profileImageUrl,
      'https://cdn.test/users/12/profile/a.jpg',
    );
  });

  test('서버 오류를 실패 이유로 바꾼다', () async {
    for (final (error, expected) in [
      (const NetworkException(), ProfileFailureReason.network),
      (
        const ApiException(statusCode: 409, code: 'USER_001'),
        ProfileFailureReason.nicknameTaken,
      ),
      (
        const ApiException(statusCode: 400, code: 'COMMON_004'),
        ProfileFailureReason.invalidInput,
      ),
      (
        const ApiException(statusCode: 400, code: 'USER_003'),
        ProfileFailureReason.termsRequired,
      ),
      (
        const ApiException(statusCode: 404, code: 'USER_005'),
        ProfileFailureReason.userNotFound,
      ),
      (
        const ApiException(statusCode: 500, code: 'COMMON_005'),
        ProfileFailureReason.unknown,
      ),
      (UnknownApiException(Exception()), ProfileFailureReason.unknown),
    ]) {
      final repository = ProfileRepository(_FakeProfileService(error));

      await expectLater(
        repository.saveProfile(
          const ProfileDraft(
            nickname: '두현',
            genreCodes: ['ROCK'],
            positionCodes: ['VOCAL'],
          ),
        ),
        throwsA(
          isA<ProfileFailure>().having(
            (failure) => failure.reason,
            'reason',
            expected,
          ),
        ),
        reason: '$error',
      );
    }
  });

  test('닉네임 확인 중 연결 실패도 ProfileFailure로 던진다', () async {
    final repository = ProfileRepository(
      _FakeProfileService(const NetworkException()),
    );

    await expectLater(
      repository.checkNickname('두현'),
      throwsA(
        isA<ProfileFailure>().having(
          (failure) => failure.reason,
          'reason',
          ProfileFailureReason.network,
        ),
      ),
    );
  });
}
