# PR 체크리스트 — 누가 만들어도 같은 결과가 나오게

두 사람이 번갈아 만들어도 사용자는 한 사람이 만든 것처럼 느껴야 하고, 어느 기능 폴더를 열어도 같은 자리에 같은 것이 있어야 한다.
"같은 느낌"은 취향이 아니라 **검사할 수 있는 항목**으로 바꿔야 지켜진다. 이 문서는 그 항목과, 각 항목이 어떤 일관성을 지키는지(왜 보는지), 어떻게 확인하는지를 적는다.

PR 템플릿(`.github/PULL_REQUEST_TEMPLATE.md`)의 체크박스는 이 문서의 요약이다. 체크박스가 왜 있는지 모르겠으면 여기서 같은 번호를 찾는다.

## 0. 쓰는 법

- **작성자**는 PR을 올리기 전에 A를 위에서부터 돌린다. 해당 없는 항목은 템플릿에서 "해당 없음"이라고 쓰고 지운다. 체크 안 한 채로 두지 않는다.
- **리뷰어**는 B 순서로 읽는다. 작성자가 체크했다고 믿지 않고, B3(실패 방어)과 B5(일관성)는 직접 본다.
- 항목이 많아 보이면 항목을 빼지 말고 **자동화로 옮긴다**(D절). 사람이 보는 항목은 자동화가 안 되는 것만 남긴다.
- 항목을 늘리는 기준: 같은 지적이 PR 두 번 나오면 체크 항목으로 올린다. 세 번 나오면 린트·테스트·공통 위젯으로 옮긴다.

## 1. "같은 느낌"은 무엇으로 만들어지나

사용자가 느끼는 일관성과 개발자가 느끼는 일관성을 나눠서, 각각 어느 항목이 지키는지 표로 둔다. 항목을 추가·삭제할 때 이 표가 비는 칸이 없는지 본다.

| 사용자가 느끼는 것 | 구체적으로 | 지키는 항목 |
| --- | --- | --- |
| 화면 리듬이 같다 | 여백·모서리·글자 크기가 화면마다 같은 단계 | A6 토큰 |
| 기다리는 모양이 같다 | 로딩·빈 결과·실패 화면이 어느 화면에서나 같은 위젯 | A5 화면 상태 4종, A7 공통 위젯 |
| 실패해도 당황하지 않는다 | 오류 문구가 "무엇이, 어떻게 하면"으로 끝나고 재시도가 있다 | A5, A8 문구 |
| 두 번 눌러도 사고가 안 난다 | 신청·예매·결제 버튼 연타, 느린 네트워크 | A4 명령 처리 |
| 로그아웃·계정 전환이 깨끗하다 | 이전 계정 데이터가 비치지 않는다 | A4, A9 데이터 |
| 앱과 웹이 한 제품이다 | 같은 색·간격·문구 톤, bridge로 자연스럽게 이동 | A6, A8, A12 수동 확인 |

| 개발자가 느끼는 것 | 구체적으로 | 지키는 항목 |
| --- | --- | --- |
| 어느 기능을 열어도 같은 자리에 있다 | `models/ data/ presentation/` 배치, 파일 접미사 | A3 구조 |
| 어디서 무엇을 import해도 되는지 고민 안 한다 | `app → features → core/shared` 한 방향 | A3 |
| 테스트가 어디 있고 무엇을 지키는지 안다 | 같은 경로, 4케이스, 문구 고정 없음 | A10 테스트 |
| 환경·경로·비밀이 흩어지지 않는다 | `env`, `routes` 한 곳, 토큰은 보안 저장소 | A9 |
| 이력을 검색할 수 있다 | 브랜치·커밋·PR 제목 형식 | A1 형식 |

## A. 작성자 체크 (PR 올리기 전)

각 항목: **본다** → **왜** → **확인 방법**. 확인 방법의 `grep`은 도우미일 뿐 통과 조건이 아니다. 결과를 보고 사람이 판단한다.

### A1. 형식

- 본다: 브랜치 `feat/JECT-123-...`, 커밋 `feat(JECT-123): 한글 요약`, PR 제목 `[JECT-123] 요약`, 템플릿 섹션이 비어 있지 않음, PR 하나 = Task 하나.
- 왜: 나중에 "이 화면 언제 왜 바뀌었지"를 사람 기억이 아니라 `git log`로 찾기 위해.
- 확인: `git log --oneline main..HEAD`로 커밋 제목을 본다. 관계없는 변경(리팩터링, 포맷만)이 섞였으면 PR을 나눈다.

### A2. 자동 검증

- 본다: 앱(`apps/mobile`에서) `fvm dart format --set-exit-if-changed --output=none lib test tool` / `fvm flutter analyze` / `fvm dart run tool/check_imports.dart` / `fvm flutter test`, 웹(`apps/web`에서) `pnpm format:check && pnpm lint && pnpm typecheck && pnpm test && pnpm build && pnpm build:dev`. 전부 종료 코드 0. 앱·웹 파일이 바뀐 PR이면 CI가 같은 것을 돌린다(문서만 바뀐 PR은 CI가 돌지 않는다).
- 왜: 가장 싸게 얻는 일관성. 사람이 보기 전에 기계가 거를 수 있는 것은 전부 기계에 맡긴다.
- 확인: 마지막 커밋 뒤에 다시 돌린다. 경고를 `// ignore:`·`eslint-disable`·`any`로 지웠으면 그 자체가 실패다.

### A3. 구조와 의존성

- 본다:
  - 새 파일이 `features/<x>/{models,data/{dto,services,repositories},presentation/{providers,view_models,views,widgets}}` 또는 웹 `features/<x>/{api,hooks,components,pages}` 안에 있다.
  - `core`·`shared`에 공연·예매 같은 도메인 단어가 들어가지 않았다.
  - `features`가 `app/`을 import하지 않는다(웹은 `app/routes.ts`만 예외). 다른 기능의 `presentation/`(웹: `components/ hooks/ pages/`)을 import하지 않는다.
  - 빈 폴더, "나중에 쓸" 인터페이스·UseCase·추상 클래스가 없다.
- 왜: 구조가 같아야 상대가 내 기능을 고칠 때 찾는 시간이 0에 가깝다. 의존성 방향이 지켜져야 아래층을 따로 테스트하고 바꿀 수 있다.
- 확인: 웹은 `pnpm lint`(ESLint `import-x/no-restricted-paths`), 앱은 `fvm dart run tool/check_imports.dart`가 방향 위반을 잡는다. 아래 grep은 린트가 못 보는 것(도메인 단어가 core/shared에 들어갔는지 등)을 눈으로 볼 때 쓴다.
  ```bash
  # 앱: features가 app을 import하는가
  grep -rn "import '.*\/app\/" apps/mobile/lib/features
  # 앱: 다른 기능의 presentation을 import하는가 (자기 기능 이름은 결과에서 눈으로 제외)
  grep -rn "features/.*/presentation" apps/mobile/lib/features
  # 웹: features가 app(routes 제외)이나 다른 기능 내부를 import하는가
  grep -rn "from '.*\/app\/" apps/web/src/features | grep -v routes
  grep -rnE "from '\.\./\.\./[a-z]+/(components|hooks|pages)" apps/web/src/features
  ```
  자세한 허용표: [mobile-architecture.md 2절](./mobile-architecture.md#2-의존성-방향), [web-architecture.md 2절](./web-architecture.md#2-의존성-방향).

### A4. 명령 처리 (쓰기 요청이 있을 때)

- 본다:
  - 신청·예매·결제·입금 확인·취소는 버튼 → ViewModel 메서드. Provider `build()`나 `initState`에서 쓰기 요청을 보내지 않는다.
  - ViewModel이 `state.isLoading`이면 두 번째 호출을 무시한다. 버튼도 로딩 중 비활성.
  - 서버 멱등성 키 계약이 있으면 같은 작업에 같은 키. 타임아웃이면 실패로 표시하지 않고 결과를 먼저 조회한다.
  - 로그아웃·계정 전환이 걸리는 변경이면 Repository 캐시·소켓 정리가 호출되고, 이전 세션의 늦은 응답을 버린다.
  - 권한·재고·가격·마감을 화면에서 확정하지 않는다. 버튼을 숨겨도 서버 응답으로 다시 판단한다.
- 왜: 돈·자리가 걸린 명령이 두 번 가거나 유실되면 사용자 신뢰가 한 번에 깨진다. 이건 화면마다 다르게 처리하면 안 되는 대표적인 "같은 느낌"이다.
- 확인: 시뮬레이터에서 네트워크를 느리게(Network Link Conditioner / Chrome throttling) 두고 버튼을 연타한다. 요청이 한 번만 가는지 로그로 본다.

### A5. 화면 상태 4종

- 본다: 데이터를 받는 화면은 **로딩 / 빈 결과 / 실패 / 정상**이 전부 있다. 실패에는 재시도나 다음 행동(로그인으로 이동 등)이 있다. 로딩·빈·실패는 `shared/widgets`의 `LoadingView`·`EmptyView`·`ErrorView`(웹: `shared/ui`)를 쓰고 화면마다 새로 그리지 않는다.
- 왜: 사용자가 "기다리는 모양"과 "안 될 때 모양"을 한 번 배우면 모든 화면에서 통하게.
- 확인: `AsyncValue.when`(앱)의 세 분기가 모두 있는지, 웹은 `loading / error / empty / data` 분기. 시뮬레이터에서 비행기 모드로 실패 화면을 한 번 띄운다.

### A6. 디자인 토큰

- 본다: 위젯·컴포넌트 코드에 hex, `Colors.*`, 숫자 패딩·폰트 크기·모서리가 없다. 전부 `context.colors.*` / `AppSpacing` / `AppRadius` / `textTheme`, 웹은 `var(--color-*)` 등. 토큰 값을 바꿨으면 앱·웹·`design-tokens.md` 셋 다 같은 PR에 있고 캡처가 있다.
- 왜: 화면 리듬(여백·모서리·글자 크기)이 같으면 디자인이 달라도 "같은 앱"으로 느낀다. 반대로 한 화면만 14px 대신 15px이면 이유 없이 어색하다.
- 확인:
  ```bash
  grep -rnE "Color\(0x|Colors\.|fontSize: [0-9]|EdgeInsets\.(all|symmetric|only|fromLTRB)\([0-9]|Radius\.circular\([0-9]" apps/mobile/lib/features apps/mobile/lib/app
  grep -rnE "#[0-9a-fA-F]{3,8}\b|[0-9]+px" apps/web/src/features apps/web/src/shared/ui --include='*.css'
  ```
  예외: `1px` 테두리, `max-width`·breakpoint, 진행률 같은 동적 값. 예외는 그 줄에 짧게 이유를 남긴다. 기존 단계로 안 되면 [design-tokens.md 2절](./design-tokens.md#2-바꾸는-절차)대로 디자이너와 범용 단계를 추가한다. 특정 화면 이름이 붙은 토큰은 만들지 않는다.

### A7. 공통 위젯·컴포넌트 재사용

- 본다: 버튼·입력창·카드·목록 아이템·바텀시트가 `shared/widgets`(웹 `shared/ui`)에 이미 있으면 그것을 쓴다. 비슷한 것을 기능 안에서 다시 만들지 않는다. 새로 만든 조각이 두 번째 기능에서도 필요해지면 그때 `shared`로 올린다(첫 번째 때 미리 올리지 않는다).
- 왜: 같은 버튼이 두 개면 반드시 한쪽만 고쳐지는 날이 온다.
- 확인: PR 안의 새 위젯 이름을 `shared/widgets` 목록과 비교. "Primary", "Button", "Card"가 이름에 들어가면 한 번 더 의심한다.

### A8. 문구와 접근성

- 본다:
  - 오류 문구는 "무엇이 안 됐는지 + 무엇을 하면 되는지" 두 조각. 예: "예매 정보를 불러오지 못했어요. 다시 시도해 주세요."
  - 버튼은 동사로 끝난다(확인·예매하기·다시 시도). "OK", "Submit" 금지.
  - 같은 뜻은 같은 단어: 공연/행사, 예매/예약, 신청/지원 중 하나로 통일(팀이 정한 용어집 — E절).
  - 탭 영역 최소 44×44(앱)·44px(웹), 글자 크기는 토큰, 이미지에 대체 텍스트(웹 `alt`, 앱 `Semantics`).
- 왜: 톤이 섞이면 사용자는 "다른 사람이 만든 화면"을 바로 알아챈다.
- 확인: 새 문구를 PR 본문에 모아 적는다(리뷰어가 톤을 한 번에 본다).

### A9. 데이터·보안·설정 위치

- 본다:
  - 토큰·개인정보(이름·연락처·입금자명)·비회원 조회 비밀값이 로그, URL, 분석 이벤트, SharedPreferences/localStorage에 들어가지 않는다.
  - 환경값은 앱 `app/env.dart`, 웹 `shared/config/env.ts`에서만 읽는다. 경로 문자열은 `AppRoutes`/`routes.ts`에만.
  - 역할별로 서버가 제한한 필드만 쓰고, 화면에서 더 보여주지 않는다(현장 담당자는 연락처 뒤 4자리만 등).
  - 외부 링크는 브라우저로, 외부 앱 scheme은 허용 목록으로. bridge는 `shared/bridge` 한 곳.
- 왜: 한 번 새면 되돌릴 수 없는 것들. 사람마다 다르게 다루면 반드시 한 곳이 뚫린다.
- 확인: `grep -rn "print(\|debugPrint(\|console.log(" <변경 파일>`로 로그 줄을 보고 무엇을 찍는지 확인. URL 만드는 코드가 있으면 쿼리에 무엇이 들어가는지 본다.

### A10. 테스트

- 본다:
  - 위치: 앱은 `test/`에 `lib/`와 같은 경로, 웹은 파일 옆 `*.test.tsx`.
  - ViewModel은 로딩·성공·실패·중복 실행 4케이스, View는 로딩·빈·실패·정상 4케이스(해당하는 것만).
  - 테스트가 **실패할 수 있다**: assert를 반대로 바꾸면 빨개진다. mock이 테스트 대상까지 대신하지 않는다.
  - 문구를 고정하지 않는다(`find.text('로그인')` 대신 `find.byType`·`byKey`·역할). 고정 `sleep`·`pump(Duration)`으로 성공을 기다리지 않는다.
  - 생성 파일(`*.g.dart`)은 테스트하지 않는다.
- 왜: 테스트는 "같은 동작"의 증거다. 문구 테스트는 디자인 변경마다 깨져서 결국 아무도 안 믿게 된다.
- 확인: 새 테스트 파일 하나를 골라 assert 하나를 뒤집고 돌려본다. 통과하면 그 테스트는 아무것도 지키지 않는다.

### A11. 생성 파일·의존성

- 본다: 모델을 바꿨으면 `build_runner`를 돌렸고 `*.freezed.dart`·`*.g.dart`가 같이 커밋됐다. `pubspec.yaml`/`package.json`을 바꿨으면 lock 파일이 같이 있다. 메이저 버전·SDK 제약 변경은 PR 본문 "호환성"에 적고 사전 공유했다.
- 왜: 생성 파일이 빠지면 상대 환경에서만 빌드가 깨진다. 의존성은 두 사람 환경이 같아야 "내 컴퓨터에선 되는데"가 없다.
- 확인: `git status`가 깨끗한 상태에서 `fvm dart run build_runner build --delete-conflicting-outputs`를 다시 돌려 diff가 없는지 본다.

### A12. 수동 확인

- 본다: 수락 기준 시나리오를 실제로 한 번 돌렸다. 앱은 바꾼 플랫폼 캡처, 웹은 모바일 폭 캡처. 아래 중 해당하는 것:
  - 앱: 뒤로가기, 딥링크로 직접 진입, 회전·다크 모드(지원 시), 앱 재실행 후 세션 복원
  - 웹: 새로고침, 뒤로가기, 일반 브라우저와 앱 WebView 둘 다, bridge 없는 환경에서 깨지지 않음
  - 권한이 필요한 기능: 거부 → 설정으로 안내 → 복귀
- 왜: 자동 검증은 코드가 "맞는지"를 보고, 수동 확인은 "쓸 만한지"를 본다. 둘 다 있어야 한다.
- 확인: PR 본문 "검증"에 기기·시나리오·결과를 한 줄씩 적는다. 캡처 없는 UI 변경은 리뷰어가 돌려보낸다.

### A13. 사전 공유

- 본다: DI 등록, 공유 모델, 라우팅, 네이티브 설정, bridge, 디자인 토큰, `pubspec.yaml`/`package.json` 중 하나라도 바꿨으면 PR 전에 상대에게 한 줄 알렸다.
- 왜: 이 일곱 가지는 상대의 작업과 충돌하거나 상대가 모르면 깨진다.
- 확인: PR 본문 "호환성·주의"에 알린 날짜/채널을 적는다.

## B. 리뷰어 체크 (읽는 순서)

리뷰는 파일 목록 순서가 아니라 **동작 순서**로 읽는다. 작성자가 PR 본문 "리뷰 순서"에 경로를 적어 두면 그대로 따라간다.

| 순서 | 읽는 것 | 보는 것 | 근거 |
| --- | --- | --- | --- |
| B1 진입점 | `router.dart`/`router.tsx`, 버튼 `onPressed` | 어떤 메서드로 들어가는가. 경로가 상수인가 | A3, A9 |
| B2 상태·요청 | ViewModel, Repository, Service | 상태가 알맞은 범위에 있는가(로컬/화면/ID별/공통). 요청은 Service에만, 변환은 Repository에만 | A3, A4 |
| B3 실패 방어 | 같은 파일들 | 4종 UI, 중복 실행, 늦은 응답, 오류 매핑, 일시 오류로 로그아웃하지 않음 | A4, A5 |
| B4 테스트 | `test/`·`*.test.tsx` | 무엇을 지키는가, 빠진 케이스, 뒤집으면 실패하는가 | A10 |
| B5 일관성 | 캡처, 기존 비슷한 화면 | 기존 목록·상세 화면과 여백·카드·빈 화면·문구 톤이 같은가. 토큰 grep 결과 | A6, A7, A8 |
| B6 범위 | diff 전체 | PR이 Task 하나인가. 관계없는 리팩터링·포맷 변경이 섞였나 | A1 |

리뷰 코멘트 규칙:

- `[must]` 머지 전 고쳐야 함 / `[nit]` 고치면 좋지만 머지를 막지 않음. 접두사를 붙인다.
- 근거는 이 문서나 구조 문서의 절 번호로 쓴다("A5: 실패 화면 없음"). 취향이면 `[nit]`로 쓰고 근거를 요구하지 않는다.
- 설계가 갈리면 댓글 왕복 3회 안에 통화한다. 결론을 PR에 한 줄 남긴다.
- 승인 뒤 `[nit]`만 남았으면 작성자가 고치고 바로 머지한다.

## C. 머지 뒤

- squash 커밋 제목이 커밋 규칙 `type(JECT-123): 요약`인지 본다. GitHub 기본값은 PR 제목(`[JECT-123] 요약`)이므로 머지할 때 고친다.
- 공통 변경(A13)이었으면 상대가 `develop`을 당겨 받았는지 확인한다.
- 배포에 들어갔으면 `docs/releases.md`에 한 줄(소스 커밋·검증·patch 번호).

## D. 자동화로 옮길 것 (CI·린트가 생기면)

사람이 보는 항목을 줄이는 순서. 위에서부터 효과가 크다.

| 항목 | 지금 | 옮길 곳 |
| --- | --- | --- |
| A2 자동 검증 | **된 것**: `.github/workflows/mobile.yml`, `web.yml` | - |
| A3 의존성 방향 (웹) | **된 것**: ESLint `import-x/no-restricted-paths` | - |
| A3 의존성 방향 (앱) | **된 것**: `tool/check_imports.dart` (CI 포함) | 규칙이 늘면 `custom_lint`로 옮기는 것을 검토 |
| A6 토큰 (웹) | grep | stylelint `declaration-property-value-disallowed-list`로 hex·px 차단(예외 목록 포함) |
| A6 토큰 (앱) | grep | `custom_lint` 규칙 (`Color(0x`, `Colors.` 금지 in features) |
| A11 생성 파일 | **된 것**: `mobile.yml`이 `build_runner` 후 `git diff --exit-code` | - |
| A1 형식 | 눈 | commitlint / PR 제목 정규식 검사 |

## E. 팀이 아직 정해야 하는 것

이 문서의 항목 중 아래는 값이 비어 있다. 정해지면 해당 항목에 적는다.

- 문구 톤: 존댓말("~해요" / "~합니다"), 마침표 사용, 느낌표 금지 여부
- 용어집: 공연·행사, 예매·예약, 신청·지원, 밴드·팀, 공연장·장소 — 각각 하나로
- 오류 문구 사전: 네트워크·인증 만료·서버 오류·찾을 수 없음 네 가지의 표준 문구
- 공통 위젯 1차 목록: Button, TextField, LoadingView, EmptyView, ErrorView, Card — 언제 만들지
- 캡처 기준 기기: iOS 시뮬레이터 모델, Android 에뮬레이터 API, 웹 폭(예: 390px)
