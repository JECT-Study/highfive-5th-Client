import 'concert_genre.dart';

/// 생성 폼에서 고칠 수 있는 항목. 순서는 화면 위에서 아래 순서다.
enum ConcertDraftField {
  title,
  genres,
  performDate,
  recruitTeamCount,
  rentalFee,
}

/// 항목을 고쳐야 하는 이유. 안내 문구는 화면이 정한다.
enum ConcertDraftError {
  /// 비었다 (제목·장르·날짜, 미정이 아닌데 비운 대관비).
  missing,

  /// 제목이 [ConcertDraft.titleMaxLength]자를 넘는다.
  tooLong,

  /// 오늘보다 이전 날짜다.
  pastDate,

  /// 모집할 팀 수가 [ConcertDraft.minRecruitTeamCount]보다 적다.
  belowMinimum,

  /// 대관비가 숫자가 아니거나 [ConcertDraft.rentalFeeMax]원을 넘는다.
  invalidAmount,
}

/// 합동공연 만들기 폼의 입력값. Swagger `ConcertCreateRequest` 검증과 같은 규칙으로 [validate]한다.
///
/// Figma 생성 화면(2217:123040)에 없는 시작·종료 시간과, 아직 열 수 없는 장소 검색 결과(장소·주소·지역)·포스터는 담지 않는다.
class ConcertDraft {
  const ConcertDraft({
    required this.title,
    required this.genres,
    required this.recruitTeamCount,
    required this.performDate,
    required this.rentalFeeUndecided,
    required this.rentalFeeText,
  });

  /// 서버 `title` 최대 길이.
  static const titleMaxLength = 30;

  /// 서버 `rentalFee`(Integer) 최댓값.
  static const rentalFeeMax = 2147483647;

  /// 모집할 팀 수 최솟값. 주최 팀은 빼고 센다 (서버 `recruitTeamCount` 1 이상).
  static const minRecruitTeamCount = 1;

  static final _digits = RegExp(r'^\d+$');

  final String title;
  final Set<ConcertGenre> genres;
  final int recruitTeamCount;
  final DateTime? performDate;

  /// 전체 대관비 "아직 미정이에요".
  final bool rentalFeeUndecided;
  final String rentalFeeText;

  /// 보낼 대관비. 미정이면 null. [validate]를 통과한 값에서만 읽는다.
  int? get rentalFee =>
      rentalFeeUndecided ? null : int.parse(rentalFeeText.trim());

  /// 고쳐야 할 항목. 비어 있으면 보낼 수 있다. [today]의 시각은 보지 않는다.
  Map<ConcertDraftField, ConcertDraftError> validate({
    required DateTime today,
  }) {
    final errors = <ConcertDraftField, ConcertDraftError>{};
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      errors[ConcertDraftField.title] = ConcertDraftError.missing;
    } else if (trimmedTitle.length > titleMaxLength) {
      errors[ConcertDraftField.title] = ConcertDraftError.tooLong;
    }
    if (genres.isEmpty) {
      errors[ConcertDraftField.genres] = ConcertDraftError.missing;
    }
    final date = performDate;
    if (date == null) {
      errors[ConcertDraftField.performDate] = ConcertDraftError.missing;
    } else if (_dateOnly(date).isBefore(_dateOnly(today))) {
      errors[ConcertDraftField.performDate] = ConcertDraftError.pastDate;
    }
    if (recruitTeamCount < minRecruitTeamCount) {
      errors[ConcertDraftField.recruitTeamCount] =
          ConcertDraftError.belowMinimum;
    }
    if (!rentalFeeUndecided) {
      final fee = rentalFeeText.trim();
      if (fee.isEmpty) {
        errors[ConcertDraftField.rentalFee] = ConcertDraftError.missing;
      } else if (!_digits.hasMatch(fee) ||
          (int.tryParse(fee) ?? rentalFeeMax + 1) > rentalFeeMax) {
        errors[ConcertDraftField.rentalFee] = ConcertDraftError.invalidAmount;
      }
    }
    return errors;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
