# JECT-150 합동공연 페이지·정보·피드·일정 탭 연결

작성일: 2026-11-28. 작업 위치: `.worktrees/JECT-150`, 브랜치 `feat/JECT-150-concert-page`
(JECT-148 커밋 `58b9361` 위에서 시작. `58b9361`은 `origin/develop` `2f420c5`의 자손).

## 현재 상태

- 현재 단계: 구현·로컬 전체 검증·codex 3차 정적 승인까지 완료했다. 푸시·PR 생성·Jira 쓰기는 허용 범위가 아니므로 하지 않는다.
- 허용 범위: `/shows/:showId` 라우트, 공연 페이지 셸(정보·피드·일정 탭), 참여자 확인과 화면 상태,
  정보 탭의 최소 내용(날짜·시간·장소, 참여 밴드 이름), 참여 밴드 조회 계약과 가짜 구현, 공용 상태 위젯, 테스트·골든, 이 기록.
- 손대지 않은 것: 피드·일정 내용(리자), 공연 정보 수정 화면(JECT-153), 정보 탭 상세(JECT-152),
  주최 대표자 관리 버튼(JECT-151), 라인업(JECT-165).
- 다음 행동: 검증 후 한글 커밋과 PR 본문을 준비해 부모 레인에 SHA와 확장 계약을 전달한다. PR 게시는 부모 레인이 맡는다.

## 요구사항

- Jira JECT-150(기능 23): 참여자의 공연 페이지(정보·피드·일정 탭) 접근 및 권한 적용. hi-fi 3차.
- 성공 기준: `/shows/:showId`가 실제 화면을 연다. 참여 팀 멤버만 내용을 본다(서버 403 `AUTH_005`, 응답 `myBandIds`가 빈 목록이어도 차단).
  없는 공연(404 `CONCERT_001`)과 참여자가 아닌 경우는 안내 후 이전 화면으로 간다. 그 밖의 오류는 다시 시도한다.
  탭은 경로가 아닌 화면 상태다. 뒤로 가기는 이전 화면, 스택에 이전 화면이 없으면 홈이다. 152·151이 붙을 자리가 있다.
  콜드 스타트의 인증 redirect가 원래 주소를 보존하는 것은 기존 인증 라우터의 별도 과제다.

## 근거와 선택

Figma Desktop MCP를 읽기 전용으로 썼다(`get_metadata`, `get_screenshot`). 기준 프레임은 `정보탭_팀 모집 전`(2217:122759·2217:122814),
`3팀 모집, 1팀 들어온 상태`(2217:123232), `공연정보수정`(2217:123929)이다. API는 Notion 명세의 공연 상세 GET(2650–2777행, 148 계약)과
라인업 GET(2211–2322행)이고, 같은 날짜 Swagger에는 둘 다 없다.

| 결정 | 이유 | 버린 대안 |
| --- | --- | --- |
| 공연 페이지를 하단 탭 밖 루트 경로로 등록 | Figma 공연 페이지에 하단 탭 바가 없다 | 홈 branch 안: 탭 바가 남는다 |
| 정보 수정은 `hasRoutePath`로 `showEdit`가 라우트 표에 있을 때만 연결 | 수정 화면(153)은 형제 브랜치다. 153의 `GoRoute`가 머지되면 추가 연결 없이 켜진다 | 항상 push: 없는 경로 오류 화면. 머지 뒤 손으로 한 줄 추가: 잊으면 버튼이 죽는다 |
| 상태를 `AsyncValue.when` 대신 오류 우선으로 나눔 | 자동 재시도 중에도 실패와 다시 시도를 보인다. 갱신 실패 시 옛 값을 최신 값처럼 보이지 않는다 | `when`: 재시도 동안 로딩만 표시. 값 우선 분기: 갱신 실패가 숨겨짐 |
| 상세·참여 밴드 어느 쪽이든 명세의 403·404 쌍이면 차단 화면 | 삭제·빼기 뒤 다시 불러왔을 때 옛 내용을 계속 보이지 않는다 | 이전 값 유지, HTTP나 코드만 비교 |
| 참여 밴드는 라인업 응답에서 `bandId`·`name`·`isHost`만 읽는 좁은 계약 | 정보 탭이 실제로 이름을 그리고, 151·152가 같은 참여자 ID를 쓴다(부모 레인 결정). 라인업 전체는 165가 읽는다 | 라인업 DTO 전체 복제 |
| `ShowHeader.statusLabel`을 nullable로 | 앱이 모르는 새 상태에 임의 문구를 만들지 않고 태그를 숨긴다 | 기본 문구 |
| D-day는 `D - n`만, 날짜만 UTC로 계산하며 자정·앱 재개에 갱신 | 당일·지난 공연은 숨긴다. UTC 달력 날짜 차이로 일광 절약 시간 경계를 피하고, 주입한 `clock`으로 날짜 변경을 검증한다 | 새 문구, 빌드 때만 현재 날짜 읽기 |
| 골든은 macOS에서만 비교 | CI(ubuntu)는 글꼴 래스터화가 달라 픽셀이 어긋난다. 구조·상태는 일반 위젯 테스트가 모든 OS에서 본다 | 허용 오차 비교: 작은 회귀를 놓친다 |
| 티켓 관리 탭·메시지 아이콘 생략 | 탭은 티켓 기능 범위, 아이콘은 열 채팅방을 알려 주는 명세가 없다. 누르면 아무 일도 없는 버튼을 두지 않는다 | 비활성 자리 표시 |

- 추론: 참여 밴드 미리보기의 위치(공연 정보 아래)는 `3팀 모집, 1팀 들어온 상태` 프레임을 따랐다. 팀 수 안내·빈자리·`편집`은 152·151이 붙인다.
- 공식 원리(코드에서 확인): Riverpod 3.4.3 `ProviderElement.triggerRetry`가 재시도 타이머를 걸고 `AsyncLoading(error, retrying: true)`를 내보내며,
  `invalidateSelf`의 `runOnDispose`가 대기 중인 타이머를 취소한다. go_router 18.1.2의
  `RouteConfiguration.locationForRoute`가 부모·자식 경로를 결합하므로 자체 경로 결합 함수를 두지 않는다.

## 사용자의 이해

- 상태: 미확인. 설명만 제공했고 사용자 설명·실행 근거는 아직 없다.

## 구현 범위

- 라우트: `lib/app/router.dart`(`concertShowRoute`, `hasRoutePath`), DI: `lib/app/di.dart`
- 화면: `features/performances/presentation/views/concert_detail_view.dart`,
  `widgets/concert_page_header.dart`·`concert_info_tab.dart`·`concert_section.dart`·`concert_participants_preview.dart`
- 참여 밴드: `models/concert_participant.dart`, `data/dto/concert_participants_dto.dart`,
  `data/repositories/concert_participants_repository.dart`·`fake_concert_participants_repository.dart`,
  `presentation/providers/concert_participants_providers.dart`
- 공용: `shared/widgets/loading_view.dart`·`error_view.dart`·`empty_view.dart`, `shared/utils/date_format.dart`,
  `shared/widgets/show/show_header.dart`(상태 태그 선택)
- 문서: `docs/api/concert-participants.md`, `docs/mobile-architecture.md`(1·6·11절), `docs/pr-checklist.md`(E절), `AGENTS.md`

## 검증

에이전트가 실행한 것(무거운 명령은 `/tmp/highfive-concert-heavy.lock`으로 한 번에 하나씩):

- `fvm dart format --set-exit-if-changed --output=none lib test tool` exit 0
- `fvm dart run tool/check_imports.dart` → import 방향 OK (163 files)
- 리뷰 반영 후 `fvm flutter test` 347개 통과(골든 2장 포함, macOS).
- `fvm flutter analyze`는 한글 경로를 피해 영문 경로 복사본에서 실행 → No issues found
- `fvm dart run build_runner build` 후 생성 파일 변경 없음
- `fvm flutter build apk --debug --flavor dev` → dev debug APK 빌드 성공(영문 경로 복사본, 설치·실행은 하지 않음)
- 골든 PNG를 직접 열어 Figma 구조와 비교했다(글꼴 Pretendard, 뒤로 아이콘, 태그·제목·장르·정보 수정, 탭, 공연 정보, 참여 밴드 주최 배지).

미실행: 시뮬레이터·실기기 확인(UI 확인은 사용자가 직접 한다는 합의), 실서버 응답, 사용자 직접 확인.
QA 상태: 전체 자동 검증 통과, codex 정적 검토 APPROVE. 운영 준비: 미배포(가짜 저장소가 모든 flavor에 등록됨).

### codex 읽기 전용 리뷰 1차

| 지적 | 조치 |
| --- | --- |
| 1 참여 밴드 권한 철회 후 이전 이름 노출 | 페이지가 참여 밴드 조회의 접근 오류도 보고 전체 내용을 차단 |
| 3 시스템 뒤로가기와 원래 출발 화면 검증 | `PopScope`로 루트 복귀 처리, 홈이 아닌 마이 화면에서 상단·시스템 뒤로가기를 검증 |
| 4 HTTP 또는 코드만으로 접근 차단 판정 | `(403, AUTH_005)`·`(404, CONCERT_001)`만 분류 |
| 5 성공 뒤 갱신 실패 숨김 | 상세·참여 밴드 모두 오류 우선, 수동 재시도 제공 |
| 6 16진수 공연 주소 허용 | 양의 10진수만 파싱, 잘못된 주소는 조회 없이 안내 |
| 7 잘못된 초 허용, 시간 표시 테스트 부족 | 초 00–59 검증, 정보 행의 값과 미정 상태 검증 |
| 8 오류 버튼 42dp | 기존 large 버튼(52dp) 사용 |
| 10 하위 경로 결합 불일치·순환 기대값 | `locationForRoute` 사용, 기대값은 실제 `findMatch` 결과와 비교 |
| 11 수동 재시도 중 중복 탭 | 새 응답까지 버튼 로딩 유지, 보류 응답으로 호출 수 검증 |
| 12 자동 재시도 없음 테스트가 최종 상태만 확인 | 첫 오류 이벤트와 그 시점 호출 수 1을 검증 |
| 14 자정·앱 복귀 때 D-day 미갱신 | 머리 위젯에 자정 타이머·복귀 listener, 주입 시계 검증 |
| 2 인증 복원 중 딥링크 소실 | 보류: 인증 영역 변경 금지, 딥링크 형식도 아직 미정. 공연 화면 자체의 스택 복귀와 구분 |
| 9 넓은 창 본문 최대 폭 | 보류: 12절에서 최대 폭을 디자이너와 정하도록 했으므로 임의 토큰을 만들지 않음 |
| 13 Ubuntu CI가 골든을 건너뜀 | 보류: macOS 기준 골든의 로컬 회귀 검증이며 CI 변경은 범위 밖. 일반 위젯 테스트는 CI에서 실행 |

### codex 읽기 전용 리뷰 2차

- 남은 지적: 참여 밴드 재시도 중 정보 → 피드 → 정보로 이동하면 미리보기가 다시 만들어져 요청 중 표시를 잃는다.
- 수정: `SliverVisibility(maintainState: true)`로 정보 탭을 유지한다. 보이지 않을 때는 레이아웃·접근성에서 숨기되 진행 중인 조회와 버튼 상태를 함께 유지한다.
  상태를 상위 화면으로 옮기기 위한 새 필수 인자를 만들지 않아 152·151이 붙일 위젯 API도 유지한다.
- 재현: 응답을 보류한 채 탭을 왕복하는 회귀 테스트는 수정 전 `loading`의 기대 true·실제 false로 실패했다.
  같은 테스트가 탭 왕복 후 재탭에도 총 호출 2회(최초 조회와 수동 재시도)인지를 확인한다.

### codex 읽기 전용 리뷰 3차

- 위 탭 상태 보존과 회귀 테스트를 다시 검토해 APPROVE를 받았다. 리뷰어는 테스트·빌드를 실행하지 않았으며 실행 근거는 위 에이전트 QA와 구분한다.

## 장애와 배포

- 예상 증상: 공연 페이지가 계속 진행 표시만 보임(저장소 응답 없음), 참여자인데 차단 화면(서버가 `myBandIds`를 빈 목록으로 줌),
  정보 수정 버튼 비활성(수정 화면 `GoRoute` 미등록).
- 확인 순서: `concertDetailProvider(id)` 상태 → `ConcertRepository` 응답(403·404 코드) → `myBandIds` →
  `hasRoutePath(router.configuration, AppRoutes.showEdit)` → 참여 밴드는 `concertParticipantsProvider(id)`.
- 되돌리기: `router.dart`의 `concertShowRoute()` 한 줄을 빼면 경로가 사라진다. 공용 위젯은 다른 화면이 아직 쓰지 않는다.

## 다음 단계

- JECT-152: `ConcertInfoTab`·`ConcertParticipantsPreview`를 시안대로 채운다(모집 카드, 주소·대관비, 팀 수 안내·빈자리, 프로필 사진).
- JECT-151: `myPermissions.isHostLeader`로 참여 밴드 `편집`(빼기)·공연 삭제를 붙이고, 쓰기 성공 후 두 Provider를 invalidate한다.
- JECT-153: `GoRoute(path: AppRoutes.showEdit)`만 등록하면 정보 수정이 연결된다. 저장 성공 후 `concertDetailProvider`를 invalidate한다.
- 실서버가 열리면 공연 상세·라인업 Service와 실제 Repository를 추가하고 DI 두 줄을 바꾼다.
