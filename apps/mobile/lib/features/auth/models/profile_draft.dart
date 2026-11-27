import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_draft.freezed.dart';

/// 저장할 개인 프로필 입력 (docs/api/profile.md `PUT /users/me/profile`).
/// 장르·포지션은 서버 코드 그대로 담는다 (예: `ROCK`, `VOCAL`).
@freezed
abstract class ProfileDraft with _$ProfileDraft {
  const factory ProfileDraft({
    required String nickname,

    /// 고른 순서대로. [genreCustomCode]가 있으면 [genreCustomName]을 보낸다.
    required List<String> genreCodes,
    String? genreCustomName,

    /// 고른 순서대로. [positionCustomCode]가 있으면 [positionCustomName]을 보낸다.
    required List<String> positionCodes,
    String? positionCustomName,

    /// 업로드한 사진 주소. 건너뛰면 null (기본 이미지).
    String? profileImageUrl,
  }) = _ProfileDraft;

  /// 장르 "직접입력" 코드 (서버 이름은 기타).
  static const genreCustomCode = 'ETC';

  /// 포지션 "직접입력" 코드.
  static const positionCustomCode = 'CUSTOM';
}
