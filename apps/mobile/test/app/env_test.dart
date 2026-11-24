import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/env.dart';

void main() {
  test('flavor 정의가 없으면 dev로 정한다', () {
    final env = AppEnv.fromEnvironment();

    expect(env.flavor, Flavor.dev);
    expect(env.isDev, isTrue);
  });

  test('prod 이름은 prod 환경과 dev와 다른 API 주소로 정한다', () {
    final prod = AppEnv.forFlavorName('prod');

    expect(prod.flavor, Flavor.prod);
    expect(prod.isDev, isFalse);
    expect(prod.apiBaseUrl, isNot(AppEnv.forFlavorName('dev').apiBaseUrl));
  });

  test('dev와 prod는 서로 다른 카카오 앱 키를 쓴다', () {
    final dev = AppEnv.forFlavorName('dev');
    final prod = AppEnv.forFlavorName('prod');

    expect(dev.kakaoNativeAppKey, isNotEmpty);
    expect(prod.kakaoNativeAppKey, isNotEmpty);
    expect(dev.kakaoNativeAppKey, isNot(prod.kakaoNativeAppKey));
  });

  test('Google iOS 클라이언트는 flavor별로 다르고 서버 클라이언트는 같다', () {
    final dev = AppEnv.forFlavorName('dev');
    final prod = AppEnv.forFlavorName('prod');

    expect(dev.googleIosClientId, isNot(prod.googleIosClientId));
    expect(dev.googleServerClientId, prod.googleServerClientId);
    expect(dev.googleServerClientId, isNot(dev.googleIosClientId));
  });

  test('모르는 flavor 이름이면 바로 실패한다', () {
    expect(() => AppEnv.forFlavorName('staging'), throwsArgumentError);
  });
}
