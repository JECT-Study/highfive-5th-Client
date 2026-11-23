import '../dto/token_dto.dart';

/// 로그인 API 호출.
///
/// 임시: 로그인 API가 아직 없어 받은 값과 관계없이 고정 토큰을 돌려준다
/// (workflow 3절 "서버가 아직 없을 때").
/// 실제 API가 나오면 이 파일만 바꾼다. 위 계층(Repository·ViewModel·화면)은 그대로다.
class AuthService {
  /// [provider]는 요청에 보낼 제공자 값(`kakao`·`apple`·`google`), [providerToken]은
  /// 제공자 SDK가 준 토큰(SDK 연동 전이면 빈 문자열). 필드 이름은 BE 명세가 나오면 맞춘다.
  /// 토큰은 로그에 남기지 않는다.
  Future<TokenDto> login(
    String provider, {
    required String providerToken,
  }) async {
    return TokenDto.fromJson(const {
      'accessToken': 'temporary-access-token',
      'refreshToken': 'temporary-refresh-token',
    });
  }
}
