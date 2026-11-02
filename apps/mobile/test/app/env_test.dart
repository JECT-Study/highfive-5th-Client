import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/env.dart';

void main() {
  test('flavor 정의가 없으면 dev로 정한다', () {
    final env = AppEnv.fromEnvironment();

    expect(env.flavor, Flavor.dev);
    expect(env.isDev, isTrue);
  });
}
