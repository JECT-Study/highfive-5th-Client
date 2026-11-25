import 'package:freezed_annotation/freezed_annotation.dart';

part 'term.freezed.dart';

/// 동의받을 약관 하나 (`GET /api/v1/terms`의 `terms[]`). docs/api/terms.md
@freezed
abstract class Term with _$Term {
  const factory Term({
    /// 동의 저장 때 `termId`로 보낸다.
    required int id,

    /// 화면에 보이는 제목 (예: `서비스 이용약관`).
    required String title,

    /// 필수 약관이면 동의해야 다음으로 갈 수 있다.
    required bool required,

    /// 본문 페이지 주소. 없으면 "보기"를 보이지 않는다 (예: 만 14세 이상 확인).
    String? contentUrl,
  }) = _Term;
}
