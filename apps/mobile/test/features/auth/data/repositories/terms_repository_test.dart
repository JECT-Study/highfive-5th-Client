import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/auth/data/dto/term_agreements_dto.dart';
import 'package:highfive/features/auth/data/dto/terms_response_dto.dart';
import 'package:highfive/features/auth/data/repositories/terms_repository.dart';
import 'package:highfive/features/auth/data/services/terms_service.dart';
import 'package:highfive/features/auth/models/next_step.dart';
import 'package:highfive/features/auth/models/term.dart';
import 'package:highfive/features/auth/models/terms_failure.dart';

/// 서버 대신 정해진 응답이나 [error]를 돌려주고 보낸 요청을 기록한다.
class _FakeTermsService extends TermsService {
  _FakeTermsService([this.error]) : super(Dio());

  final AppException? error;
  TermAgreementsRequestDto? request;

  @override
  Future<TermsResponseDto> fetchTerms() async {
    if (error case final error?) throw error;
    return const TermsResponseDto(
      terms: [
        TermDto(
          id: 1,
          code: 'SERVICE',
          title: '서비스 이용약관',
          version: '1.0',
          required: true,
          contentUrl: 'https://t/1',
        ),
        TermDto(
          id: 2,
          code: 'AGE',
          title: '만 14세 이상입니다',
          version: '1.0',
          required: true,
          contentUrl: '',
        ),
      ],
    );
  }

  @override
  Future<TermAgreementsResponseDto> saveAgreements(
    TermAgreementsRequestDto request,
  ) async {
    this.request = request;
    if (error case final error?) throw error;
    return const TermAgreementsResponseDto(nextStep: 'PROFILE');
  }
}

const _terms = [
  Term(id: 1, title: 'a', required: true),
  Term(id: 2, title: 'b', required: false),
];

void main() {
  test('목록을 모델로 바꾸고, 빈 contentUrl은 null(보기 없음)로 둔다', () async {
    final terms = await TermsRepository(_FakeTermsService()).fetchTerms();

    expect(terms.map((term) => term.id), [1, 2]);
    expect(terms[0].contentUrl, 'https://t/1');
    expect(terms[1].contentUrl, isNull);
  });

  test('받은 약관을 모두 보내고(고르지 않은 것은 agreed false) 다음 단계를 돌려준다', () async {
    final service = _FakeTermsService();

    final nextStep = await TermsRepository(service).saveAgreements(_terms, {1});

    expect(nextStep, NextStep.profile);
    expect(service.request!.toJson(), {
      'agreements': [
        {'termId': 1, 'agreed': true},
        {'termId': 2, 'agreed': false},
      ],
    });
  });

  test('서버 오류를 실패 이유로 바꾼다', () async {
    Future<TermsFailureReason> reasonOf(AppException error) async {
      try {
        await TermsRepository(_FakeTermsService(error))
            .saveAgreements(_terms, {1});
      } on TermsFailure catch (failure) {
        return failure.reason;
      }
      fail('TermsFailure를 던져야 한다');
    }

    expect(
      await reasonOf(const NetworkException()),
      TermsFailureReason.network,
    );
    expect(
      await reasonOf(const ApiException(statusCode: 400, code: 'COMMON_004')),
      TermsFailureReason.termsChanged,
    );
    expect(
      await reasonOf(const ApiException(statusCode: 400, code: 'USER_003')),
      TermsFailureReason.unknown,
    );
  });
}
