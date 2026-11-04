# 디자인 토큰

색·간격·모서리·글자 크기 값을 한 곳에서 정하고, 앱과 웹이 같은 이름·같은 값을 쓰게 하는 규칙이다.

## 1. 원칙

- **기준은 이 문서의 표**다. Figma 변수가 생기면 그 이름을 그대로 따라 표를 고친다.
- **두 단계**: 원시(primitive) 토큰(`brand.500`, `gray.200`)은 팔레트, 의미(semantic) 토큰(`color.primary`, `color.border`)은 쓰임새. 화면 코드는 **의미 토큰만** 쓴다. 원시 토큰은 토큰 파일 안에서만 참조한다. 디자인이 바뀌면 의미 토큰이 가리키는 원시 값만 바꾸면 되고 화면 코드는 그대로다.
- **앱과 웹은 각자 파일에 손으로 같은 값을 둔다.** 토큰이 수십 개 수준이라 생성 도구(Style Dictionary 등)보다 손 동기화가 단순하다. 토큰이 100개를 넘거나 다크 모드가 들어오면 그때 생성 도구를 검토한다.

| 위치 | 파일 |
| --- | --- |
| 기준 | `docs/design-tokens.md` (이 문서) |
| 앱 | `apps/mobile/lib/shared/theme/app_colors.dart`, `app_spacing.dart`, `app_radius.dart`, `app_typography.dart` |
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

현재 값은 **디자인 확정 전 임시값**이다. 이름과 구조만 믿고, 값은 디자인이 나오면 바뀐다.

### 색 — 원시 (토큰 파일 안에서만)

| 이름 | 값 |
| --- | --- |
| brand.500 | `#4F46E5` |
| brand.600 | `#4338CA` |
| gray.50 | `#F9FAFB` |
| gray.200 | `#E5E7EB` |
| gray.600 | `#4B5563` |
| gray.900 | `#111827` |
| red.500 | `#EF4444` |
| white | `#FFFFFF` |

### 색 — 의미 (화면 코드가 쓰는 것)

| 이름 | 가리킴 | 앱 | 웹 | 쓰임 |
| --- | --- | --- | --- | --- |
| color.primary | brand.500 | `context.colors.primary` | `var(--color-primary)` | 주 버튼, 강조 |
| color.primaryPressed | brand.600 | `.primaryPressed` | `--color-primary-pressed` | 눌림 상태 |
| color.onPrimary | white | `.onPrimary` | `--color-on-primary` | primary 위 글자 |
| color.background | gray.50 | `.background` | `--color-background` | 화면 바탕 |
| color.surface | white | `.surface` | `--color-surface` | 카드·시트 |
| color.textPrimary | gray.900 | `.textPrimary` | `--color-text-primary` | 본문 |
| color.textSecondary | gray.600 | `.textSecondary` | `--color-text-secondary` | 보조 설명 |
| color.border | gray.200 | `.border` | `--color-border` | 구분선·테두리 |
| color.danger | red.500 | `.danger` | `--color-danger` | 오류·삭제 |

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

### 글자 크기

| 이름 | 값 | 앱 | 웹 |
| --- | --- | --- | --- |
| fontSize.sm | 14 | `textTheme.bodySmall` | `--font-size-sm` |
| fontSize.md | 16 | `textTheme.bodyMedium` | `--font-size-md` |
| fontSize.lg | 20 | `textTheme.titleLarge` | `--font-size-lg` |
| fontSize.xl | 24 | `textTheme.headlineSmall` | `--font-size-xl` |

앱은 크기를 `AppFontSize`에 두고 `AppTypography.textTheme`가 Material `TextTheme`에 매핑한다. 위젯은 `Theme.of(context).textTheme.*`만 쓴다.

## 4. 쓰는 법

앱:

```dart
Container(
  padding: const EdgeInsets.all(AppSpacing.x4),
  decoration: BoxDecoration(
    color: context.colors.surface,
    border: Border.all(color: context.colors.border),
    borderRadius: BorderRadius.circular(AppRadius.md),
  ),
  child: Text(title, style: Theme.of(context).textTheme.titleLarge),
)
```

웹 (`NoticeCard.module.css`):

```css
.card {
  padding: var(--space-4);
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  font-size: var(--font-size-md);
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
- 폰트 패밀리·행간·자간
- 그림자, 애니메이션 시간
- 컴포넌트 토큰 (버튼 높이, 입력창 높이 등)
