/// 간격 토큰(논리 픽셀). 이름의 숫자 × 4 = 값이고, 웹의 `--space-N`과 같은 번호를 쓴다.
/// 위젯에서 `EdgeInsets.all(16)`처럼 숫자를 직접 쓰지 않는다.
/// 반 단계(x0_5, x1_5 …)는 Figma 컴포넌트가 실제로 쓰는 2·6·10·14 때문에 둔다.
abstract final class AppSpacing {
  static const x0_5 = 2.0;
  static const x1 = 4.0;
  static const x1_5 = 6.0;
  static const x2 = 8.0;
  static const x2_5 = 10.0;
  static const x3 = 12.0;
  static const x3_5 = 14.0;
  static const x4 = 16.0;
  static const x5 = 20.0;
  static const x6 = 24.0;
  static const x8 = 32.0;
}
