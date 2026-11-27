/// 닉네임·직접입력 값 규칙 (docs/api/profile.md). 서버와 같은 규칙으로 버튼을 막는다.
/// 최종 판단은 서버가 한다.
library;

/// 완성형 한글·영문·숫자만.
final _allowed = RegExp(r'^[가-힣a-zA-Z0-9]+$');

/// 입력 중에는 자음·모음만 있는 글자(예: `ㄷ`)도 허용한다. 한글을 조합하는 동안
/// 안내가 깜빡이지 않게 한다. 조합이 끝나지 않은 채 남으면 [isValidNickname]이 막는다.
final _allowedWhileTyping = RegExp(r'^[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]*$');

const nicknameMinLength = 2;
const nicknameMaxLength = 10;
const customNameMaxLength = 10;

/// 공백·이모지·특수문자가 있다. 화면은 바로 "한글, 영문, 숫자만 쓸 수 있어요"를 보인다.
bool hasForbiddenCharacter(String value) =>
    !_allowedWhileTyping.hasMatch(value);

bool hasValidNicknameLength(String value) =>
    value.length >= nicknameMinLength && value.length <= nicknameMaxLength;

/// 2~10자, 완성형 한글·영문·숫자만. 영문 대소문자는 다른 글자로 본다.
bool isValidNickname(String value) =>
    hasValidNicknameLength(value) && _allowed.hasMatch(value);

/// 장르·포지션 직접입력 값. 앞뒤 공백을 빼고 1~10자, 한글·영문·숫자만.
bool isValidCustomName(String value) {
  final trimmed = value.trim();
  return trimmed.length <= customNameMaxLength && _allowed.hasMatch(trimmed);
}
