import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/env.dart';

void main() {
  test('fromEnvironment resolves dev when no flavor is defined', () {
    final env = AppEnv.fromEnvironment();

    expect(env.flavor, Flavor.dev);
    expect(env.isDev, isTrue);
  });
}
