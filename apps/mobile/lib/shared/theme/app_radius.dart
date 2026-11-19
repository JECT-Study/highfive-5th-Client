/// 모서리 토큰(논리 픽셀). Figma 디자인 시스템 v3 공통 컴포넌트에서 쓰는 값.
/// 웹의 `--radius-*`와 같은 값을 쓴다.
abstract final class AppRadius {
  static const xs = 6.0; // TagSquare
  static const sm = 8.0; // Button Mini
  static const md = 10.0; // Input, Button XL
  static const lg = 12.0; // Button XS
  static const xl = 16.0; // 카드
  static const xxl = 20.0; // Dialog, BottomSheet 위쪽
  static const full = 999.0; // Chip, TagRound, FloatingButton (양끝 둥근 모양)
}
