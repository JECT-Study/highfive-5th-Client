import '../../../../core/error/app_exception.dart';
import '../../models/next_step.dart';
import '../../models/term.dart';
import '../../models/terms_failure.dart';
import '../dto/term_agreements_dto.dart';
import '../services/terms_service.dart';

/// 약관 목록을 받고 동의를 저장한다. 서버 오류는 [TermsFailure]로 바꿔 던진다.
class TermsRepository {
  TermsRepository(this._service);

  final TermsService _service;

  /// 서버 순서 그대로 (필수 → 선택).
  Future<List<Term>> fetchTerms() async {
    try {
      return (await _service.fetchTerms()).toModel();
    } on AppException catch (error) {
      throw TermsFailure(_reasonOf(error), error);
    }
  }

  /// [terms] 전부를 보낸다. [agreedIds]에 있으면 동의, 없으면 거부.
  /// 돌려주는 값은 서버가 정한 다음 화면.
  Future<NextStep> saveAgreements(List<Term> terms, Set<int> agreedIds) async {
    final request = TermAgreementsRequestDto(
      agreements: [
        for (final term in terms)
          TermAgreementDto(
            termId: term.id,
            agreed: agreedIds.contains(term.id),
          ),
      ],
    );
    try {
      return (await _service.saveAgreements(request)).toModel();
    } on AppException catch (error) {
      throw TermsFailure(_reasonOf(error), error);
    }
  }

  /// 서버 오류 코드 → 실패 이유 (docs/api/terms.md "에러").
  static TermsFailureReason _reasonOf(AppException error) => switch (error) {
    NetworkException() => TermsFailureReason.network,
    ApiException(code: 'COMMON_004') => TermsFailureReason.termsChanged,
    ApiException() || UnknownApiException() => TermsFailureReason.unknown,
  };
}
