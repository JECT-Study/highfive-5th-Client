/// 빌드 환경. 보통 `--flavor dev|prod`(네이티브 flavor)로 정한다.
enum Flavor { dev, prod }

/// 환경별 설정값. 앱 시작 시 한 번 만들어 get_it에 등록한다.
///
/// 네이티브 flavor(dev/prod)가 앱 ID·이름을 분리한다. `--flavor`를 주면 Flutter가
/// `FLUTTER_APP_FLAVOR`를 넣어 주므로 그 값을 먼저 읽는다.
/// `--dart-define=FLAVOR`는 flavor 없이 도는 테스트·도구용으로만 남겨 둔다.
class AppEnv {
  const AppEnv({
    required this.flavor,
    required this.apiBaseUrl,
    required this.kakaoNativeAppKey,
    required this.googleIosClientId,
    required this.googleServerClientId,
  });

  /// `FLUTTER_APP_FLAVOR` → `FLAVOR` 순서로 읽고, 둘 다 없으면 dev.
  /// 모르는 값이면 앱 시작 시 바로 실패한다.
  factory AppEnv.fromEnvironment() {
    const name = bool.hasEnvironment('FLUTTER_APP_FLAVOR')
        ? String.fromEnvironment('FLUTTER_APP_FLAVOR')
        : String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    return AppEnv.forFlavorName(name);
  }

  /// flavor 이름으로 환경값을 고른다. 모르는 이름이면 [ArgumentError].
  factory AppEnv.forFlavorName(String name) {
    return switch (Flavor.values.byName(name)) {
      Flavor.dev => const AppEnv(
        flavor: Flavor.dev,
        // dev 서버. DB는 개발 중 초기화될 수 있다.
        apiBaseUrl: 'https://dev-api.highfive-app.link',
        kakaoNativeAppKey: '8f7351ffe7f85cf74698761a2029c90e', // Dev 키
        googleIosClientId: '620350281095-0h5cs8o86celcea40kv3u22gp3994n3a.apps.googleusercontent.com',
        googleServerClientId: _googleServerClientId,
      ),
      Flavor.prod => const AppEnv(
        flavor: Flavor.prod,
        // TODO(BE): prod API 주소 확정 후 교체
        apiBaseUrl: 'https://api.highfive.example',
        kakaoNativeAppKey: '68320ddfa8016bae212ff9306cf24c8d', // Default 키
        googleIosClientId: '620350281095-gadtuaqoi2aatm5bcgapgcgcq14eem35.apps.googleusercontent.com',
        googleServerClientId: _googleServerClientId,
      ),
    };
  }

  final Flavor flavor;
  final String apiBaseUrl;

  /// 카카오 네이티브 앱 키. 같은 값이 네이티브 설정에도 있다 (iOS 빌드 설정
  /// `KAKAO_NATIVE_APP_KEY`, Android `build.gradle.kts`의 `manifestPlaceholders`). 바꿀 때 셋 다 바꾼다.
  final String kakaoNativeAppKey;

  /// Google OAuth iOS 클라이언트 ID (bundle ID별). iOS 빌드 설정 `GOOGLE_REVERSED_CLIENT_ID`에
  /// 뒤집은 값이 같이 있다. Android는 패키지명·SHA-1로 Google 콘솔에서 알아보므로 코드에 ID가 없다.
  final String googleIosClientId;

  /// Google OAuth 웹(서버) 클라이언트 ID. 로그인 ID 토큰이 이 서버용으로 나오고 BE가 이 값으로 검증한다.
  final String googleServerClientId;

  static const _googleServerClientId =
      '620350281095-d3ubpmrm04ipo0gakrommsd3l7qjs4h0.apps.googleusercontent.com';

  bool get isDev => flavor == Flavor.dev;
}
