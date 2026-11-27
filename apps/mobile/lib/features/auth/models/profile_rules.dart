/// 닉네임·직접입력 값 규칙 (docs/api/profile.md). 서버와 같은 규칙으로 버튼을 막는다.
/// 최종 판단은 서버가 한다.
library;

import 'nickname_check_result.dart';

/// 완성형 한글·영문·숫자만.
final _allowed = RegExp(r'^[가-힣a-zA-Z0-9]+$');

const nicknameMinLength = 2;
const nicknameMaxLength = 10;
const customNameMaxLength = 10;

/// 프로필 사진 최대 용량 (기능명세서 "사진 1장당 최대 10MB").
const profilePhotoMaxBytes = 10 * 1024 * 1024;

/// 닉네임 형식 검사. 맞으면 null, 틀리면 이유
/// ([NicknameCheckResult.invalidCharacter] 먼저, 그다음 [NicknameCheckResult.invalidLength]).
/// 공백·이모지·특수문자와 조합이 끝나지 않은 자음·모음(예: `ㄷ`)은 허용하지 않는다.
/// 영문 대소문자는 다른 글자로 본다. 중복 여부는 서버가 본다.
NicknameCheckResult? validateNickname(String value) {
  if (!_allowed.hasMatch(value)) return NicknameCheckResult.invalidCharacter;
  if (value.length < nicknameMinLength || value.length > nicknameMaxLength) {
    return NicknameCheckResult.invalidLength;
  }
  return null;
}

/// 장르·포지션 직접입력 값. 앞뒤 공백을 빼고 1~10자, 한글·영문·숫자만.
bool isValidCustomName(String value) {
  final trimmed = value.trim();
  return trimmed.length <= customNameMaxLength && _allowed.hasMatch(trimmed);
}
