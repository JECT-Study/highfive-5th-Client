/// 빌드 환경. 보통 `--flavor dev|prod`(네이티브 flavor)로 정한다.
enum Flavor { dev, prod }

/// 환경별 설정값. 앱 시작 시 한 번 만들어 get_it에 등록한다.
///
/// 네이티브 flavor(dev/prod)가 앱 ID·이름을 분리한다. `--flavor`를 주면 Flutter가
/// `FLUTTER_APP_FLAVOR`를 넣어 주므로 그 값을 먼저 읽는다.
/// `--dart-define=FLAVOR`는 flavor 없이 도는 테스트·도구용으로만 남겨 둔다.
class AppEnv {
  const AppEnv({required this.flavor, required this.apiBaseUrl});

  /// `FLUTTER_APP_FLAVOR` → `FLAVOR` 순서로 읽고, 둘 다 없으면 dev.
  /// 모르는 값이면 앱 시작 시 바로 실패한다.
  factory AppEnv.fromEnvironment() {
    const name = bool.hasEnvironment('FLUTTER_APP_FLAVOR')
        ? String.fromEnvironment('FLUTTER_APP_FLAVOR')
        : String.fromEnvironment('FLAVOR', defaultValue: 'dev');
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
