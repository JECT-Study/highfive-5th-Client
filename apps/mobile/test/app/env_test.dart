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

  test('모르는 flavor 이름이면 바로 실패한다', () {
    expect(() => AppEnv.forFlavorName('staging'), throwsArgumentError);
  });
}
