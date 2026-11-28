# 디자인 토큰

색·간격·모서리·글자 크기 값을 한 곳에서 정하고, 앱과 웹이 같은 이름·같은 값을 쓰게 하는 규칙이다.

## 1. 원칙

- **기준은 이 문서의 표**다. Figma 변수가 생기면 그 이름을 그대로 따라 표를 고친다.
- **두 단계**: 원시(primitive) 토큰(`pink.500`, `gray.200`)은 팔레트, 의미(semantic) 토큰(`label.normal`, `line.normal`)은 쓰임새. 화면 코드는 **의미 토큰만** 쓴다. 원시 토큰은 토큰 파일 안에서만 참조한다. 디자인이 바뀌면 의미 토큰이 가리키는 원시 값만 바꾸면 되고 화면 코드는 그대로다.
- **앱과 웹은 각자 파일에 손으로 같은 값을 둔다.** 토큰이 수십 개 수준이라 생성 도구(Style Dictionary 등)보다 손 동기화가 단순하다. 토큰이 100개를 넘거나 다크 모드가 들어오면 그때 생성 도구를 검토한다.

| 위치 | 파일 |
| --- | --- |
| 기준 | `docs/design-tokens.md` (이 문서) |
| 앱 | `apps/mobile/lib/shared/theme/app_colors.dart`, `app_spacing.dart`, `app_radius.dart`, `app_typography.dart`, `app_shadows.dart`, `app_component_tokens.dart`, 글꼴 `assets/fonts/pretendard/` |
| 웹 | `apps/web/src/shared/styles/tokens.css` |

## 2. 바꾸는 절차

1. 디자이너와 값·이름 확정
2. 이 문서의 표 수정
3. 앱 파일과 웹 파일을 같이 수정
4. 한 PR에 셋 다 넣고, 바뀐 화면 캡처(앱·웹) 첨부
5. 상대 리뷰 (토큰은 "사전 공유" 대상)

한쪽만 바꾸지 않는다. 새 토큰이 필요하면 먼저 기존 토큰으로 안 되는지 본다.

토큰이 아닌 값도 있다: 레이아웃 폭(`max-width`, breakpoint), `1px` 테두리, 진행률 같은 동적 값, 특정 일러스트 크기. 이건 그 컴포넌트 CSS·위젯 안에 두고 그 줄에 짧게 이유를 남긴다. 반대로 **색·간격·모서리·글자 크기는 한 화면용이라도 기존 토큰 단계 중에서 고른다.** 단계에 없는 값이 정말 필요하면 디자이너와 앱 전체에서 쓸 범용 단계(예: `space.5`)로 추가한다. 특정 화면 이름이 붙은 토큰(예: `loginTitleGap`)은 만들지 않는다. 예외가 두 번째 쓰임을 얻으면 토큰으로 올린다.

## 3. 토큰 표

색·글자·그림자는 Figma 디자인 시스템 v3 기준이다. 2026-11 디자이너가 "너무 연해서" 반투명 회색(Label·Line·Fill)을 불투명 색으로 바꾸고 Status/Destructive·Line/Strong을 바꾼 변수 값을 따른다 (Figma `디자인` 파일 변수). 모서리는 v3 공통 컴포넌트(Button·Input·Chip·Tag)에서 쓰는 값이다. 간격은 Figma에 아직 없어 임시값이다.
2026-11-26 디자인 시스템 v4(`디자인시스템_v4` 페이지)와 대조해 바뀐 값(Pink-50·600·700, Background/Warning, Head(B), 입력창·칩 테두리 안쪽 여백)을 반영했다. 근거와 디자이너 확인 항목은 아래 [v4 대조](#v4-대조-2026-11-26)에 모았다.

### 색 — 원시 (토큰 파일 안에서만)

Figma 디자인 시스템 v3 Primitive (Neutral → `gray`, Primary-Pink → `pink`, Primary-Blue → `blue`).
(미사용)은 아직 어떤 의미 토큰도 가리키지 않아 토큰 파일에 없다. 처음 쓸 때 앱·웹 토큰 파일에 같이 추가한다.

| 이름 | 값 |
| --- | --- |
| gray.50 | `#F7F7F7` (미사용) |
| gray.100 | `#EBEBEC` (미사용) |
| gray.200 | `#E2E2E2` (미사용) |
| gray.300 | `#D3D3D3` (미사용) |
| gray.400 | `#B1B1B2` (미사용) |
| gray.500 | `#858586` (미사용) |
| gray.700 | `#545456` (미사용) |
| gray.800 | `#0B0B0C` |
| pink.50 | `#FFD6E9` |
| pink.300 | `#FF5FA6` |
| pink.500 | `#FF2F8C` |
| pink.600 | `#DC136C` |
| pink.700 | `#8E0341` |
| blue.50 | `#E9F4FF` |
| blue.500 | `#2F97FF` |
| blue.600 | `#2887E6` |
| blue.700 | `#1A6EC2` |
| white | `#FFFFFF` |
| black | `#000000` |

### 색 — 의미 (화면 코드가 쓰는 것)

Figma Semantic 이름 그대로. 앱은 `context.colors.<앱 이름>`, 웹은 `var(<웹 이름>)`.
Figma Semantic 값이 원시 팔레트에 없으면 토큰 파일의 의미 토큰에 값을 그대로 둔다. %는 불투명도.

| 이름 | 값 | 앱 | 웹 | 쓰임 |
| --- | --- | --- | --- | --- |
| label.normal | `#171719` | `labelNormal` | `--color-label-normal` | 본문 글자 |
| label.strong | black | `labelStrong` | `--color-label-strong` | 가장 진한 글자 |
| label.neutral | `#47484C` | `labelNeutral` | `--color-label-neutral` | 보조 본문 |
| label.alternative | `#6E6E73` | `labelAlternative` | `--color-label-alternative` | 보조 설명 |
| label.assistive | `#B9B9B9` | `labelAssistive` | `--color-label-assistive` | placeholder·힌트 |
| label.disable | `#DFDFE0` | `labelDisable` | `--color-label-disable` | 비활성 글자 |
| background.normal | white | `backgroundNormal` | `--color-background-normal` | 화면 바탕 |
| background.alternative | `#F7F7F8` | `backgroundAlternative` | `--color-background-alternative` | 구역 구분 바탕 |
| background.warning | `#FFE7E7` | `backgroundWarning` | `--color-background-warning` | 경고 바탕 |
| interaction.inactive | `#989BA2` | `interactionInactive` | `--color-interaction-inactive` | 선택 안 된 상태 |
| interaction.disable | `#F4F4F5` | `interactionDisable` | `--color-interaction-disable` | 비활성 요소 바탕 |
| line.normal | `#E0E0E2` | `lineNormal` | `--color-line-normal` | 기본 테두리 |
| line.neutral | `#E8E8EA` | `lineNeutral` | `--color-line-neutral` | 구분선 |
| line.alternative | `#F4F4F5` | `lineAlternative` | `--color-line-alternative` | 옅은 구분선 |
| line.strong | `#D9D9D9` | `lineStrong` | `--color-line-strong` | 진한 테두리 |
| status.positive | `#00BF40` | `statusPositive` | `--color-status-positive` | 성공 |
| status.cautionary | `#FF9200` | `statusCautionary` | `--color-status-cautionary` | 주의 |
| status.destructive | `#DB1F25` | `statusDestructive` | `--color-status-destructive` | 오류·삭제 |
| inverse.primary | `#3385FF` | `inversePrimary` | `--color-inverse-primary` | 어두운 바탕 위 강조 |
| inverse.background | `#1B1C1E` | `inverseBackground` | `--color-inverse-background` | 어두운 바탕 (토스트 등) |
| inverse.label | `#F7F7F8` | `inverseLabel` | `--color-inverse-label` | 어두운 바탕 위 글자 |
| static.white | white | `staticWhite` | `--color-static-white` | 모드와 상관없이 흰색 |
| static.black | black | `staticBlack` | `--color-static-black` | 모드와 상관없이 검정 |
| fill.normal | `#F4F4F5` | `fillNormal` | `--color-fill-normal` | 채움 바탕 |
| fill.strong | `#E8E8EA` | `fillStrong` | `--color-fill-strong` | 진한 채움 |
| fill.alternative | `#70737C` 5% (Figma 변경 확인 필요) | `fillAlternative` | `--color-fill-alternative` | 옅은 채움 |
| material.dimmer | `#171719` 52% | `materialDimmer` | `--color-material-dimmer` | 모달 뒤 어둡게 |

### 색 — 화면에서 바로 쓰는 원시 색 (Primary-Pink · Primary-Blue · Gray-800)

Pink·Blue는 Figma에서 둘 다 Primary다. Gray-800은 Figma Icon 컴포넌트 기본색(선택된 하단 탭 등). 화면에서 바로 쓴다. Material 기본 위젯의 primary는 `pink.500`, secondary는 `blue.500`.

| 이름 | 앱 | 웹 |
| --- | --- | --- |
| pink.50 | `pink50` | `--color-pink-50` |
| pink.300 | `pink300` | `--color-pink-300` |
| pink.500 | `pink500` | `--color-pink-500` |
| pink.600 | `pink600` | `--color-pink-600` |
| pink.700 | `pink700` | `--color-pink-700` |
| blue.50 | `blue50` | `--color-blue-50` |
| blue.500 | `blue500` | `--color-blue-500` |
| blue.600 | `blue600` | `--color-blue-600` |
| blue.700 | `blue700` | `--color-blue-700` |
| gray.800 | `gray800` | `--color-gray-800` |

다크 모드 전용 값(Figma Background/Elevated, Transparent)은 다크 모드를 넣을 때 추가한다.

### 간격 (이름의 숫자 × 4 = 값)

반 단계(0.5, 1.5, 2.5, 3.5)와 5는 Figma 컴포넌트가 실제로 쓰는 2·6·10·14·20 때문에 둔다. Figma에 간격 변수가 없어 컴포넌트에서 읽은 값이고, 디자이너 확정이 필요하다.

| 이름 | 값 | 앱 | 웹 |
| --- | --- | --- | --- |
| space.0.5 | 2 | `AppSpacing.x0_5` | `--space-0-5` |
| space.1 | 4 | `AppSpacing.x1` | `--space-1` |
| space.1.5 | 6 | `AppSpacing.x1_5` | `--space-1-5` |
| space.2 | 8 | `AppSpacing.x2` | `--space-2` |
| space.2.5 | 10 | `AppSpacing.x2_5` | `--space-2-5` |
| space.3 | 12 | `AppSpacing.x3` | `--space-3` |
| space.3.5 | 14 | `AppSpacing.x3_5` | `--space-3-5` |
| space.4 | 16 | `AppSpacing.x4` | `--space-4` |
| space.5 | 20 | `AppSpacing.x5` | `--space-5` |
| space.6 | 24 | `AppSpacing.x6` | `--space-6` |
| space.8 | 32 | `AppSpacing.x8` | `--space-8` |

### 모서리

| 이름 | 값 | 앱 | 웹 |
| --- | --- | --- | --- |
| radius.xs | 6 | `AppRadius.xs` | `--radius-xs` |
| radius.sm | 8 | `AppRadius.sm` | `--radius-sm` |
| radius.md | 10 | `AppRadius.md` | `--radius-md` |
| radius.lg | 12 | `AppRadius.lg` | `--radius-lg` |
| radius.xl | 16 | `AppRadius.xl` | `--radius-xl` |
| radius.xxl | 20 | `AppRadius.xxl` | `--radius-xxl` |
| radius.full | 999 (양끝 둥글게) | `AppRadius.full` | `--radius-full` |

### 그림자 (Figma 디자인 시스템 v3 Elevation)

그림자 색은 모두 `#171717`이고 %는 불투명도. 값은 `x y blur spread`. 앱은 `BoxDecoration(boxShadow: AppShadows.small)`, 웹은 `box-shadow: var(--shadow-small)`.

| 이름 | 값 | 앱 | 웹 |
| --- | --- | --- | --- |
| shadow.xsmall | `0 1 2 -1` 10% | `AppShadows.xsmall` | `--shadow-xsmall` |
| shadow.small | `0 4 6 -1` 6% + `0 2 4 -2` 6% | `AppShadows.small` | `--shadow-small` |
| shadow.medium | `0 10 15 -3` 7% + `0 4 6 -2` 7% | `AppShadows.medium` | `--shadow-medium` |
| shadow.large | `0 16 24 -6` 8% + `0 6 10 -4` 8% | `AppShadows.large` | `--shadow-large` |
| shadow.xlarge | `0 24 38 -10` 12% + `0 10 15 -5` 10% | `AppShadows.xlarge` | `--shadow-xlarge` |
| shadow.spread.small | `0 0 60 0` 10% | `AppShadows.spreadSmall` | `--shadow-spread-small` |
| shadow.spread.medium | `0 15 75 0` 16% | `AppShadows.spreadMedium` | `--shadow-spread-medium` |

### 글자 (Figma 디자인 시스템 v3 타이포그래피)

글꼴은 **Pretendard** (SIL OFL 1.1). Regular·Medium·SemiBold·Bold만 쓴다. 자간 0.
앱은 `apps/mobile/assets/fonts/pretendard/`에 파일을 두고 `pubspec.yaml` fonts에 등록, 웹은 `pretendard` npm 패키지(글자 범위별로 나눠 필요한 조각만 받는다).

| Figma | 굵기 | 크기 | 행간 | 앱 `context.textStyles.*` | 웹 `font: var(...)` |
| --- | --- | --- | --- | --- | --- |
| Head(SB) | SemiBold 600 | 24 | 130% | `head` | `--text-head` |
| Head(B) | Bold 700 | 24 | 130% | `headBold` | `--text-head-bold` |
| Title-1(B) | Bold 700 | 18 | auto | `title1Bold` | `--text-title1-bold` |
| Title-1(R) | Regular 400 | 18 | auto | `title1Regular` | `--text-title1-regular` |
| Title-2(B) | Bold 700 | 16 | auto | `title2Bold` | `--text-title2-bold` |
| Title-2(SB) | SemiBold 600 | 16 | auto | `title2SemiBold` | `--text-title2-semibold` |
| Title-2(R) | Regular 400 | 16 | auto | `title2Regular` | `--text-title2-regular` |
| Body-1(B) | Bold 700 | 14 | 140% | `body1Bold` | `--text-body1-bold` |
| Body-1(SB) | SemiBold 600 | 14 | 140% | `body1SemiBold` | `--text-body1-semibold` |
| Body-1(M) | Medium 500 | 14 | 140% | `body1Medium` | `--text-body1-medium` |
| Body-1(R) | Regular 400 | 14 | 140% | `body1Regular` | `--text-body1-regular` |
| Caption-1(SB) | SemiBold 600 | 12 | 140% | `caption1SemiBold` | `--text-caption1-semibold` |
| Caption-1(M) | Medium 500 | 12 | 140% | `caption1Medium` | `--text-caption1-medium` |
| Caption-1(R) | Regular 400 | 12 | 140% | `caption1Regular` | `--text-caption1-regular` |
| Tag-1(SB) | SemiBold 600 | 10 | auto | `tag1` | `--text-tag1` |
| Tag-1(M) | Medium 500 | 10 | auto | `tag2` | `--text-tag2` |

- 앱은 기기의 글자 크기 설정(iOS Dynamic Type, Android 글꼴 크기)을 따르지 않는다. `app/app.dart`에서 `MediaQuery.withNoTextScaling`으로 막아 글자는 항상 이 표의 크기다. 웹은 px 단위라 브라우저 기본 글자 크기 설정의 영향을 받지 않는다(화면 확대는 브라우저가 처리).
- auto는 글꼴 기본 행간 (앱은 `height` 지정 안 함, 웹은 `normal`).
- 스타일에는 색이 없다. 기본 글자색 `label.normal`을 물려받고, 다른 색은 앱 `.copyWith(color: context.colors.*)`, 웹 `color: var(--color-*)`로 따로 준다.
- Material 기본 위젯용으로 `TextTheme`에도 매핑해 둔다 (`bodyMedium` = Body-1(R), `titleLarge` = Title-1(B) 등, `AppTextStyles.toTextTheme`). 화면 코드는 `TextTheme` 이름을 쓰지 않는다.
- Head(B)를 뺀 15개는 Figma 텍스트 스타일과 같다. v4 스타일 이름은 `Head/Head(SB)`, `Title/1(B)`, `Body/1(R)`, `Caption/1(R)`, `Tag/1(SB)`·`Tag/1(M)`처럼 그룹/이름이다. 코드 이름 `tag1`·`tag2`는 Figma Tag-1(SB)·Tag-1(M)이다.
- Head(B)는 v4 타이포그래피 표(`1502:11358`)에만 있고 텍스트 스타일로 등록되지 않았다. 기존 화면이 쓰는 `head`(Head(SB))는 그대로다.

### 컴포넌트 (Figma 디자인 시스템 v3 공통 컴포넌트)

세 번째 단계. 크기·여백·모서리만 두고, **색은 위의 의미 토큰을 고른다**. 컴포넌트 토큰은 그 컴포넌트 안에서만 쓴다 (앱 `shared/widgets/`, 웹 `shared/ui/`). 화면 코드는 컴포넌트를 쓰고 이 값을 직접 쓰지 않는다.
앱은 `app_component_tokens.dart`의 `AppButtonTokens`·`AppInputTokens`·`AppChipTokens`·`AppTagTokens`, 웹은 `tokens.css`의 `--button-*`·`--input-*`·`--chip-*`·`--tag-*`.
4 배수가 아닌 값(예: 30, 14, 5)도 Figma 값 그대로 둔다. 간격 단계(`space.*`)에 없는 값이라 컴포넌트 토큰에만 둔다.

| 컴포넌트 | 앱 위젯 / 웹 컴포넌트 | Figma |
| --- | --- | --- |
| 버튼 | `AppButton` / `Button` | `Btn` (와이어프레임 New/컴포넌트 → Button) |
| 입력창 | `AppTextField` / `TextField` | `Input` |
| 칩 | `AppChip` / `Chip` | `Chip`, `SocialLinkChip` |
| 태그 | `AppTag`·`AppRoundTag` / `Tag`·`RoundTag` | `TagSquare`, `TagRound` |
| 여러 줄 입력 | `AppTextArea` / `TextArea` | `TextArea` |
| 드롭다운 | `AppDropdown` / - | `Dropdown` |
| 체크박스·라디오 | `AppCheckbox`·`AppRadio` / `Checkbox`·`Radio` | `Checkbox`, `Radio Button` |
| 토글 | `AppToggle` / - | `Toggle` |
| 필터 | `AppFilterChip` / - | `Filter` |
| 안내 띠 | `AppNotice` / `Notice` | `Notice` |
| 다이얼로그 | `AppDialog`·`showAppDialog` / `Dialog` | `Dialog` |
| 바텀시트 | `AppBottomSheet`·`showAppBottomSheet`·`AppModalHeader` / - | `BottomSheet`, `ModalHeader` |
| 목록 한 줄 | `AppListRow` / - | `ListRow` |
| 하단 탭 | `AppBottomNavBar` / - | `NavEX` |
| 화면 안 탭 | `AppTabList` / - | `TabList` |
| 상단 바 | `AppTopBar`·`AppIconButton` / - | `Top`(Default), `IconButton` |
| 숫자 배지 | `AppBadge` / - | `Badge` |
| 구역 구분 띠 | `AppSectionDivider` / `SectionDivider` | `Divider` |
| 단계 막대 | `AppStepProgress` / - | `ProgressBar` |
| 숫자 올리기 | `AppStepper` / - | `InputCount` |
| 폼 항목 | `AppFormSection` / `FormSection` | `FormSection` |
| 아이콘 | `AppIcon` / - | `Icon` (IconList24 등) |

dev 빌드의 컴포넌트 모음 화면(`/dev/widgets`, DEV 띠 길게 누르기)에서 위 컴포넌트를 코드 이름·Figma 이름과 함께 볼 수 있다. 값은 디자인 확정 전 Figma 기준이라 바뀔 수 있다.

웹은 관객 신청 화면에 쓸 것만 만들었다(`-`는 앱만).

**영역별 컴포넌트** — 말풍선·공연 카드처럼 특정 화면 영역의 Figma 컴포넌트(메시지, 공연페이지, 홈, 온보딩, 목록, QR 섹션)는 화면보다 먼저 만들어 develop에 둔다. 두 사람이 같은 영역 위젯을 따로 만들거나 고치지 않게 하려는 것으로, "쓰는 곳 없는 코드는 미리 만들지 않는다"(AGENTS.md 1번)의 예외다. 디자인 확정 전 Figma 기준이라, 화면을 만들 때 Figma와 다시 맞추고 다르면 그 화면 PR에서 고친다.

범용 폴더(`shared/widgets/`)의 `AppBandCard`(Figma `BandCard`)·`AppMemberHeader`(`MemberHeader`)·`AppChipGroup`(`Chipwarp`)도 같은 경우다.

**영역 폴더의 컴포넌트** — 말풍선·공연 카드처럼 특정 화면 영역의 Figma 컴포넌트는 앱 `shared/widgets/<폴더>/`에 둔다(폴더 이름 = Figma 섹션: `message`, `show`, `home`, `onboarding`, `list`, `qr`). 값만 받아 그리는 위젯이라 어느 기능에서든 쓴다 (규칙은 [mobile-architecture 1절](./mobile-architecture.md#1-폴더와-들어가는-파일)).

- 색·글자·간격·모서리·그림자는 위의 토큰만 쓴다. 버튼·태그·배지 같은 부품은 범용 위젯(`AppButton` 등)을 그대로 넣는다.
- 앱에서만 쓰므로 컴포넌트 토큰을 따로 두지 않는다. 토큰에 없는 고정 크기(포스터 60, 프로필 40 등)만 위젯 안에 private 상수로 두고 Figma의 무엇인지 한 줄 적는다. 같은 크기가 여러 위젯에서 반복되면 토큰으로 올린다.
- Figma 컴포넌트의 hex가 v3 의미 색과 다르면 범용 컴포넌트와 같은 기준으로 가장 가까운 의미 색을 쓴다(아래 '어긋난 값' 표).
- 토큰과 1 차이 나는 간격(3, 5, 9, 11, 13, 15)과 모서리(15, 19)는 가장 가까운 단계로 맞췄다. 버튼·태그를 범용 위젯으로 넣으면서 높이·모서리가 1~4 달라진 곳도 있다(예: Figma 버튼 높이 30·33·35 → `AppButton` small 32).

| 폴더 | Figma 컴포넌트 (variant) | 위젯 |
| --- | --- | --- |
| `message/` | `MessageTag` (보낸문의 · 받은 문의) | `MessageTag` |
| | `Badge` | `ProfileBadge` (프로필 + `AppBadge`) |
| | `Message Container` (Sent · Received) | `MessageBubble` |
| | `MessageItem` (대표자 · 팀원) | `ChatTeamInputBar` |
| | `MessageItem` (Default · 공고삭제 · 목록에서 확인) | `InquiryListItem` |
| | `MessageSwipeRow` | `MessageSwipeRow` |
| | `MessageInput` (입력전 · 입력후) | `MessageInputBar` |
| | `ChatListRow` | `ChatListRow` |
| | `SystemMessage` | `SystemMessage` |
| | `Invitation` | `InvitationCard` |
| | `ResultCard` (합류 · 합류실패) | `JoinResultCard` |
| | `Container` (공고보기 · 내공고보기) | `PostLinkBar` |
| | `ReportItem` | `ReportItem` |
| | `Top` (채팅창 · 합동공연채팅) | `ChatTopBar` |
| `show/` | `Line up` (card / 모집중 · 합류 준비 / 팀추가) | `ShowLineupItem` / `ShowLineupPlaceholder` / `ShowLineupAddButton` |
| | `Badge` (주최 · 모집중), `Profile` (Default · 모집중) | `ShowTeamAvatar` |
| | `Component` (Inquiry · Link · copy) | `ShowActionRow` |
| | `Date` (default · today · Detail) | `ShowDateCard` |
| | `Notice` (숫자 요약) | `ShowStatSummary` |
| | `ProgressCard` (모집전 · 모집중 · 티켓판매 · 공연당일) | `ShowProgressCard` |
| | `Feed Tab` (Text · Image) | `ShowFeedPost` |
| | `Container` (고정 글) | `ShowPinnedPost` |
| | `Header` (false · true) | `ShowHeader` / `ShowHeader.compact` |
| | `Top` (합동공연 / 현장입장) | `ShowTopBar` / `EntryTopBar` |
| | `_Week`, `_Day` | `CalendarWeekRow`, `CalendarDayCell` |
| | `InputImg` (Default · 수정) | `ImageInput` (이미지가 있으면 수정 모양) |
| | `LocationList` | `LocationListItem` |
| | `입금확인` (확인완료 · 미확인 · 미입금 · 취소신청) | `DepositCheckCard` |
| | (여러 컴포넌트의 점 구분 줄) | `ShowMetaText` |
| | `이름으로 찾기` (현장 입장) | `EntryAttendeeRow` |
| | `popup` (수정 · 수정스탑 · 삭제 · 삭제불가) | `ShowConfirmPopup` · `showShowConfirmPopup` |
| `qr/` | `QRList` | `QrListCard` |
| | `DetailList` | `QrDetailRow` |
| `home/` | `CardLarge` (default · ticket · d-day / add) | `HomeShowCard` / `HomeShowAddCard` |
| | `CardSmall` | `HomeShowCardSmall` |
| | `Notice` | `HomeNotice` |
| | `HomeList` | `HomeListRow` |
| | `TeamProfile` | `HomeTeamProfile` |
| | `Btn` (addBtn · searchBtn) | `HomeActionButton` |
| `onboarding/` | `Onboarding` (Default · Code) | `OnboardingOptionCard` |
| | `popup` | `OnboardingPopup` |
| `list/` | `List` | `ShowListItem` |
| | `Notification` (Default · New / toggle · text · next) | `NotificationRow` / `NotificationSettingRow` |

Figma 아이콘이 없어 Material 아이콘으로 대신한 곳: `ShowActionRow` 복사(`content_copy`), `ImageInput` 이미지(`image_outlined`), `DepositCheckCard` 타이머(`timer_outlined`). 자물쇠·찜은 Figma 아이콘(`Icon: lock`, `Icon:bookmark`)으로 바꿨다.

2026-11-22 Figma 반영: 공연 팝업은 범용 `Dialog`와 여백·글자가 달라(폭 320, 여백 20, 설명 Body-1(R)) 영역 위젯으로 따로 두었다. 버튼은 `AppButton`을 그대로 써서 Figma 인스턴스의 SemiBold 글자와는 다르다. 팝업 안내 띠는 `AppNotice`(Body-1)라 Figma(Caption-1 회색)와 글자가 다르고, 느낌표 원 바탕 `#FDECEC`는 토큰이 없어 background.warning으로 맞췄다. `이름으로 찾기`의 화살표는 오른쪽 방향으로 가정했다(디자인 확인 필요).

**버튼** — 크기: large = XL, medium = XS, small = Mini, floating = FloatingButton. 너비는 정하지 않는다(부모 레이아웃이 정한다).

| 항목 | large | medium | small | floating |
| --- | --- | --- | --- | --- |
| 높이 | 52 | 42 | 32 | 여백으로 (48) |
| 좌우 여백 | 30 | 20 | 8 | 왼 14 · 오른 16 · 위아래 12 |
| 아이콘↔글자 | 2 | 4 | 6 | 4 |
| 모서리 | radius.md (10) | radius.lg (12) | radius.sm (8) | radius.full |
| 아이콘 | 24 | 24 | 16 | 24 |
| 글자 (fill·danger / weak) | Title-2(B) / Title-2(R) | Body-1(B) / Body-1(M) | Body-1(SB) / Body-1(M) | Title-2(B) / Title-2(R) |

| 중요도 | 바탕 | 글자 | 테두리 | 비활성 |
| --- | --- | --- | --- | --- |
| fill | label.strong | static.white | 없음 | 바탕 interaction.inactive, 글자 static.white |
| weak | background.normal | label.neutral (floating은 label.normal) | line.neutral | 바탕 interaction.disable, 글자 label.alternative |
| danger (large·floating) | status.destructive | static.white | 없음 | fill과 같음 |
| danger (medium·small) | background.normal | status.destructive | status.destructive | weak와 같음 |

로딩(Figma Loaing)은 글자 대신 점 3개(지름 6, 간격 8, 불투명도 100·70·40%)를 글자색으로 그리고 눌리지 않는다.

**입력창** — 높이 47, 좌우 여백 14(1px 테두리 안쪽에서 잰다. 바깥 테두리에서 글자·아이콘까지 15 — Figma `654:5752`·`1501:10747`), 아이콘·단위와 간격 10, radius.md (10). 바탕 background.normal, 테두리 line.strong, 글자 Body-1(R) label.normal, 안내 문구 label.alternative. 비활성: 바탕 interaction.disable, 글자 label.alternative. 오류: 테두리 status.destructive (Figma Error variant `1501:10747`, 변수 Status/Destructive). 앱 `AppTextField`는 Material 입력창이 테두리를 여백에 넣지 않고 입력 앞뒤에 4를 더하므로(M3 `gapPadding`·아이콘 간격) 위젯 안에서 보정해 웹과 같은 위치에 둔다. 포커스: 웹은 테두리를 label.normal로 바꾼다(키보드로 이동할 때 어느 칸인지 보여야 해서. Figma에 모양이 없어 임시값이고 오류 색이 우선), 앱은 커서로 알리고 테두리는 그대로 둔다. TextArea도 같다.

**칩** — 여백 좌우 12 · 위아래 8 (1px 테두리 안쪽. 높이 38 = Figma `1497:9998`), radius.full, 글자 Body-1(R). 선택 전: 바탕 background.normal, 테두리 line.strong, 글자 label.normal. 선택 후: 바탕·테두리 label.normal, 글자 static.white.

**상태 속성 이름** — 같은 뜻은 앱·웹·모든 컴포넌트에서 같은 이름을 쓴다. 상태 값은 화면(ViewModel)이 갖고 컴포넌트는 받은 값을 그린다.

| 뜻 | 이름 | 쓰는 컴포넌트 |
| --- | --- | --- |
| 여럿 중에서 골라짐 | `selected` (탭은 `selectedIndex`) | Chip, Filter, Radio, TabList |
| 켜짐·체크됨 | `checked` | Checkbox, Toggle |
| 오류 | `invalid` | Input |
| 요청 중 | `loading` | Button |
| 비활성 | 누르는 것은 콜백을 `null`로(웹은 `disabled`), 입력창은 `enabled: false`(웹은 `disabled`) | Button, Checkbox, Toggle, InputCount / Input, TextArea |

**범용 UI** — 치수는 `app_component_tokens.dart` / `tokens.css`에 있다. 색만 여기 적는다.

| 컴포넌트 | 치수 | 색 |
| --- | --- | --- |
| TextArea | 높이 100, 여백 14, radius.md | Input과 같음. 글자 수 Caption-1(R) label.alternative. 비활성: 바탕·테두리 interaction.disable |
| Dropdown | Input과 같음, 화살표 18 | 테두리 line.strong. 값 있음: 글자·화살표 label.normal, 없음: 글자 label.alternative·화살표 label.assistive |
| Checkbox | 상자 14, 모서리 2, 누르는 영역 44 | 테두리 label.neutral, 체크: 바탕 label.neutral + 흰 체크. 비활성: 바탕 interaction.disable + 테두리 label.disable (체크된 비활성은 Figma에 없어 바탕도 label.disable) |
| Radio | 원 22, 안쪽 점 10, 누르는 영역 44 | 안 고름: 테두리 interaction.inactive, 고름: 바탕 label.normal + 흰 점 |
| Toggle | 50 × 26, 원 16 | 켬: label.strong, 꺼짐: label.assistive, 원 static.white |
| Filter | 여백 12 · 8, 간격 2, radius.full | 테두리 line.neutral, 글자 Body-1(M) label.normal, 걸림: 바탕 fill.strong |
| Notice | 여백 12 · 10, 간격 4, 아이콘 24, radius.md | info: background.alternative + Body-1(R) gray.800, warning: background.warning + Title-2(SB) status.destructive |
| Dialog | 폭 323, 여백 위 30 · 옆·아래 10, 간격 20, radius.xxl | 제목 Title-1(B) label.normal, 설명 Body-1(M) label.neutral, 뒤 material.dimmer, 버튼은 weak + fill(또는 danger) large |
| BottomSheet | 여백 위 12 · 옆 20 · 아래 34, 간격 16, 위쪽 radius.xxl, 손잡이 40 × 4 | 바탕 background.normal, 손잡이 line.strong. ModalHeader: 제목 Title-1(B) label.normal, 보조 Body-1(R) label.neutral, 간격 8 |
| ListRow | 높이 44, 여백 10, 간격 10, 뒤 요소 폭 52 | 글자 Title-2(SB) label.normal |
| TabList | 탭 높이 44, 여백 12, 밑줄 2 | 아래 선 line.strong. 고름: Body-1(B) label.strong + 밑줄, 안 고름: Body-1(R) interaction.inactive |
| Top · IconButton | 높이 56, 여백 6, 버튼 44, 아이콘 24 | 제목 Title-2(B) label.normal |
| Badge | 지름 20 원 (길어지지 않음, `99+`는 원 안에 맞게 줄임) | 바탕 label.strong, 글자 Tag-1(SB) static.white |
| Divider | 두께 10 | background.alternative |
| ProgressBar | 여백 8, 막대 높이 4 · 간격 4 · 모서리 2 | 제목 Body-1(SB) label.normal, 단계 Caption-1(SB) label.alternative, 끝남 칸 label.normal, 남은 칸 fill.strong |
| InputCount | 버튼 44, radius.md | 테두리 line.strong, 값 Title-2(B) label.normal, 끌 버튼 label.assistive |
| FormSection | 간격 8 | 제목 Title-2(SB) label.normal, 힌트 Caption-1(R) label.alternative |

**태그** — 누를 수 없는 상태 라벨.

| | 여백 | 모서리 | 글자 | 색 |
| --- | --- | --- | --- | --- |
| 네모 (small·medium·large = XS·S·XL) | 좌우 8 · 위아래 5 | radius.xs (6) | Tag-1(M) / Tag-1(SB) / Caption-1(R) | neutral: fill.strong + label.normal, filled: label.normal + static.white, outlined: 테두리 label.normal |
| 둥근 small (M) | 8 | radius.full | Tag-1(M) | fill.strong + label.neutral |
| 둥근 medium (L) | 좌우 10 · 위아래 6 | radius.full | Caption-1(SB) | fill.strong + label.strong |
| 둥근 large (XL) | 좌우 10 · 위아래 4 | radius.full | Body-1(M) | fill.strong + label.normal |

#### Figma 컴포넌트와 어긋난 값 (디자이너 확인 필요)

마스터 컴포넌트에 변수 없이 칠해진 색이다. 컴포넌트는 가장 가까운 의미 토큰을 쓴다. 디자이너가 컴포넌트 값이 맞다고 하면 토큰을 추가하거나 값을 바꾼다 (2절 절차). 변수를 쓰는 자리(danger 버튼, weak 버튼, 입력창 테두리, 태그 바탕, Checkbox)는 2026-11 변수 변경으로 의미 토큰과 값이 같아졌다.

| 컴포넌트 자리 | Figma 컴포넌트 값 | 쓰는 토큰 (값) |
| --- | --- | --- |
| 칩 테두리 | `#CFCFCF` (스타일 없음) | line.strong (`#D9D9D9`) |
| 입력창 Fill 글자 | 변수 없음 (v3 `#1A1A1A`. 칩·입력창 Error 글자는 v4에서 Label/Normal 변수) | label.normal (`#171719`) |
| 둥근 태그 L 글자 | `#030303` (스타일 없음) | label.strong (black) |
| 힌트·단계 글자 | `#606060` (스타일 없음) | label.alternative (`#6E6E73`) |
| TextArea 글자 수 | `#878787` (스타일 없음) | label.alternative |
| Dropdown·InputCount·TextArea(Fill) 테두리, 바텀시트 손잡이 | `#CFCFCF` | line.strong |
| Filter 테두리·걸림 바탕 | `#EBEBEB` | line.neutral / fill.strong |
| ProgressBar 남은 칸 | `#E4E4E4` | fill.strong |
| Divider | `#F2F2F2` | background.alternative (`#F7F7F8`) |
| Badge 바탕 | `#030303` | label.strong |

모양이 한 컴포넌트 안에서 어긋난 곳도 하나로 맞췄다:

- 버튼 XL 모서리: Fill·Danger 10, Weak 12 → 10. 나란히 놓는 버튼이라 같아야 한다.
- 버튼 XS 모서리: 대부분 12, Fill Disabled 10·Danger 8 → 12.
- 버튼 Mini 좌우 여백: Default 8, Disabled 10 → 8.
- Toggle은 Figma가 그림(SVG)이라 치수를 읽어 맞춘 바탕 채운 모양이다. 켜짐/꺼짐 색만 Figma(label.strong / label.assistive)와 같다.
- BottomSheet 그림자(`0 4 10` 8%)는 v3 Elevation에 없어 넣지 않았다. 뒷 배경을 material.dimmer로 어둡게 해 구분된다.
- 입력창 뒤 아이콘 칸: Weak(`654:5752`)만 오른쪽 5, Error·Fill/서브텍스트·지우기 아이콘(`1501:10747`·`1959:20282`·`1701:13048`)은 15 → 15. 2Fill의 검색 아이콘↔글자는 8(다른 variant 10) → 10.

#### v4 대조 (2026-11-26)

Figma `디자인` 파일 `디자인시스템_v4` 페이지(`107:315`)의 `디자인 시스템v4`(`1502:11241`), `인풋 수정 v2`(`1681:11168`), `색상변경V3`(`2175:28537`)와 대조했다. 값은 Figma Desktop MCP의 변수·텍스트 스타일(`get_variable_defs`), 좌표(`get_metadata`), 견본 스크린샷 픽셀(sRGB)로 읽었다.

| 항목 | 이전 | v4 | 근거 |
| --- | --- | --- | --- |
| pink.50 | `#FFEAF4` | `#FFD6E9` | 변수 `색상/Primary/Pink/50`(공통·공연페이지·홈 컴포넌트), 견본 `1502:11498` |
| pink.600 | `#E62A7E` | `#DC136C` | 견본 `1502:11511` (이전 값은 `2175:28624`에 따로 둠) |
| pink.700 | `#C7256D` | `#8E0341` | 견본 `1502:11516` (이전 값은 `2175:29148`) |
| background.warning | `#F1E1E1` | `#FFE7E7` | 변수 `색상/Background/Normal/Warning`(공통·Button 컴포넌트) |
| Head(B) | 없음 | Bold 24 / 130% | 타이포그래피 표 `1502:11355`~`11358` |
| 입력창·칩 여백 | 앱만 테두리 포함 14(글자는 18) | 테두리 안쪽 14 = 바깥에서 15 | Input `654:5752`·`1501:10747`, Chip `1497:9998` 높이 38 |

디자이너 확인 필요:

- Pink-600·700은 변수에 연결된 곳이 없어 색상 문서 견본 값을 따랐다. 변수 `색상/Primary/Pink/600`·`700` 값이 같은지.
- Background/Warning 변수는 `#FFE7E7`인데 색상 문서 견본(`1681:13570`)과 다크 표 글자(`2218:149795`)는 `#F1E1E1`이다. 코드는 컴포넌트가 쓰는 변수를 따랐다.
- Blue-700 견본은 `#1A6EC2`를 약 76% 불투명도로 칠해 `#5191D1`로 보인다. 값은 바꾸지 않았다.
- 색상 문서 프레임(`1502:11429`)의 Label·Line·Fill 견본은 아직 옛 반투명 라이브러리 변수(`Label/Neutral` `#2E2F33` 88% 등)를 쓴다. 컴포넌트는 `색상/*` 불투명 변수를 쓰고 코드는 이것을 따른다.
- 타이포그래피 표(`1502:11314`) 라벨과 샘플이 실제 스타일과 다르다. Caption-1(SB) 행 라벨 Regular, Caption-1(R) 행 라벨 SemiBold, 캡션 행간 auto(실제 140%). 샘플 연결은 Caption-1(M) 행→`Caption/1(SB)`, Caption-1(R) 행→`Caption/1(M)`, Title-1(B) 행→`Title/2(SB)`, Tag-2 행→`Tag/1(SB)`. 코드는 컴포넌트가 쓰는 실제 스타일(예: `Caption/1(R)` Regular 400 · 140%)을 따른다.
- Head(B)를 텍스트 스타일로 등록할지.

코드에 아직 없는 v4 항목:

- Input `Fill/서브텍스트`(`1959:20282`, 높이 56, 값 아래 `상세주소` 한 줄 Label/Neutral). 글자에 스타일이 연결되지 않아 값을 확인한 뒤 추가한다.
- Input `2Fill`(`1701:13048`, 검색 아이콘 + 지우기 20)은 지금 `prefix`·`suffix`로 만든다.
- 밴드 합동공연 Dark(`2218:149494`, `밴드 합동공연/Dark/*` 변수)는 다크 화면을 만들 때 추가한다. Lime·Purple·Glow·Primary·Secondary 일부는 변수가 없다.
- Accent(Background·Foreground)는 색상 프레임에 이름만 있고 값이 없다.

#### Figma 화면과 어긋난 값 (디자이너 확인 필요)

화면 시안이 공통 컴포넌트·토큰 대신 직접 칠한 값을 쓴 곳이다. 디자이너 확인 전까지 화면은 시안과 똑같이 맞추고, 토큰에 없는 값은 그 화면 파일의 `_Draft` 클래스 한 곳에 모은다. 디자이너가 시안 값이 맞다고 하면 토큰을 추가하거나 값을 바꾸고(2절 절차), 토큰 값이 맞다고 하면 화면을 토큰으로 바꾼다. 어느 쪽이든 끝나면 `_Draft`를 지운다. 화면 PR 설명에도 같은 표를 붙인다.

**로그인 (`계정-회원가입`, Figma node `1372:6594`, JECT-180)** — `login_view.dart`의 `_Draft`

| 자리 | Figma 화면 값 (지금 쓰는 것) | 가장 가까운 토큰 |
| --- | --- | --- |
| 제목 "음악이 통하는 순간…" | 26 Bold, 행간 1.3 | head (24 SemiBold, 행간 1.3) |
| 카카오 버튼 바탕 | `#1A1A1A` | AppButton fill → label.strong (black) |
| Apple·Google 버튼 테두리 | `#C5C5C5` | AppButton weak → line.neutral (`#E8E8EA`) |
| Apple·Google 버튼 글자 | `#1A1A1A` 16 SemiBold | AppButton weak → label.neutral (`#47484C`) Title-2(R) |
| 카카오 버튼 글자 | 16 SemiBold | AppButton fill → Title-2(B) |
| 버튼 아이콘 · 글자 사이 | 26 · 10 | AppButton 아이콘 24 · 간격 2 |
| 부제목·"로그인에 문제가 있으신가요?" | `#7F7F7F` 14 Medium, 부제목 행간 1.5 | label.alternative (`#6E6E73`) Body-1(M), 행간 1.4 |
| 로고 ↔ 제목 간격 | 28 | spacing.x6 (24) |
| 마지막 버튼 ↔ 도움말 | 29 | spacing.x6 (24) |
| 상태 표시줄 → 로고 / 마지막 버튼 → 홈 인디케이터 | 119 위 고정 / 110 아래 고정 (시안 top 163 - 44, bottom 144 - 34) | 토큰 없음. 부제목 ↔ 버튼은 남는 높이라 화면마다 다르다 (812 화면 약 79, iPhone 17 Pro 약 120) |
| 짧은 화면 (시안 없음) | — | 로고 위 119부터 줄이고, 부제목 ↔ 버튼은 최소 spacing.x8 (32). 그래도 모자라면 스크롤 (iPhone SE 등). 최소값은 디자이너 확인 필요 |

버튼 색·글자 굵기는 AppButton을 그대로 쓰고, 로그인 버튼 아래에서만 AppButton이 읽는 토큰을 바꿔 맞춘다(`_DraftButtonTheme`). 아이콘 크기·간격은 AppButton의 `iconSize`·`iconGap`으로 넘긴다.

정해지지 않은 것:

- 로고와 버튼 아이콘 3개는 시안도 회색 자리 표시다. 같은 크기 자리만 둔다 (로고 100, 아이콘 26).
- "로그인에 문제가 있으신가요?"를 누르면 어디로 갈지 정해지지 않아 글자만 둔다.
- 로그인 오류 안내 시안이 없다. Figma에 있는 로그인 오류는 "다른 기기에서 로그인했어요" 팝업(node `1739:8767`)뿐이라 같은 모양(가운데 Dialog)으로 띄운다. 문구는 `docs/api/auth-login.md` "에러".
  - `AUTH_006`(소셜 인증 실패): 임시 문구 "소셜 로그인 인증에 실패했어요. 다시 시도해 주세요."
  - `USER_004`(탈퇴한 계정): 임시 문구 "탈퇴한 계정이에요."
  - 네트워크 오류는 Figma 공통 문구 "네트워크 상태를 확인하고 다시 시도해 주세요."를 쓴다.
- 카카오는 브랜드 가이드상 노란 버튼(`#FEE500`), Apple은 Sign in with Apple 가이드 모양을 요구한다. 검은·흰 버튼이 심사를 통과하는지 디자이너와 확인한다.

**홈 (`홈-처음/공연없음`, Figma node `2217:122923`, JECT-149)** — `home_view.dart`의 `_Draft`

| 자리 | Figma 화면 값 (지금 쓰는 것) | 가장 가까운 토큰 |
| --- | --- | --- |
| 위쪽 문구 "함께 무대에 오를 밴드를 찾고…" | 22 Bold, 행간 1.4 | headBold (24 Bold, 행간 1.3) |

**합동공연 만들기 (`공연열고 팀 모집`, Figma node `2217:123040`, JECT-149)** — 화면 시안이 컴포넌트 값을 덮어쓴 곳. V3 컴포넌트 값으로 그렸다.

| 자리 | 화면 시안 값 | 그린 값 (컴포넌트) |
| --- | --- | --- |
| 항목 제목 (공연 제목·연주 장르·공연 날짜·공연 포스터·공연 장소·전체 대관비) | 14 SemiBold | `FormSection` 마스터(`1439:9745`) Title-2(SB) 16 |
| 입력한 날짜 "2026.10.12 (월)" | Body-1(M) | `AppTextField` Body-1(R) |
| 하단 "공연 만들기" 버튼 글자 | 16 SemiBold | `AppButton` large Title-2(B) |

## 4. 쓰는 법

앱:

```dart
Container(
  padding: const EdgeInsets.all(AppSpacing.x4),
  decoration: BoxDecoration(
    color: context.colors.backgroundNormal,
    border: Border.all(color: context.colors.lineNormal),
    borderRadius: BorderRadius.circular(AppRadius.md),
  ),
  child: Text(title, style: context.textStyles.title1Bold),
)
```

웹 (`NoticeCard.module.css`):

```css
.card {
  padding: var(--space-4);
  background: var(--color-background-normal);
  border: 1px solid var(--color-line-normal);
  border-radius: var(--radius-md);
  font: var(--text-body1-regular);
}
```

## 5. 하면 안 되는 것

- 위젯·컴포넌트에서 hex, `Colors.*`, 숫자 px·dp 직접 사용
- 화면 코드에서 컴포넌트 토큰(`AppButtonTokens`, `--button-*` 등) 사용. 버튼이 필요하면 `AppButton`/`Button`을 쓴다
- 원시 토큰(`_Palette.*`, `--gray-200`)을 토큰 파일 밖에서 참조
- 앱·웹 중 한쪽만 바꾸기
- 특정 화면 전용 토큰 만들기 (새 값이 필요하면 범용 단계로 추가)
- 토큰 파일에 색·크기 외의 로직 넣기

## 6. 아직 없는 것 (필요해질 때 같은 절차로 추가)

- 다크 모드 (`AppColors.dark`, `@media (prefers-color-scheme: dark)`). 밴드 합동공연 Dark 팔레트는 Figma `2218:149494`
- 애니메이션 시간
- 여러 조각으로 그려진 Figma 아이콘(menu, bell, bookmark, lock, camera 등). 쓸 때 Figma에서 SVG로 내보내 `assets/icons/`와 `AppIcons`에 추가
- 영역별 컴포넌트는 들어가 있다. 화면을 만들 때 Figma와 다시 맞춘다
