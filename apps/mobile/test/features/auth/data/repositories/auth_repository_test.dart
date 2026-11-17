import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/auth/data/repositories/auth_repository.dart';
import 'package:highfive/features/auth/data/services/auth_service.dart';

void main() {
  test('로그인하면 서비스가 준 토큰으로 세션을 만든다', () async {
    final session = await AuthRepository(AuthService()).login();

    expect(session.accessToken, isNotEmpty);
    expect(session.refreshToken, isNotEmpty);
  });
}
