# JECT-258 디자인 시스템 대조와 COMPONENT V3 후속

## 후속 현재 상태 (2026-11-26)

- 작업 위치: `.worktrees/JECT-258`, `feat/JECT-258-concert-dark-components`, 기준 `origin/develop` `2f420c5`. 부모가 만든 워크트리를 그대로 사용했다. 이전 PR #11은 머지된 상태이며, 이번 변경은 아직 커밋하지 않았다.
- 허용 범위: 확인된 COMPONENT V3 재사용 컴포넌트·공연 테마·공통 웹 토큰/컴포넌트·갤러리·자동 테스트·문서. Jira 쓰기는 부모 담당이다. 커밋·푸시·PR·배포는 하지 않는다. 다른 워크트리는 수정하지 않았다.
- 사용자 지시 변경: UI QA는 사용자가 직접 진행한다. 에이전트는 기기·브라우저·스크린샷 QA를 시작하지 않았고 자동 위젯 테스트·정적 검사·웹 빌드만 실행했다. 시각 수용 여부·사용자 이해는 미확인이다.

### 기준과 구현

컴포넌트는 페이지 `881:3898`, V3 배너 `1061:40813` 아래 공통 `1061:36797`·공연페이지 `1060:6106`·팝업 `1915:13425`를 따른다. V2 `1979:12105`와 후보 `1988:14018`은 제외했다.

| 확인된 master/variant | 실제 코드 |
| --- | --- |
| Input set `724:3663` 서브텍스트 `1959:20282` | 앱 `AppTextField.subtext`, 웹 `TextField subtext`; 56 높이·17 행 높이·4 간격 |
| 같은 set 2Fill `1701:13048` | `variant=search`와 기존 prefix/suffix 합성; 간격 8·Medium, 삭제는 호출자 |
| Dialog `1681:12975` | 앱·웹 notice/content 슬롯. AppNotice 글자·여백 재정의 지원. 기존 슬롯 없는 모양 보존 |
| 일정있음 `1959:19911` | CalendarDayCell.hasEvent; 4 점·top 32·선택과 독립·일정 semantics |
| SummaryBox `2014:19752` | 기존 QrListCard.summary / 웹 SummaryBox. 16/14 여백, 3줄 303 × 108 |
| ProgressCard 판매 마감 `2014:20680` / 판매 중 `2014:20681` | 기존 ticketSales·info·actions로 두 예시 합성, 중복 카드/enum 추가 없음 |
| Dark 팔레트 `2218:149494` / 공연 화면 `2217:123929` | AppColors.concertDark·AppTheme.concertDark / data-theme=concert-dark |

V3 Input 인스턴스 `1060:6495`의 내부 노드가 원본 Fill `654:5754`와 일치하는 계보를 확인했다. 원본 set이 별도 `디자인시스템_v4` 페이지에 있다는 이유로 V2를 채택한 것이 아니다. V3 팝업에는 “다이얼로그로 통합. 기존거는 v.2에..”라고 적혀 있다. 기존 ShowConfirmPopup은 보존하고 V2 popup을 새로 구현하지 않았다.

### 선택 이유와 한계

- 라이트는 기존 버튼 black·칩 #171719·입력 white/D9D9D9를 각 역할 기본값으로 유지했다. 다크에서만 라임 action/selection과 surface control로 바꾼다. 전역 OS 다크 연동은 하지 않았다.
- Theme는 ColorScheme·textTheme·IconTheme·기존 ThemeExtension을 함께 바꾼다. 단순 배경 교체로 아이콘이 검게 남는 문제를 막는다. 공식 API의 Theme/ThemeData.copyWith 원리와 로컬 코드·위젯 테스트 결과를 구분했다.
- SummaryBox는 새 행 렌더러를 복제하지 않고 QrListCard의 여백만 바꾼다. 회귀 테스트가 제한된 부모 안에서 Column이 600 높이로 늘어나는 것을 잡아 mainAxisSize.min으로 원인을 고쳤다.
- 기본 입력창 47·간격 10과 슬롯 없는 Dialog 간격은 유지한다. 보조행은 helperText와 바깥 테두리, 검색형은 기존 아이콘 슬롯을 쓴다.
- 팔레트 Destructive #D64146와 실제 화면 삭제 글자 #FF5A5F가 다르다. 현재는 팔레트 기준이다. 분홍·파랑·inverse의 별도 다크 명세는 임의로 만들지 않았다.
- get_design_context는 핵심 Input·Dialog·일정·Dark에서 성공했다. SummaryBox·ProfileNotice·판매 카드의 추가 원문 재조회는 MCP metadata timeout으로 실패했다. SummaryBox는 이미 확인한 좌표와 기존 QR 카드의 의미 색을 합성했다.

### 검증

- 수정 전: subtext·variant·notice·hasEvent·concertDark·QrListCard.summary가 없어 새 계약 테스트가 실패했다. 웹도 안내·보조행 미표시로 실패했다.
- 앱: 전체 위젯/단위 테스트 **255개 통과**. import 방향 검사 OK(139 files). format 통과. 한글 경로의 알려진 analyze 문제를 피해 영문 임시 복사본에서 `fvm flutter analyze` → **No issues found**.
- 웹: format·lint·typecheck·테스트 **15개**·build 통과.
- 기기·브라우저·스크린샷 QA: 사용자 지시로 미실행. 자동 위젯 테스트는 UI 세션이나 시각 수용 판정을 대신하지 않는다.

### 직접 확인 / 장애 시 순서

개발 빌드에서 DEV 띠 길게 → concert V3. 라이트/공연 다크 각각에서 보조행 입력 유지 → 검색 지우기 → 일정 있는 날짜 선택 → 다이얼로그의 안내·SummaryBox·확인/취소 결과 → 판매 중/마감 합성을 확인한다. `/dev/widgets?folder=concert`도 같은 폴더다. 폴더 바깥이 다크로 바뀌지 않아야 한다.

문제가 있으면 `concert_gallery_section.dart`의 호출 인자 → 해당 shared 위젯 → AppColors/AppTheme의 역할 → `docs/design-tokens.md` 7절과 Figma 순으로 확인한다. 서비스·토큰 저장·서버 쓰기 경로는 이번 변경에 없다.

### 부모 전달용 남은 범위

- 공연 master의 출처는 확인했으나 별도 스타일·데이터·행동 계약이 더 필요한 항목: ProfileNotice `2034:15430`(AppNotice 합성 후보), PhotoList `2034:15467`(photo/video), LineupCell `2034:16185`, PlayList `2075:17309`(추가/추가됨/리스트/편집), PaymentStatus `2086:17775`, 입금확인 `1338:8348`의 입장 상태 매핑. 이번에는 임의의 독립 UI를 추가하지 않았다.
- 관객웹 라이브러리(후보 영역과 구분): PinInput `2014:16694`, SetlistCard `2014:20862`, InfoTable `2175:27095`, InfoBox `2175:27352`, StatusBadge `2188:24937`, TicketSummary `2188:24948`, InfoRow `2188:24984`, KeyValue `2188:25000`, QRTicket `2188:25010`, QRPanel `2188:25050`, ContactCard `2188:25065`, PasswordResult `2188:25076`. 이 목록으로 전체 관객웹 화면을 추가하지 않았다. Jira 갱신은 부모가 판단한다.

---

아래는 이전 PR #11에 포함된 1차 작업의 작성 당시 기록이다.

작성일: 2026-11-26. 작업 위치: `.worktrees/JECT-258`, 브랜치 `feat/JECT-258-design-system-v4`
(origin/develop `4ace55e`에서 시작).

## 1차 작업 당시 상태

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
