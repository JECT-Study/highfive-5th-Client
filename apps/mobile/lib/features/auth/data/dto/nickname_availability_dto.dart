import 'package:json_annotation/json_annotation.dart';

import '../../models/nickname_check_result.dart';

part 'nickname_availability_dto.g.dart';

/// `GET /api/v1/users/nickname-availability` 응답의 `data` (docs/api/profile.md).
/// 중복·형식 오류도 에러가 아니라 `available: false`로 온다.
@JsonSerializable(createToJson: false)
class NicknameAvailabilityDto {
  const NicknameAvailabilityDto({required this.available, this.reason});

  factory NicknameAvailabilityDto.fromJson(Map<String, dynamic> json) =>
      _$NicknameAvailabilityDtoFromJson(json);

  final bool available;

  /// `INVALID_LENGTH` / `INVALID_CHARACTER` / `DUPLICATED`. 쓸 수 있으면 `null`.
  final String? reason;

  /// 모르는 사유면 [NicknameCheckResult.unavailable]. 서버가 사유를 추가해도 통과시키지 않는다.
  NicknameCheckResult toModel() {
    if (available) return NicknameCheckResult.available;
    return switch (reason) {
      'INVALID_LENGTH' => NicknameCheckResult.invalidLength,
      'INVALID_CHARACTER' => NicknameCheckResult.invalidCharacter,
      'DUPLICATED' => NicknameCheckResult.duplicated,
      _ => NicknameCheckResult.unavailable,
    };
  }
}
