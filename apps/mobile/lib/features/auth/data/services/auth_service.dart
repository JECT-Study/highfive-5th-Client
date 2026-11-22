import '../dto/token_dto.dart';

/// 로그인 API 호출.
///
/// 임시: 로그인 API가 아직 없어 고정 토큰을 돌려준다 (workflow 3절 "서버가 아직 없을 때").
/// 실제 API가 나오면 이 파일만 Dio 호출로 바꾼다. 위 계층(Repository·ViewModel·화면)은 그대로다.
class AuthService {
  Future<TokenDto> login() async {
    return TokenDto.fromJson(const {
      'accessToken': 'temporary-access-token',
      'refreshToken': 'temporary-refresh-token',
    });
  }
}
