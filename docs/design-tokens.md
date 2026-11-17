# 디자인 토큰

색·간격·모서리·글자 크기 값을 한 곳에서 정하고, 앱과 웹이 같은 이름·같은 값을 쓰게 하는 규칙이다.

## 1. 원칙

- **기준은 이 문서의 표**다. Figma 변수가 생기면 그 이름을 그대로 따라 표를 고친다.
- **두 단계**: 원시(primitive) 토큰(`pink.500`, `gray.200`)은 팔레트, 의미(semantic) 토큰(`label.normal`, `line.normal`)은 쓰임새. 화면 코드는 **의미 토큰만** 쓴다. 원시 토큰은 토큰 파일 안에서만 참조한다. 디자인이 바뀌면 의미 토큰이 가리키는 원시 값만 바꾸면 되고 화면 코드는 그대로다.
- **앱과 웹은 각자 파일에 손으로 같은 값을 둔다.** 토큰이 수십 개 수준이라 생성 도구(Style Dictionary 등)보다 손 동기화가 단순하다. 토큰이 100개를 넘거나 다크 모드가 들어오면 그때 생성 도구를 검토한다.

| 위치 | 파일 |
| --- | --- |
| 기준 | `docs/design-tokens.md` (이 문서) |
| 앱 | `apps/mobile/lib/shared/theme/app_colors.dart`, `app_spacing.dart`, `app_radius.dart`, `app_typography.dart`, 글꼴 `assets/fonts/pretendard/` |
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

색·글자는 Figma 디자인 시스템 v3 기준이다. 간격·모서리는 Figma에 아직 없어 임시값이다.

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
| pink.50 | `#FFEAF4` |
| pink.300 | `#FF5FA6` |
| pink.500 | `#FF2F8C` |
| pink.600 | `#E62A7E` |
| pink.700 | `#C7256D` |
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
| label.neutral | `#2E2F33` 88% | `labelNeutral` | `--color-label-neutral` | 보조 본문 |
| label.alternative | `#6E6E73` | `labelAlternative` | `--color-label-alternative` | 보조 설명 |
| label.assistive | `#B9B9B9` | `labelAssistive` | `--color-label-assistive` | placeholder·힌트 |
| label.disable | `#37383C` 16% | `labelDisable` | `--color-label-disable` | 비활성 글자 |
| background.normal | white | `backgroundNormal` | `--color-background-normal` | 화면 바탕 |
| background.alternative | `#F7F7F8` | `backgroundAlternative` | `--color-background-alternative` | 구역 구분 바탕 |
| background.warning | `#F1E1E1` | `backgroundWarning` | `--color-background-warning` | 경고 바탕 |
| interaction.inactive | `#989BA2` | `interactionInactive` | `--color-interaction-inactive` | 선택 안 된 상태 |
| interaction.disable | `#F4F4F5` | `interactionDisable` | `--color-interaction-disable` | 비활성 요소 바탕 |
| line.normal | `#70737C` 22% | `lineNormal` | `--color-line-normal` | 기본 테두리 |
| line.neutral | `#70737C` 16% | `lineNeutral` | `--color-line-neutral` | 구분선 |
| line.alternative | `#70737C` 8% | `lineAlternative` | `--color-line-alternative` | 옅은 구분선 |
| line.strong | `#B6B6B6` | `lineStrong` | `--color-line-strong` | 진한 테두리 |
| status.positive | `#00BF40` | `statusPositive` | `--color-status-positive` | 성공 |
| status.cautionary | `#FF9200` | `statusCautionary` | `--color-status-cautionary` | 주의 |
| status.destructive | `#EF2E2E` | `statusDestructive` | `--color-status-destructive` | 오류·삭제 |
| inverse.primary | `#3385FF` | `inversePrimary` | `--color-inverse-primary` | 어두운 바탕 위 강조 |
| inverse.background | `#1B1C1E` | `inverseBackground` | `--color-inverse-background` | 어두운 바탕 (토스트 등) |
| inverse.label | `#F7F7F8` | `inverseLabel` | `--color-inverse-label` | 어두운 바탕 위 글자 |
| static.white | white | `staticWhite` | `--color-static-white` | 모드와 상관없이 흰색 |
| static.black | black | `staticBlack` | `--color-static-black` | 모드와 상관없이 검정 |
| fill.normal | `#70737C` 8% | `fillNormal` | `--color-fill-normal` | 채움 바탕 |
| fill.strong | `#70737C` 16% | `fillStrong` | `--color-fill-strong` | 진한 채움 |
| fill.alternative | `#70737C` 5% | `fillAlternative` | `--color-fill-alternative` | 옅은 채움 |
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

### 간격 (4 배수)

| 이름 | 값 | 앱 | 웹 |
| --- | --- | --- | --- |
| space.1 | 4 | `AppSpacing.x1` | `--space-1` |
| space.2 | 8 | `AppSpacing.x2` | `--space-2` |
| space.3 | 12 | `AppSpacing.x3` | `--space-3` |
| space.4 | 16 | `AppSpacing.x4` | `--space-4` |
| space.6 | 24 | `AppSpacing.x6` | `--space-6` |
| space.8 | 32 | `AppSpacing.x8` | `--space-8` |

### 모서리

| 이름 | 값 | 앱 | 웹 |
| --- | --- | --- | --- |
| radius.sm | 8 | `AppRadius.sm` | `--radius-sm` |
| radius.md | 12 | `AppRadius.md` | `--radius-md` |
| radius.lg | 16 | `AppRadius.lg` | `--radius-lg` |

### 글자 (Figma 디자인 시스템 v3 타이포그래피)

글꼴은 **Pretendard** (SIL OFL 1.1). Regular·Medium·SemiBold·Bold만 쓴다. 자간 0.
앱은 `apps/mobile/assets/fonts/pretendard/`에 파일을 두고 `pubspec.yaml` fonts에 등록, 웹은 `pretendard` npm 패키지(글자 범위별로 나눠 필요한 조각만 받는다).

| Figma | 굵기 | 크기 | 행간 | 앱 `context.textStyles.*` | 웹 `font: var(...)` |
| --- | --- | --- | --- | --- | --- |
| Head(SB) | SemiBold 600 | 24 | 130% | `head` | `--text-head` |
| Title-1(B) | Bold 700 | 18 | auto | `title1Bold` | `--text-title1-bold` |
| Title-1(R) | Regular 400 | 18 | auto | `title1Regular` | `--text-title1-regular` |
| Title-2(B) | Bold 700 | 16 | auto | `title2Bold` | `--text-title2-bold` |
| Title-2(SB) | SemiBold 600 | 16 | auto | `title2SemiBold` | `--text-title2-semibold` |
| Title-2(R) | Regular 400 | 16 | auto | `title2Regular` | `--text-title2-regular` |
| Body-1(B) | Bold 700 | 14 | 140% | `body1Bold` | `--text-body1-bold` |
| Body-1(SB) | SemiBold 600 | 14 | 140% | `body1SemiBold` | `--text-body1-semibold` |
| Body-1(M) | Medium 500 | 14 | 140% | `body1Medium` | `--text-body1-medium` |
| Body-1(R) | Regular 400 | 14 | 140% | `body1Regular` | `--text-body1-regular` |
| Caption-1(SB) | SemiBold 600 | 12 | auto | `caption1SemiBold` | `--text-caption1-semibold` |
| Caption-1(M) | Medium 500 | 12 | auto | `caption1Medium` | `--text-caption1-medium` |
| Caption-1(R) | Regular 400 | 12 | auto | `caption1Regular` | `--text-caption1-regular` |
| Tag-1 | SemiBold 600 | 10 | auto | `tag1` | `--text-tag1` |
| Tag-2 | Medium 500 | 10 | auto | `tag2` | `--text-tag2` |

- auto는 글꼴 기본 행간 (앱은 `height` 지정 안 함, 웹은 `normal`).
- 스타일에는 색이 없다. 기본 글자색 `label.normal`을 물려받고, 다른 색은 앱 `.copyWith(color: context.colors.*)`, 웹 `color: var(--color-*)`로 따로 준다.
- Material 기본 위젯용으로 `TextTheme`에도 매핑해 둔다 (`bodyMedium` = Body-1(R), `titleLarge` = Title-1(B) 등, `AppTextStyles.toTextTheme`). 화면 코드는 `TextTheme` 이름을 쓰지 않는다.
- Figma 표기와 스타일이 어긋난 곳: Head 표기는 32px지만 스타일은 24px → 24. Caption-1(SB) 표기는 Regular → SemiBold. Title-1(B)·Caption-1(R)·Tag-2는 Figma 스타일이 없어 이름대로 정했다. 디자인 확인 필요.

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
- 원시 토큰(`_Palette.*`, `--gray-200`)을 토큰 파일 밖에서 참조
- 앱·웹 중 한쪽만 바꾸기
- 특정 화면 전용 토큰 만들기 (새 값이 필요하면 범용 단계로 추가)
- 토큰 파일에 색·크기 외의 로직 넣기

## 6. 아직 없는 것 (필요해질 때 같은 절차로 추가)

- 다크 모드 (`AppColors.dark`, `@media (prefers-color-scheme: dark)`)
- 그림자, 애니메이션 시간
- 컴포넌트 토큰 (버튼 높이, 입력창 높이 등)
