/// 간격 토큰(논리 픽셀, 4 배수). 웹의 `--space-N`과 같은 번호를 쓴다.
/// 위젯에서 `EdgeInsets.all(16)`처럼 숫자를 직접 쓰지 않는다.
abstract final class AppSpacing {
  static const x1 = 4.0;
  static const x2 = 8.0;
  static const x3 = 12.0;
  static const x4 = 16.0;
  static const x6 = 24.0;
  static const x8 = 32.0;
}
