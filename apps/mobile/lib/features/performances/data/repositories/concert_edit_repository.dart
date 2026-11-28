import '../../../../core/error/app_exception.dart';
import '../../models/concert_edit_failure.dart';
import '../../models/concert_edit_form.dart';
import '../../models/concert_update.dart';
import '../dto/concert_update_error_dto.dart';
import '../dto/concert_update_request_dto.dart';
import '../services/concert_edit_service.dart';

/// 공연 기본 정보 수정 계약. 실패는 [ConcertEditFailure]로 던진다.
abstract interface class ConcertEditRepository {
  /// [update]로 공연 정보를 통째로 바꾼다. 성공하면 서버가 version을 1 올린다.
  Future<void> update(int concertId, ConcertUpdate update);
}

/// 실서버 `PUT /api/v1/concerts/{concertId}`.
///
/// 공연 GET이 배포되어 상세가 실서버 값일 때만 DI에 등록한다 (app/di.dart, docs/api/concert-update.md).
/// 가짜 상세의 공연 ID·version으로 보내면 같은 ID의 다른 공연을 덮어쓸 수 있다.
class RemoteConcertEditRepository implements ConcertEditRepository {
  RemoteConcertEditRepository(this._service);

  final ConcertEditService _service;

  @override
  Future<void> update(int concertId, ConcertUpdate update) async {
    try {
      await _service.update(
        concertId,
        ConcertUpdateRequestDto.fromModel(update),
      );
    } on ConcertUpdateErrorDto catch (error) {
      throw _failureOf(error);
    }
  }

  /// 서버 오류 코드 → 실패 이유 (docs/api/concert-update.md "에러").
  static ConcertEditFailure _failureOf(ConcertUpdateErrorDto error) {
    ConcertEditFailure invalid(
      ConcertEditField field,
      ConcertEditIssue issue,
    ) => ConcertEditFailure(
      ConcertEditFailureReason.invalid,
      issues: {field: issue},
      cause: error,
    );

    return switch (error.error) {
      // 보낸 뒤 끊겼을 수도 있다. 저장 여부는 ViewModel이 상세를 다시 읽어 가린다.
      NetworkException() || UnknownApiException() => ConcertEditFailure(
        ConcertEditFailureReason.unconfirmed,
        cause: error,
      ),
      ApiException(code: 'CONCERT_012') => ConcertEditFailure(
        ConcertEditFailureReason.conflict,
        cause: error,
      ),
      ApiException(code: 'CONCERT_001') => ConcertEditFailure(
        ConcertEditFailureReason.missing,
        cause: error,
      ),
      ApiException(code: 'AUTH_005') => ConcertEditFailure(
        ConcertEditFailureReason.forbidden,
        cause: error,
      ),
      ApiException(code: 'CONCERT_002') => invalid(
        ConcertEditField.performDate,
        ConcertEditIssue.pastDate,
      ),
      ApiException(code: 'CONCERT_011') => invalid(
        ConcertEditField.performDate,
        ConcertEditIssue.beforeRecruitDeadline,
      ),
      ApiException(code: 'CONCERT_010') => invalid(
        ConcertEditField.time,
        ConcertEditIssue.timePair,
      ),
      ApiException(code: 'CONCERT_003') => invalid(
        ConcertEditField.recruitTeamCount,
        ConcertEditIssue.belowJoinedTeams,
      ),
      ApiException(code: 'COMMON_004' || 'COMMON_001') => _rejected(error),
      ApiException(:final statusCode)
          when statusCode != null && statusCode >= 500 =>
        ConcertEditFailure(ConcertEditFailureReason.unconfirmed, cause: error),
      ApiException(statusCode: 408) => ConcertEditFailure(
        ConcertEditFailureReason.unconfirmed,
        cause: error,
      ),
      ApiException() => ConcertEditFailure(
        ConcertEditFailureReason.failed,
        cause: error,
      ),
    };
  }

  /// `errors[].field`를 화면 입력칸으로 옮긴다. 화면에 없는 값(지역·포스터·version)은 입력칸이 없어
  /// 이유만 남기고, 화면은 일반 안내를 띄운다.
  static ConcertEditFailure _rejected(ConcertUpdateErrorDto error) {
    final issues = <ConcertEditField, ConcertEditIssue>{};
    final reasons = <ConcertEditField, String>{};
    for (final MapEntry(key: name, value: reason)
        in error.fieldErrors.entries) {
      final field = _fieldOf(name);
      if (field == null) continue;
      issues[field] = ConcertEditIssue.rejected;
      reasons.update(
        field,
        (previous) => '$previous\n$reason',
        ifAbsent: () => reason,
      );
    }
    return ConcertEditFailure(
      ConcertEditFailureReason.invalid,
      issues: issues,
      serverReasons: reasons,
      cause: error,
    );
  }

  /// `genres[0]`처럼 원소 위치가 붙은 이름도 앞부분으로 찾는다.
  static ConcertEditField? _fieldOf(String name) =>
      switch (name.split(RegExp(r'[.\[]')).first) {
        'title' => ConcertEditField.title,
        'genres' => ConcertEditField.genres,
        'performDate' => ConcertEditField.performDate,
        'startTime' || 'endTime' => ConcertEditField.time,
        'place' => ConcertEditField.place,
        'address' => ConcertEditField.address,
        'rentalFee' => ConcertEditField.rentalFee,
        'recruitTeamCount' => ConcertEditField.recruitTeamCount,
        _ => null,
      };
}
