import 'concert_edit_form.dart';

/// 공연 정보를 저장하지 못한 이유. 화면은 이유별로 안내와 다음 행동을 고른다.
/// 오류 코드와 앱 처리는 docs/api/concert-update.md "에러".
enum ConcertEditFailureReason {
  /// 입력값을 서버가 받지 않았다. [ConcertEditFailure.issues]에 입력칸별 문제가 있다.
  invalid,

  /// 다른 멤버가 먼저 수정했다 (`CONCERT_012`). 최신 상세로 화면을 다시 채운다.
  conflict,

  /// 공연이 없거나 삭제됐다 (`CONCERT_001`).
  missing,

  /// 참여 팀 멤버가 아니다 (`AUTH_005`).
  forbidden,

  /// 응답을 받지 못해 저장됐는지 모른다 (연결 끊김·시간 초과 등). 실패로 단정하지 않는다.
  unconfirmed,

  /// 저장되지 않았다. 같은 version으로 다시 보내도 서버가 두 번 반영하지 않는다.
  failed,
}

/// 공연 정보 저장 실패.
class ConcertEditFailure implements Exception {
  const ConcertEditFailure(
    this.reason, {
    this.issues = const {},
    this.serverReasons = const {},
    this.cause,
  });

  final ConcertEditFailureReason reason;
  final Map<ConcertEditField, ConcertEditIssue> issues;

  /// `COMMON_004`의 `errors[].reason`. 입력칸 아래에 서버 문구를 그대로 보인다.
  final Map<ConcertEditField, String> serverReasons;

  /// 원래 오류. 디버그 로그에서 서버 오류 코드를 보려고 둔다.
  final Object? cause;

  @override
  String toString() => 'ConcertEditFailure(${reason.name}, $issues, $cause)';
}
