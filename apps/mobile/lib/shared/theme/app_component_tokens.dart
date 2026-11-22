import 'app_radius.dart';

/// 컴포넌트 토큰: Figma 디자인 시스템 v3 공통 컴포넌트(Button·Input·Chip·Tag)의 크기·여백·모서리.
/// 웹의 `--button-*`, `--input-*`, `--chip-*`, `--tag-*`와 같은 값을 쓴다.
/// 색은 여기 두지 않는다. 위젯이 의미 색 토큰(`context.colors.*`)을 고른다 (docs/design-tokens.md 3절).
/// 이 파일의 숫자는 해당 컴포넌트 위젯(`shared/widgets/`) 안에서만 쓴다.

/// Button (Figma `Btn`). 크기 이름은 Figma Property: XL → large, XS → medium, Mini → small.
abstract final class AppButtonTokens {
  static const largeHeight = 52.0;
  static const mediumHeight = 42.0;
  static const smallHeight = 32.0;

  static const largePaddingX = 30.0;
  static const mediumPaddingX = 20.0;
  static const smallPaddingX = 8.0;

  /// 아이콘과 글자 사이.
  static const largeGap = 2.0;
  static const mediumGap = 4.0;
  static const smallGap = 6.0;

  static const largeRadius = AppRadius.md;
  static const mediumRadius = AppRadius.lg;
  static const smallRadius = AppRadius.sm;

  static const iconSize = 24.0;
  static const smallIconSize = 16.0;

  /// FloatingButton: 양끝이 둥글고 왼쪽(아이콘 쪽) 여백이 2 작다.
  static const floatingPaddingLeft = 14.0;
  static const floatingPaddingRight = 16.0;
  static const floatingPaddingY = 12.0;
  static const floatingGap = 4.0;
  static const floatingRadius = AppRadius.full;

  /// 로딩 점 3개 (Figma `loader`).
  static const loaderDotSize = 6.0;
  static const loaderDotGap = 8.0;
}

/// Input (Figma `Input`).
abstract final class AppInputTokens {
  static const height = 47.0;
  static const paddingX = 14.0;
  static const gap = 10.0;
  static const radius = AppRadius.md;
}

/// Chip (Figma `Chip`, `SocialLinkChip`).
abstract final class AppChipTokens {
  static const paddingX = 12.0;
  static const paddingY = 8.0;
  static const radius = AppRadius.full;
}

/// Tag (Figma `TagSquare`, `TagRound`). 누를 수 없는 라벨.
abstract final class AppTagTokens {
  static const squarePaddingX = 8.0;
  static const squarePaddingY = 5.0;
  static const squareRadius = AppRadius.xs;

  /// TagRound 크기별 여백. Figma M → small, L → medium, XL → large.
  static const roundSmallPadding = 8.0;
  static const roundMediumPaddingX = 10.0;
  static const roundMediumPaddingY = 6.0;
  static const roundLargePaddingX = 10.0;
  static const roundLargePaddingY = 4.0;
  static const roundRadius = AppRadius.full;
}

/// TextArea (Figma `TextArea`). 테두리·모서리는 Input과 같다.
abstract final class AppTextAreaTokens {
  static const height = 100.0;
  static const padding = 14.0;
  static const radius = AppRadius.md;
}

/// Dropdown (Figma `Dropdown`). 높이·여백은 Input과 같고 오른쪽에 화살표 18.
abstract final class AppDropdownTokens {
  static const iconSize = 18.0;
}

/// Checkbox·Radio·Toggle. 누르는 영역은 모두 44 (Figma Radio Button 크기).
abstract final class AppSelectionTokens {
  static const touchSize = 44.0;
  static const checkboxSize = 14.0;
  static const checkboxRadius = 2.0;
  static const radioSize = 22.0;
  static const radioDotSize = 10.0;
  static const toggleWidth = 50.0;
  static const toggleHeight = 26.0;
  static const toggleThumbSize = 16.0;
  static const toggleThumbInset = 5.0;
}

/// Filter (Figma `Filter`). 목록 위 거르기 버튼. 글자 뒤에 화살표 18.
abstract final class AppFilterTokens {
  static const paddingX = 12.0;
  static const paddingY = 8.0;
  static const gap = 2.0;
  static const iconSize = 18.0;
  static const radius = AppRadius.full;
}

/// Notice (Figma `Notice`). 안내·경고 띠.
abstract final class AppNoticeTokens {
  static const paddingX = 12.0;
  static const paddingY = 10.0;
  static const gap = 4.0;
  static const iconSize = 24.0;
  static const radius = AppRadius.md;
}

/// Dialog (Figma `Dialog`).
abstract final class AppDialogTokens {
  static const width = 323.0;
  static const paddingTop = 30.0;
  static const paddingX = 10.0;
  static const paddingBottom = 10.0;
  static const gap = 20.0;
  static const buttonGap = 8.0;
  static const radius = AppRadius.xxl;
}

/// BottomSheet (Figma `BottomSheet`)와 그 안의 ModalHeader.
abstract final class AppBottomSheetTokens {
  static const paddingTop = 12.0;
  static const paddingX = 20.0;
  static const paddingBottom = 34.0;
  static const gap = 16.0;
  static const radius = AppRadius.xxl;
  static const handleWidth = 40.0;
  static const handleHeight = 4.0;
  static const handleRadius = 2.0;
  static const headerGap = 8.0;
}

/// ListRow (Figma `ListRow`). 설정·메뉴 목록 한 줄.
abstract final class AppListRowTokens {
  static const height = 44.0;
  static const paddingX = 10.0;
  static const gap = 10.0;
  static const iconSize = 24.0;
  static const trailingWidth = 52.0;
}

/// TabList (Figma `TabList`). 화면 안 상단 탭 (예: 정보·피드·일정).
abstract final class AppTabListTokens {
  static const height = 44.0;
  static const paddingX = 12.0;
  static const indicatorHeight = 2.0;
}

/// Top (Figma `Top` Default). 화면 상단 앱바와 IconButton.
abstract final class AppTopBarTokens {
  static const height = 56.0;
  static const paddingX = 6.0;
  static const iconButtonSize = 44.0;
  static const iconSize = 24.0;
}

/// Badge (Figma `Badge`의 숫자 동그라미).
abstract final class AppBadgeTokens {
  /// 지름. 숫자가 길어져도 늘어나지 않는 원이다.
  static const size = 20.0;

  /// 글자가 원 테두리에 닿지 않게 두는 안쪽 여백 (`99+`가 줄어드는 기준).
  static const innerPadding = 2.0;
}

/// Divider (Figma `Divider`). 구역 사이 두꺼운 구분 띠.
abstract final class AppDividerTokens {
  static const thickness = 10.0;
}

/// ProgressBar (Figma `ProgressBar`). 단계 막대.
abstract final class AppProgressTokens {
  static const paddingX = 8.0;
  static const labelGap = 6.0;
  static const barPaddingTop = 8.0;
  static const barPaddingBottom = 18.0;
  static const segmentHeight = 4.0;
  static const segmentGap = 4.0;
  static const segmentRadius = 2.0;
}

/// InputCount (Figma `InputCount`). 숫자 올리고 내리기.
abstract final class AppStepperTokens {
  static const buttonSize = 44.0;
  static const radius = AppRadius.md;
}

/// 하단 탭 바 (Figma `NavEX`). 라벨은 Caption-1 글자 토큰을 쓴다.
abstract final class AppBottomNavTokens {
  static const paddingY = 12.0;
  static const iconSize = 24.0;
  static const iconLabelGap = 2.0;
}

/// FormSection (Figma `FormSection`). 폼 제목 + 힌트 + 입력물.
abstract final class AppFormSectionTokens {
  static const gap = 8.0;
}
