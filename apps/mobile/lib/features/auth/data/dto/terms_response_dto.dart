import 'package:json_annotation/json_annotation.dart';

import '../../models/term.dart';

part 'terms_response_dto.g.dart';

/// `GET /api/v1/terms` 응답의 `data` (docs/api/terms.md).
@JsonSerializable(createToJson: false)
class TermsResponseDto {
  const TermsResponseDto({required this.terms});

  factory TermsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TermsResponseDtoFromJson(json);

  /// 필수 → 선택 순서.
  final List<TermDto> terms;

  List<Term> toModel() => [for (final term in terms) term.toModel()];
}

@JsonSerializable(createToJson: false)
class TermDto {
  const TermDto({
    required this.id,
    required this.code,
    required this.title,
    required this.version,
    required this.required,
    required this.contentUrl,
  });

  factory TermDto.fromJson(Map<String, dynamic> json) =>
      _$TermDtoFromJson(json);

  final int id;

  /// 약관 종류 코드. 앱은 아직 쓰지 않는다.
  final String code;
  final String title;

  /// 약관 버전. 앱은 아직 쓰지 않는다 (동의 저장은 `id`로 한다).
  final String version;
  final bool required;

  /// 본문 페이지 주소. 비어 있으면 앱은 "보기"를 숨긴다.
  final String contentUrl;

  Term toModel() => Term(
    id: id,
    title: title,
    required: required,
    contentUrl: contentUrl.isEmpty ? null : contentUrl,
  );
}
