# JECT-258 디자인 시스템 v4 대조와 반영

작성일: 2026-11-26. 작업 위치: `.worktrees/JECT-258`, 브랜치 `feat/JECT-258-design-system-v4`
(origin/develop `4ace55e`에서 시작).

## 현재 상태

- 현재 단계: 구현, 로컬 검증, 앱·웹 렌더링 확인까지 마쳤다. 커밋·푸시·PR·Jira 쓰기는 요청받지 않아 하지 않았다.
- 허용 범위: 앱·웹 컴포넌트·토큰 코드, `docs/design-tokens.md`, 테스트, 렌더링 QA, 이 기록. JECT-149 워크트리는 건드리지 않았다.
- 다음 행동: 디자이너 확인 항목(아래) 답변을 받는다. PR 전에 토큰 변경을 상대에게 한 줄 알린다(AGENTS 11번).

## 요구사항

- 문제: Figma `디자인` 파일 `디자인시스템_v4` 페이지(`107:315`)의 `디자인 시스템v4`(`1502:11241`), `인풋 수정 v2`(`1681:11168`), `색상변경V3`(`2175:28537`)와 앱·웹 토큰·컴포넌트·문서가 다르다.
- 성공 기준: Figma에서 확인한 차이만 앱·웹·문서에 같은 값으로 반영한다. 임의 값은 넣지 않는다. 기존 화면이 쓰는 `head`는 그대로 둔다. 테스트·analyze·lint·build를 통과하고 실제 렌더링으로 값을 확인한다.

## 근거와 선택

Figma Desktop MCP만 읽기 전용으로 썼다. `get_design_context`는 이 세션에서 매번 SessionExpired로 실패했다. 그래서 `get_variable_defs`(변수·텍스트 스타일), `get_metadata`(좌표), `get_screenshot` PNG 픽셀(sRGB 청크 확인)로 값을 읽었다. MCP 리소스가 없어 공식 가이드 `figma/mcp-server-guide` `skills/figma-design-to-code/SKILL.md`를 읽었다.

| 항목 | 이전 → 이후 | 근거 |
| --- | --- | --- |
| pink.50 | `#FFEAF4` → `#FFD6E9` | 변수 `색상/Primary/Pink/50`(공통 `1061:36797`·공연페이지 `1060:6106`·홈 `1061:37912`), 견본 `1502:11498` 픽셀 |
| pink.600 | `#E62A7E` → `#DC136C` | 견본 `1502:11511` 픽셀. `색상변경V3`에 이전 값 견본 `2175:28624`(`#E62A7E`)를 따로 둠 |
| pink.700 | `#C7256D` → `#8E0341` | 견본 `1502:11516` 픽셀, 이전 값 견본 `2175:29148` |
| background.warning | `#F1E1E1` → `#FFE7E7` | 변수 `색상/Background/Normal/Warning`(공통, Button `1060:3217`) |
| Head(B) | 없음 → `headBold` · `--text-head-bold` (Bold 24 / 130%) | 표 `1502:11355`~`11358`. 렌더링 잉크가 Head(SB)보다 Figma +13.4%, iOS +13.7% |
| AppTextField | 글자 18 · 앞 아이콘 14 · 아이콘↔글자 14 → 15 · 15 · 10 | Figma `1501:10747` 글자 x=15, `654:5752` 아이콘 x=15·글자 x=49. 웹은 원래 15 |
| AppChip 높이 | 36 → 38 | Figma `1497:9998` 높이 38. 웹은 37.6(border-box) |

- 색은 컴포넌트가 실제로 쓰는 `색상/*` 변수를 먼저 따랐다(문서 원칙 "Figma 변수 값을 따른다"). Pink-600·700은 변수에 연결된 곳이 없어 v4 색상 문서 견본 값을 따랐다.
- 입력창 원인은 SDK 3.47.9 `input_decorator.dart`에 있다(코드에서 확인). M3는 `OutlineInputBorder.gapPadding`(기본 4)을 입력 앞뒤 `inputGap`으로 더하고, prefixIcon·suffixIcon과 입력 사이에 설정할 수 없는 4(`prefixToInputGap`·`inputToSuffixGap`)를 넣는다. Material 테두리는 여백에 포함되지 않는다. `InputDecorator` 구조는 그대로 두고 `gapPadding: 0`, 테두리 두께 1 더하기, 아이콘 간격에서 4 빼기로 맞췄다. 비활성·오류·readOnly 동작이 바뀌지 않아 영향 범위가 작기 때문이다. 대안인 Row로 직접 그리기는 테두리 상태와 포커스 처리를 다시 만들어야 한다.
- 칩은 웹처럼 테두리 1을 여백 바깥에 더했다. `AppFilterChip`은 이번 섹션에서 Figma 값을 확인하지 않아 그대로다.
- Head(B)는 새 필드로 추가하고 `head`(Head(SB))는 그대로 두었다. 홈·채팅·로그인 등 기존 호출자는 바뀌지 않는다.
- 추론: Pink-600·700과 Warning의 최종 의도는 디자이너 확인 전까지 추론이다. 변수와 문서 견본이 서로 다른 곳이 있다.

## 사용자의 이해

- 상태: 미확인. 설명만 제공했고 사용자 설명·실행 근거는 아직 없다.

## 구현 범위

- 앱: `lib/shared/theme/app_colors.dart`, `app_typography.dart`, `lib/shared/widgets/app_text_field.dart`, `app_chip.dart`
- 웹: `src/shared/styles/tokens.css`
- 문서: `docs/design-tokens.md` (원시·의미 색 표, Head(B), 입력창·칩 설명, `v4 대조` 절, 6절)
- 테스트: `test/shared/widgets/app_text_field_test.dart`(여백·간격), `app_chip_test.dart`(높이), `test/shared/theme/app_theme_test.dart`(Head(B))

## 검증

에이전트가 실행한 것:

- 수정 전 실패: 입력창 앞 아이콘 14(기대 15), 아이콘 뒤 글자 53(기대 49), 칩 36(기대 38), `headBold` 없음(컴파일 실패).
- 앱: `fvm dart format --set-exit-if-changed` exit 0, `fvm dart run tool/check_imports.dart` OK(138 files), `fvm flutter test` 247개 통과. `fvm flutter analyze`는 한글 경로에서 크래시(exit 255)해 영문 경로 복사본에서 실행했고 No issues found.
- 웹: `pnpm install --frozen-lockfile`, `format:check`, `lint`, `typecheck`, `test`(12개), `build` 모두 exit 0.
- iOS 렌더링: iPhone 17 Pro(iOS 26.4) 시뮬레이터, dev flavor. 임시 QA 진입점은 `/tmp` 복사본에만 두고 지웠다. 입력창 높이 47, 첫 글자 잉크 15.67~16.0pt(글자 15 + 글리프 여백), 아이콘 뒤 글자 49.67pt, 칩 38.0pt, 색 `#FFD6E9`·`#DC136C`·`#8E0341`·`#FFE7E7` 일치(이전 값 0픽셀), Head(B) 잉크 +13.7%.
- 웹 렌더링: vite와 헤드리스 WebKit(`Bun.WebView`), `/tmp` 복사본 QA 페이지(지웠다). 입력창 47, 글자 15/15, 아이콘 15, 간격 10/10, 칩 37.6, 경고 바탕 `rgb(255, 231, 231)`, 견본 4색 일치, head 600 / headBold 700, 24px / 31.2px.
- 증거 화면: 메인 저장소 `.omo/evidence/JECT-258/` (gitignore).

미실행: Android 에뮬레이터, 실제 화면 흐름(로그인·달력·알림), 사용자 직접 확인.
QA 상태: 자동 검증과 렌더링 확인 통과. 운영 준비: 커밋 전.

## 장애와 배포

- 예상 증상: 분홍 계열(달력 오늘·선택 원, 알림 점)과 경고 띠 바탕 색이 바뀐다. 입력창 글자가 3~4pt 왼쪽으로 가고, 칩이 2pt 높아져 좁은 화면에서 줄바꿈이 달라질 수 있다.
- 확인 순서: dev 빌드 `/dev/widgets`의 AppTextField·AppChip·AppNotice·달력 → `docs/design-tokens.md`의 v4 대조 표 → Figma 노드.
- 되돌리기: 해당 값만 이전 값으로 되돌린다. 토큰은 앱·웹·문서를 함께 되돌린다.
- 커밋·푸시·배포 요청: 없음.

## 다음 단계

- 디자이너 확인 6개 (`docs/design-tokens.md` v4 대조 절).
- 같은 원인 후속(추정, 이번 섹션 밖): `AppTextArea`는 OutlineInputBorder gapPadding 때문에 글자가 18로 추정되고, `AppDropdown`·`AppFilterChip`은 테두리가 여백에 포함되지 않는다. Figma 값을 확인한 뒤 맞춘다.
- Input `Fill/서브텍스트`·`2Fill` variant, 밴드 합동공연 Dark 팔레트, Accent.
