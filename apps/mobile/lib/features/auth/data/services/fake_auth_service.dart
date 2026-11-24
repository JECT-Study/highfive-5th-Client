import 'package:dio/dio.dart';

import '../dto/login_response_dto.dart';
import 'auth_service.dart';

/// 임시: 로그인 서버가 열리기 전까지 명세의 200 응답 예시를 돌려준다
/// (workflow 3절 "서버가 아직 없을 때").
/// 서버가 열리면 `app/di.dart`에서 `AuthService`로 바꾸고 이 파일을 지운다.
class FakeAuthService extends AuthService {
  // 요청을 보내지 않으므로 빈 Dio를 넘긴다.
  FakeAuthService() : super(Dio());

  @override
  Future<LoginResponseDto> login(
    String provider, {
    required String providerToken,
  }) async {
    return LoginResponseDto.fromJson(const {
      'accessToken': 'fake-access-token',
      'refreshToken': 'fake-refresh-token',
      'user': {'id': 12, 'status': 'PENDING', 'nickname': null},
      'nextStep': 'TERMS',
    });
  }
}
