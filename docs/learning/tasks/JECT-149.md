# JECT-149 공연 생성: 합의 계약 범위 구현

작성일: 2026-11-26. 작업 위치: 기존 `.worktrees/JECT-149`,
브랜치 `feat/JECT-149-create-concert`.

## 허용 범위와 근거

- 사용자 요청으로 구현과 로컬 검증까지 진행했다. 커밋·푸시·PR·Jira 쓰기 권한은 없으며 실행하지 않았다.
- 루트 AGENTS, overview/workflow/mobile-architecture/design-tokens/pr-checklist,
  기존 pubspec, 라우터, 인증·세션·공통 위젯과 관련 테스트를 먼저 읽었다.
- 계약 근거는 Notion MCP로 조회한 [합동공연 생성](https://app.notion.com/p/fe9f857a78dc82d29636017e20c25592)
  (`JECT-217`, `POST /api/v1/concerts`)과 [코드 목록 조회](https://app.notion.com/p/10cf857a78dc82c5b9c2015450299ae9)
  (`GET /api/v1/codes?types=GENRE`)다. Notion 원문은 수정하지 않았다.
- 사용자에게 전달된 독립 코드 리뷰
  `.omo/evidence/JECT-149-code-review.md`의 H1/M1/M2/M3 및 유용한 낮은 우선순위 지적을 반영했다.

## 구현과 선택 이유

입력 → `ConcertCreationViewModel.submit` → `ConcertRepository.create`
→ `ConcertService.create` → 확인된 공연 ID → 호출자의 `onCreated` 순서다.
화면에서 HTTP·Repository를 직접 호출하지 않는다.

### 입력과 화면

- `lib/features/performances/models/concert_draft.dart`:
  `HostBand`는 양수 ID와 표시 이름이 있는 주최 밴드 문맥이다.
  **현재 로그인 사용자가 대표자인지는 호출자가 먼저 확보하고 서버가 최종 확인한다.**
  `HostBand`의 동등성은 밴드 ID 기준이어서 같은 밴드를 새 객체로 전달해도
  제출 중인 family Provider가 다른 것으로 바뀌지 않는다.
- `ConcertGenre`의 code/name은 서버 응답에서 읽는다. 화면에는 name만 보이고
  제출 전 실제 제공된 code인지 검사한다. 고정 장르 목록이나 장르 최대 개수는 만들지 않았다.
- 제목 1~30자, 장르 한 개 이상, 주최 팀을 제외한 모집 팀 수 한 팀 이상을 검사한다.
  날짜는 로컬 오늘부터 허용한다. “오늘 이후” 문구보다 계약의 처리 로직
  “오늘보다 이전이면 거절”을 적용했다.
- 날짜·시간·장소·대관비 미정은 null이다. 시간은 시작/종료가 함께 있어야 하고,
  자정을 넘기는 종료 시간도 허용한다. 장소 100자, 주소 200자,
  대관비는 서버 Integer 범위의 0~2,147,483,647원이다.
- `region`과 `customGenre`는 합의 전이라 입력받거나 전송하지 않는다.
  `posterImageUrl`은 null이며 업로드 UI·임의 URL 입력을 제공하지 않는다.
- `presentation/views/concert_creation_view.dart`:
  AppTopBar, AppFormSection, AppTextField, AppChip, AppStepper, AppButton과
  기존 색·글자·간격 토큰을 재사용했다. 숫자 ID를 사용자에게 입력시키지 않는다.
- Layout: 본문은 하나의 세로 ListView, 폼 좌우 여백 20, 그룹 사이 24/32,
  내부 간격 8, 넓은 창에서 본문 최대 폭 600이다.
  최대 폭 600은 이 화면의 임시 레이아웃 상한으로 코드에 명시했으며 디자인 확인이 필요하다.
  기존 프로젝트는 light 테마만 제공하고 글자 배율을 고정한다.
  이번 작업은 별도 Figma 픽셀 일치 검증을 주장하지 않는다.

### 요청·응답·재시도

- Service는 전송과 응답 형태 해석만 담당한다.
  `post<Object?>` 응답에 패턴 매칭을 적용해
  HTTP 201, `COMMON_000`, 양수 int `concertId`가 모두 있어야 성공한다.
  예상하지 못한 응답은 성공으로 꾸미지 않는다. TypeError를 잡아 숨기지 않는다.
- `data/dto/concert_api_failure_dto.dart`는 HTTP 상태·서버 code·field/reason·
  확실한 미전송 여부만 보존한다. 사용자 행동으로 바꾸는 책임은 Repository에 둔다.
  입력 오류는 해당 항목 아래에 표시하고, `CONCERT_010`은 시간,
  `CONCERT_002`는 날짜, `AUTH_005`는 안내 후 돌아가기 동작으로 연결했다.
- ViewModel은 첫 await 전에 submitting을 설정한다. Repository도 밴드별 진행 요청을
  막는다. 성공 후 같은 화면에서 재제출하지 않는다.
- `AuthInterceptor.allowReplayKey: false`를 생성 POST에 지정했다.
  확정 거절인 `AUTH_002`에서는 토큰을 갱신하되 **POST를 자동 재전송하지 않는다.**
  사용자가 다시 누르면 새 토큰으로 요청한다. 재발급 최종 거절은 기존 SessionExpiry로 처리한다.
  재발급 대기 중 로그인 수명이 달라져 저장된 refresh token이 바뀌면 이전 결과를 저장하지 않는다.
  이전 access token으로 보낸 늦은 최종 인증 오류가 새 세션을 만료시키지 않도록 확인한다.
- 연결 전 타임아웃과 인증서 거절은 확실한 미전송으로 분리해 수동 재제출을 허용한다.
  `connectionError` 전체를 미전송으로 취급하지 않는다.
  소켓 reset·전송/수신 timeout·5xx·알 수 없는 성공 응답은 생성 여부가 불명확할 수 있어
  잠그고 생성 여부 확인을 안내한다. 결과 조회·멱등성 계약이 없으므로 재시도 버튼으로 우회하지 않는다.
- `ApiLogInterceptor.logBodyKey: false`로 주소 등 폼 본문과 응답 본문을 기록하지 않는다.
  공통 `_body` 처리로 요청·성공·오류에서 같은 정책을 적용한다.

### 세션과 이동 경계

- `SessionRepository.identity/changes`는 토큰 값을 내보내지 않는 로그인 수명 신호다.
  로그인 저장·로그아웃 시 바뀌며 온보딩 다음 단계 변경으로는 바뀌지 않는다.
- `concertSessionProvider`가 이 신호를 구독한다. 로그인 수명이 바뀌면
  `concertRepositoryProvider`가 새 Repository를 만들고 장르/제출 Provider도 갱신된다.
  대기·불명확 잠금이 다른 계정으로 넘어가지 않는다.
- ViewModel은 각 제출의 dispose 여부를 캡처한다. Notifier가 재빌드된 뒤 도착한
  이전 응답이 새 상태를 갱신하지 않는다.
- `/shows/new`를 기존 `AppRoutes.showNew`로 등록했다.
  호출자가 `HostBand`를 `extra`로 넘겼을 때만 폼을 연다.
  문맥 없는 직접 진입·raw ID 쿼리는 안내 화면이며 API를 호출하지 않는다.
  로그인 수명이 바뀌면 이전 밴드 폼을 닫는다.
- `push<int>` 호출은 확인된 공연 ID를 pop 결과로 받는다.
  단독 go 진입은 확인된 성공 상태와 돌아가기 버튼을 제공한다.
  없는 공연 상세 경로로 성공을 가장해 이동하지 않는다.

## 아직 필요한 외부 통합과 한계

1. 현재 세션에서 대표자인 밴드를 조회·선택하는 기능과 홈 진입 버튼은 미구현이다.
   임의 밴드 ID를 넣어 연결하지 않았다. 통합 호출 모양은 아래와 같다.

   ```dart
   final concertId = await context.push<int>(
     AppRoutes.showNew,
     extra: HostBand(id: selectedBand.id, name: selectedBand.name),
   );
   ```

   `selectedBand`는 현재 세션의 대표자 밴드 선택 결과여야 한다.
   위 코드는 통합 예시이며 이 작업에 가짜 `selectedBand` 구현을 추가하지 않았다.

2. 공연 상세·내 공연 목록 라우트가 완성되면 성공 ID를 실제 상세에 연결해야 한다.
   현재는 위젯 콜백/라우트 반환 값이 통합 경계다.
3. 장르 API의 실제 서버 배포와 대표자 검증은 백엔드 선행 조건이다.
   계약상 생성 API 대표자 검증은 밴드 기능 뒤 JECT-248에서 적용 예정이다.
4. 포스터 업로드, 장소 검색/지도, 기존 공연 정보 가져오기, 지역 코드 정책,
   customGenre와 장르 최대 개수는 이번 합의 범위 밖이다.
5. 불명확 잠금은 **현재 로그인 수명의 메모리 안**에서 유지된다.
   앱 종료·로그아웃을 넘어 중복 생성을 완전히 막는 서버 멱등성/결과 조회 계약은 없다.
   생성 여부가 불명확하면 앱을 다시 열어 재생성하는 대신 운영 담당자에게 확인해야 한다.
6. 실서버 POST, 실제 대표자 계정, 네이티브 키보드/피커와 실제 기기 E2E는 검증하지 않았다.
   사용자 이해·직접 확인·운영 준비 완료도 대신 선언하지 않는다.

## 테스트 근거와 검증 이력

- 새 모델 테스트: 미정 null, 서버 코드 검증, 제목/장소/주소/금액 경계,
  오늘 날짜·자정 통과 시간.
- 실제 Dio adapter 기반 테스트: 코드 API, 생성 envelope/ID, 400 필드·시간·날짜,
  403, 5xx, malformed 응답, 인증/로그 옵션.
- ProviderContainer 테스트: 로딩·중복 실행·확정 성공·검증 거절 후 수정·
  불명확 잠금과 재진입·확실한 미전송과 소켓 단절 구분·세션별 격리·늦은 응답 폐기.
- 위젯 테스트: 필수 입력→대기→확인 성공, 코드 오류 재조회/빈 목록,
  입력 오류, 불명확 결과 잠금, 권한 거절 후 돌아가기, 320/390/900 폭.
- 라우터 테스트: 문맥 없는 진입, 성공 ID 반환, 단독 성공 후 복귀,
  로그인 수명 변경 중인 폼과 늦은 응답.
- core 테스트: 재전송 제외 POST의 토큰 갱신과 다음 수동 요청,
  재발급 최종 거절, 갱신 중 계정 전환, 본문 로그 제외 성공/오류.
- 첫 수명 테스트가 늦은 응답을 `<72>`로 수락해 실패했다.
  Notifier 재빌드 때 현재 ref만 확인하는 대신 제출별 dispose 표식을 캡처해 고쳤고 통과했다.
- 초기 import 검사에서 Service→models 오류 변환 의존성을 검출했다.
  전송 DTO와 Repository의 의미 변환으로 옮겨 수정했다.
- 캡처 도구의 FakeAsync 안 이미지 변환 대기, ListView의 지연 생성 항목과
  TextField 내부 Scrollable까지 잡는 finder 문제를 수정했다.
  테스트를 삭제하거나 검증 기준을 약화하지 않았다.
- `fvm flutter analyze`는 한글 절대 경로를 처리하는 analysis server의
  `FormatException: Unterminated string`으로 종료 코드 255였다.
  작업 위치 제한을 지키기 위해 외부 경로에 복사하지 않았다.
  같은 worktree의 `fvm dart analyze --fatal-infos`로 대체 검증한다.
- 상세 최종 명령 결과는 아래 최종 검증 절에 기록한다.

## 실제 렌더링 증거와 직접 확인

다음 명령은 네트워크 adapter를 테스트 서버로 교체하고 실제 Flutter 위젯을 그린다.
실제 API로 생성 요청을 보내지 않는다.

```bash
cd apps/mobile
JECT149_CAPTURE=1 fvm flutter test \
  test/features/performances/presentation/views/concert_creation_view_test.dart \
  --reporter expanded
```

`apps/mobile/build/ject149-evidence/`에 Pretendard와 MaterialIcons가 적용된
PNG 13개를 생성했다. initial top/bottom(320/900), initial top(390),
장르 오류/빈 목록, 필수 오류, 제출 대기, 결과 불명확, 권한 거절,
선택 입력과 확인된 성공 화면이다.
스크린샷과 overflow 없는 조작 테스트는 WidgetTester 렌더링 근거이며
시뮬레이터나 실제 기기 캡처라고 부르지 않는다.
프로젝트에 dark 테마가 없어 dark 검증은 해당하지 않는다.
하위 에이전트 중첩 제한으로 별도 시각 QA 리뷰어 두 명은 실행하지 못했다.
따라서 독립 시각 QA 통과를 주장하지 않는다.

직접 검증:

1. 위 명령으로 오류 없이 완료되고 PNG가 생성되는지 확인한다.
2. `fvm flutter test test/app/concert_creation_route_test.dart`로
   진입·ID 반환·단독 성공·계정 전환을 확인한다.
3. 실제 밴드 선택 기능이 붙으면 대표자 밴드로 화면을 열고
   미정→날짜/시간 선택→미정 해제, 입력 유지와 뒤로가기를 기기에서 확인한다.
   실서버 생성은 운영 데이터 변경 승인을 받은 환경에서 별도로 한다.
4. 생성 결과가 불명확하면 재전송하지 않고 HTTP 상태·응답 envelope·서버 생성 기록 순으로 확인한다.
   코드 목록 장애는 `/api/v1/codes?types=GENRE`와 인증 갱신부터 확인한다.
   계정 전환 문제는 `SessionRepository.changes`→연결 Provider→ViewModel dispose→라우터 순으로 본다.

## 최종 검증

환경: Flutter 3.47.9 / Dart 3.13.7, 기존 고정 의존성 사용. 의존성 추가·업그레이드 없음.

| 검사 | 실제 결과 |
| --- | --- |
| `fvm flutter pub get` | 종료 0 |
| `fvm dart format --set-exit-if-changed --output=none lib test tool` | 231파일, 변경 0, 종료 0 |
| `fvm flutter analyze` | 한글 경로에서 종료 255. 같은 소스를 영문 임시 디렉터리에 복사해 `fvm flutter pub get --offline` 후 `fvm flutter analyze --no-pub` 재실행: `No issues found!`, 종료 0 |
| `fvm dart analyze --fatal-infos` | No issues found, 종료 0 |
| `fvm dart run tool/check_imports.dart` | 146파일 import 방향 OK, 종료 0 |
| `fvm flutter test --reporter expanded` | 275개 통과, 종료 0 |
| `fvm dart run build_runner build --delete-conflicting-outputs` | 20초, 10 outputs, 종료 0 |
| 생성 파일에 대한 `git diff --exit-code` | 차이 없음, 종료 0 |
| `git diff --check` | 공백 오류 없음, 종료 0 |

build_runner는 저장소 문서의 `--delete-conflicting-outputs` 옵션이 현재 버전에서
제거되어 무시됐다는 경고를 출력했다. 생성 자체는 성공했고 생성 파일 차이는 없다.
전역 설정이나 프로젝트 도구 버전을 바꿔 경고를 숨기지 않았다.

전체 검사 로그는 `apps/mobile/build/ject149-evidence/final-checks.log`다.
수명 구독을 build의 watch/명령의 read로 정리한 최종 리비전 검사 로그는
`apps/mobile/build/ject149-evidence/final-revision.log`에 있다.
최종 리비전에서도 231파일 포맷 변경 0, 분석 오류 0, import 146파일 OK,
전체 테스트 275개 통과와 `FINAL_REVISION_PASS`를 확인했다.
PNG 13개를 직접 열어 확인했고, 마지막 선택 입력/성공 캡처에서도
대관비 0·날짜·시작/종료 시간과 확인된 성공 안내가 실제 그려지는 것을 확인했다.
스크린샷은 저장소 소스가 아닌 build 산출물로만 남겼다.
