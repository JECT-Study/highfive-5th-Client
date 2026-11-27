import 'package:json_annotation/json_annotation.dart';

import '../../models/next_step.dart';
import 'next_step_json.dart';

part 'profile_dto.g.dart';

/// `PUT /api/v1/users/me/profile` 요청 본문 (docs/api/profile.md).
/// 직접 입력 값·사진이 없으면 `null`을 그대로 보낸다.
@JsonSerializable(createFactory: false)
class ProfileRequestDto {
  const ProfileRequestDto({
    required this.nickname,
    required this.genreCodes,
    required this.genreCustomName,
    required this.positionCodes,
    required this.positionCustomName,
    required this.profileImageUrl,
  });

  final String nickname;

  /// `ETC`(기타)가 있으면 [genreCustomName]이 필요하다.
  final List<String> genreCodes;
  final String? genreCustomName;

  /// `CUSTOM`(직접입력)이 있으면 [positionCustomName]이 필요하다.
  final List<String> positionCodes;
  final String? positionCustomName;

  /// 업로드 URL 발급에서 받은 `fileUrl`. 건너뛰면 `null`.
  final String? profileImageUrl;

  Map<String, dynamic> toJson() => _$ProfileRequestDtoToJson(this);
}

/// `PUT /api/v1/users/me/profile` 응답의 `data`.
@JsonSerializable(createToJson: false)
class ProfileResponseDto {
  const ProfileResponseDto({required this.status, required this.nextStep});

  factory ProfileResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseDtoFromJson(json);

  /// 저장 후에는 `ACTIVE`. 앱은 아직 쓰지 않는다.
  final String status;

  /// 밴드가 없으면 `BAND_START`, 있으면 `HOME`.
  final String nextStep;

  NextStep toModel() => nextStepFromJson(nextStep);
}
