/// 빌드 환경. `--dart-define=FLAVOR=dev|prod` 로 정한다.
enum Flavor { dev, prod }

/// 환경별 설정값. 앱 시작 시 한 번 만들어 get_it에 등록한다.
///
/// 네이티브 flavor(앱 ID·이름 분리)는 아직 없다. 지금은 Dart 쪽 분기만 한다.
class AppEnv {
  const AppEnv({required this.flavor, required this.apiBaseUrl});

  /// `FLAVOR`를 지정하지 않으면 dev. 모르는 값이면 앱 시작 시 바로 실패한다.
  factory AppEnv.fromEnvironment() {
    const name = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    return switch (Flavor.values.byName(name)) {
      Flavor.dev => const AppEnv(
        flavor: Flavor.dev,
        // TODO(BE): dev API 주소 확정 후 교체
        apiBaseUrl: 'https://dev-api.highfive.example',
      ),
      Flavor.prod => const AppEnv(
        flavor: Flavor.prod,
        // TODO(BE): prod API 주소 확정 후 교체
        apiBaseUrl: 'https://api.highfive.example',
      ),
    };
  }

  final Flavor flavor;
  final String apiBaseUrl;

  bool get isDev => flavor == Flavor.dev;
}
