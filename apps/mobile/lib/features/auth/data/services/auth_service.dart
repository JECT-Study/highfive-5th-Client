import '../dto/token_dto.dart';

/// 로그인 API 호출.
///
/// 임시: 소셜 SDK·로그인 API가 아직 없어 [provider]와 관계없이 고정 토큰을 돌려준다
/// (workflow 3절 "서버가 아직 없을 때").
/// 실제 연동이 나오면 이 파일만 바꾼다. 위 계층(Repository·ViewModel·화면)은 그대로다.
class AuthService {
  /// [provider]는 요청에 보낼 제공자 값(`kakao`·`apple`·`google`). BE 명세가 나오면 맞춘다.
  Future<TokenDto> login(String provider) async {
    return TokenDto.fromJson(const {
      'accessToken': 'temporary-access-token',
      'refreshToken': 'temporary-refresh-token',
    });
  }
}
