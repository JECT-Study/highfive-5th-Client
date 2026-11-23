import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/auth/data/repositories/auth_repository.dart';
import 'package:highfive/features/auth/data/services/auth_service.dart';
import 'package:highfive/features/auth/models/social_provider.dart';

void main() {
  test('로그인하면 서비스가 준 토큰으로 세션을 만든다', () async {
    for (final provider in SocialProvider.values) {
      final session = await AuthRepository(AuthService()).login(provider);

      expect(session.accessToken, isNotEmpty, reason: '$provider');
      expect(session.refreshToken, isNotEmpty, reason: '$provider');
    }
  });
}
