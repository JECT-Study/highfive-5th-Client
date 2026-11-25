import 'package:json_annotation/json_annotation.dart';

import '../../models/next_step.dart';
import 'next_step_json.dart';

part 'term_agreements_dto.g.dart';

/// `POST /api/v1/users/me/term-agreements` 요청 본문 (docs/api/terms.md).
/// 목록에서 받은 약관을 모두 보낸다. 선택 약관을 거부하면 `agreed: false`.
@JsonSerializable(createFactory: false, explicitToJson: true)
class TermAgreementsRequestDto {
  const TermAgreementsRequestDto({required this.agreements});

  final List<TermAgreementDto> agreements;

  Map<String, dynamic> toJson() => _$TermAgreementsRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
class TermAgreementDto {
  const TermAgreementDto({required this.termId, required this.agreed});

  final int termId;
  final bool agreed;

  Map<String, dynamic> toJson() => _$TermAgreementDtoToJson(this);
}

/// `POST /api/v1/users/me/term-agreements` 응답의 `data`.
@JsonSerializable(createToJson: false)
class TermAgreementsResponseDto {
  const TermAgreementsResponseDto({required this.nextStep});

  factory TermAgreementsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TermAgreementsResponseDtoFromJson(json);

  /// `TERMS` / `PROFILE` / `BAND_START` / `HOME`.
  final String nextStep;

  NextStep toModel() => nextStepFromJson(nextStep);
}
