# JECT-153 공연 기본 정보 수정

## 범위와 선택

- 사용자 승인 범위: 기존 JECT-153 작업 트리에서 구현, 로컬 검증, 지정 iPhone 시뮬레이터 설치. 커밋·게시·실제 서버 쓰기는 하지 않는다.
- 기준: origin/develop `2f420c5`. JECT-149는 읽기 전용으로 확인했다. 생성용 `ConcertDraft`는 region·poster를 null로 보내므로 수정에 재사용하면 기존 정보가 지워진다. 생성 기능 파일은 가져오지 않는다.
- 2026-11-26 Notion `a8ef857a78dc83adbdde813a8cb344ec` 조회: PUT 전체 교체, version 필수, 참여 팀 멤버 권한, 변경한 날짜만 검증, 충돌 시 최신 상세로 재충전.
- 상세 화면·조회 어댑터가 이 기준 브랜치에 없다. 조회 API를 추정하지 않고 호출자가 최신 전체 값·권한·장르 목록·재조회 함수를 넘기는 명시적 타입 경계를 둔다.
- 전체 원본과 입력을 분리한다. 화면에서 다루지 않는 region·posterImageUrl과 수정하지 않은 선택값은 원본을 유지한다. 새 포스터 업로드·지역 코드 선택은 미합의이므로 제공하지 않는다.
- 결과가 불명확한 저장은 재전송하지 않는다. 최신 상세를 읽은 후에만 다시 편집한다. 서버의 version 검사가 최종 동시성 방어다.

## 화면 설계

프로젝트 `docs/design-tokens.md`와 기존 공통 위젯을 따른다. 이 작업은 새 디자인 시스템을 만들지 않는다.

- 주요 행동: 저장.
- 정보 순서: 안전한 미리보기 여부와 권한 → 기존 제목·장르·모집 팀 수 → 날짜·시간·장소·주소·대관비.
- 필수 내용: 제목, 장르, 모집 팀 수, 날짜, 시작·종료 시간, 장소, 주소, 대관비, 기존 지역·포스터 유지 안내, 필드 오류, 저장·재조회 상태.
- 제외: 밴드 선택, 생성 기능, 업로드, 임의 장르 입력, 실제 데이터로 가장한 미리보기.
- Layout: 공연 기본 정보 수정 - 긴 입력 폼과 항상 보이는 저장 → scroll-body-shell; scroll owner: 본문 ListView; 상단 AppTopBar와 하단 SafeArea 저장 영역 고정, 중첩 세로 스크롤과 가로 넘침을 피한다.
- 앱은 현재 light 테마만 제공한다. 다크 테마·새 토큰은 이 작업 범위 밖이며, 웹용 Lighthouse/DOM 검사는 네이티브 Flutter 표면에 적용하지 않는다.

## 학습과 확인

공식 Riverpod family·Ref.mounted 문서와 Context7 예시를 읽었다. family는 편집 진입 객체별 상태를 분리하며 비동기 완료 후 mounted 확인은 닫힌 화면의 갱신을 막는다. 세션 동일성은 별도로 확인해야 한다.

- 공식 원리: https://riverpod.dev/docs/concepts2/family, https://riverpod.dev/docs/whats_new
- 사용자 이해 및 사용자 직접 검증: 미확인. 설명과 에이전트 QA를 사용자 확인으로 취급하지 않는다.
- 실행 결과와 최종 접근 방법은 구현 검증 후 아래에 기록한다.

## 전체 교체의 경계와 날짜

- `ConcertEditValues.fromJson`: nullable 키를 포함해 12개 필드가 모두 있어야 한다. 명시적 null은 미정으로 보존하지만 누락된 키를 null로 추측하지 않는다. `version`은 정수 타입만 받으며 기본값·소수점 절삭을 허용하지 않는다.
- 누락 키·소수 version 테스트를 먼저 실행해 9건 실패를 재현한 뒤 `JsonKey(required: true)`와 정수 변환을 추가했다. 생성 파일은 build_runner로만 만들었다.
- API 명세서의 공통 규칙(2026-11-26 조회, `662f857a78dc83e39b9f016e3ee11079`)은 서버 시간대를 Asia/Seoul로 정한다. `concertBusinessDate`는 UTC 순간에 9시간을 더해 서울 날짜를 계산한다. 해외 기기의 시간대에 기대지 않는다. 서울 자정 경계 회귀 테스트를 포함한다. 기기 시계 오차는 남으며 서버가 최종 판단한다.
- 재조회 실패는 저장 잠금을 유지한다. 재조회 함수는 같은 공연의 최신 전체 응답·참여 권한을 반환하고, 실패 시 DioException 또는 ConcertEditFailure를 전달해야 한다.

## 진입과 직접 확인

### 실제 상세 연동 경계

`ConcertEditContext(concertId, snapshot, reload)`를 `AppRoutes.showEditOf(concertId.toString())`의 `extra`에 넘긴다. snapshot은 전체 12개 값·version, 현재 참여 여부, 주최 팀 제외 합류 팀 수, 확인된 장르 목록을 모두 담는다.

```dart
final changed = await context.push<bool>(
  AppRoutes.showEditOf(detail.concertId.toString()),
  extra: ConcertEditContext(
    concertId: detail.concertId,
    snapshot: completeSnapshot,
    reload: reloadSameConcertWithCurrentPermission,
  ),
);
// changed == true이면 호출자가 상세/모집 공고의 조회 상태를 갱신한다.
```

위 코드는 상세 기능이 연결할 계약 예시이며, 아직 존재하지 않는 detail API를 구현한 것처럼 실행하지 않는다. ID만 있는 deep link에는 편집 폼을 만들지 않는다. 성공 시 true로 돌아가며, 티켓 신청 페이지는 변경하지 않는다.

### 로그인과 분리된 HOME 미리보기

사용자가 온보딩 우회 화면 확인을 명시적으로 요청했다. `lib/main_preview.dart`는 dev/debug에서만 허용되는 별도 시작점이다. `lib/main.dart`의 SDK 초기화·setupDi·secure storage·실제 세션·로그인 router는 호출하지 않는다. 토큰을 위조하거나 약관에 동의하지 않는다.

기존 `HomeView`·`RecruitmentListView`·`ChatListView`·`MyPageView`와 실제 공통 하단 탭을 그대로 쓴다. 현재 HomeView와 목록 화면은 제목만 있는 초기 화면이다. 이 미리보기는 기능 구현이 완료된 홈이나 실제 인증 성공을 의미하지 않는다. 미리보기의 로그아웃 버튼은 설명 창만 열고 실제 세션에 접근하지 않는다.

실행 위치는 이 작업 트리의 `apps/mobile`이다.

```sh
fvm flutter run --flavor dev --debug -t lib/main_preview.dart -d A553A6CA-71D7-47F6-81D4-DB6FD8B7CEF3
```

HOME 위의 `공연 정보 수정 미리보기`를 누르면 ID 없는 메모리 Repository로 편집을 연다. 저장은 이 미리보기 프로세스 안에서만 반영된다. 앱을 다시 시작하면 예시 값으로 돌아간다. 입력 오류, 저장, 최신 정보 재조회, 닫기를 직접 확인할 수 있다. 미리보기 종료 후 HOME과 네 탭으로 돌아온다.

정상 앱의 dev 빌드에서는 DEV 띠 길게 누르기 → 공연 정보 수정 미리보기로도 접근한다. prod에는 이 dev 경로가 없다. 정상 인증·온보딩 실행은 아래 명령을 사용한다. 미리보기 앱과 같은 dev 앱 ID를 덮어 설치하지만 uninstall/reset 없이 저장된 세션은 유지한다.

```sh
fvm flutter run --flavor dev --debug -t lib/main.dart -d A553A6CA-71D7-47F6-81D4-DB6FD8B7CEF3
```

## 예상 장애와 확인 순서

1. 수정 진입 불가: 실제 세션/nextStep → ConcertEditContext 전체 전달 → 공연 ID 일치 → 참여 권한을 확인한다.
2. 필드 오류: 입력칸 사유를 먼저 확인한다. 날짜는 서울 기준이고, 모집 인원·공고 마감일은 서버가 최종 검사한다.
3. 버전 충돌: 최신 상세 재조회와 재충전 여부를 확인한다. 실패하면 이전 값으로 다시 제출하지 않는다.
4. 저장 응답 유실: 성공으로 단정하지 않고 상세를 먼저 조회한다. 자동 재전송하지 않는다.
5. 지역·포스터: 원본의 누락 키가 없는지 확인한다. 이 화면은 업로드나 지역 코드 정책을 추정하지 않는다.

실서버 쓰기, 상세 조회 API 통합, 실제 참여 권한 변경, 푸시, 실기기·운영 배포는 검증하지 않았다. 사용자 직접 검증과 이해 확인은 별도다.

## 실행 근거

- 생성: `fvm dart run build_runner build --delete-conflicting-outputs` 성공. 현재 build_runner는 해당 삭제 옵션을 제거하여 경고 후 무시하지만 생성은 성공했다.
- 첫 분석은 한글 경로의 analysis server LSP JSON 처리에서 `Unterminated string`으로 종료됐다. 프로젝트 규칙대로 `/tmp/highfive-JECT-153-analyze.avs3Ee`에 동일 소스를 복사하여 `fvm flutter analyze`를 실행한다. 수정은 원래 작업 트리에서만 한다.
- 회귀 테스트에서 320 폭의 긴 모집 팀 수 라벨이 8px 넘치는 것을 재현했다. 필드 제목과 주최 팀 제외 힌트를 나누어 고쳤고, 320·1024 폭 테스트가 통과했다.
- 독립 코드 검토에서 지연된 저장 콜백이 다른 화면을 닫을 가능성과 닫기 연속 탭의 중복 이동을 지적했다. 현재 route 여부·닫기 진행 상태를 확인하고 회귀 테스트를 추가했다.
- 최종 전체 테스트: `00:16 +334: All tests passed!`, 종료 코드 0. 포맷은 237개 파일 변경 없음, import 방향은 151개 파일 통과. 영문 임시 복사본의 최종 analyze는 `No issues found!`, 종료 코드 0이다.
- JECT-149와 겹치는 공통 변경은 `ApiLogInterceptor.logBodyKey`이다. 읽기 전용으로 확인한 동일 키·구현을 사용하며, 공연 생성 Service·Repository·모델은 가져오지 않았다. 공연 수정의 전송 로그에는 주소·포스터 본문을 남기지 않는 테스트가 있다.

## 최종 iPhone 실행 검증

- 실제 `.worktrees/JECT-153/apps/mobile`에서 `fvm flutter build ios --simulator --debug --flavor dev -t lib/main_preview.dart` 성공. `Xcode build done. 23.7s`, `Built build/ios/iphonesimulator/Runner.app`, 종료 코드 0.
- 지정 기기 `A553A6CA-71D7-47F6-81D4-DB6FD8B7CEF3`에 `simctl install` 성공 후 `simctl launch --terminate-running-process ... com.ject.highfive.dev` 성공. uninstall/reset은 실행하지 않았다. 실제 약관 동의·로그아웃·토큰 쓰기·공연 서버 요청은 실행하지 않았다.
- 네이티브 접근성 트리로 HOME → 팀 모집 → 메시지 → 마이페이지 → 오프라인 공연 수정을 확인했다. 편집 화면에서 인디 선택 해제 → 메모리 저장 성공 → 최신 정보 다시 불러오기 → 스크롤 끝의 장소·주소·대관비·유지 안내를 확인했다. 최종 기기는 HOME으로 돌아간다.
- 실제 화면에서 이중 DEBUG 배너와 중복 상단 안전영역을 발견해 별도 미리보기 루트에서만 수정했다. 기존 HomeView 등 실제 기능 화면은 고치지 않았다.
- 빌드 도구가 CocoaPods/SPM 관련 파일을 자동 변경했다. 이번 기능의 의존성 변경으로 남기지 않도록 원래 Podfile.lock·project.pbxproj로 복원하고 새 Package.resolved 두 개를 제거했다. 복원 후 해당 tracked 파일의 diff가 없음을 확인했다.
- 텍스트 입력은 위젯 테스트에서 제목 변경·저장까지 검증했다. Duo의 데스크톱 AX 텍스트 입력은 도구가 닫힌 내부 창을 참조해 동작하지 않았다. 네이티브 키보드의 모든 입력·피커 조합은 사용자 직접 확인 대상으로 남긴다. 장르 선택·저장·재조회·스크롤·네 탭은 실제 Duo에서 확인했다.
- 네이티브 캡처를 직접 확인했으며 레이아웃 넘침은 없었다. WCAG AA 정식 계측·독립 시각 심사·다크 테마 검증은 하지 않았다. 하위 작업 중첩 제한으로 추가 리뷰 에이전트를 실행하지 못했으며, 별도 모델의 코드 검토 지적 세 건은 수정·회귀 검증했다.

캡처는 git에 추가하지 않는 로컬 빌드 증거다:

- `apps/mobile/build/ject153-qa/home.png`
- `apps/mobile/build/ject153-qa/recruit.png`
- `apps/mobile/build/ject153-qa/chat.png`
- `apps/mobile/build/ject153-qa/my.png`
- `apps/mobile/build/ject153-qa/edit-top.png`
- `apps/mobile/build/ject153-qa/edit-saved.png`
- `apps/mobile/build/ject153-qa/edit-bottom.png`

커밋·푸시·PR·Jira/Notion 쓰기는 하지 않았다.

## 후속: 날짜 입력과 달력만 수정

> 아래는 이전 작업 이력이다. 현재 날짜·시간 요구사항과 결과는 마지막 절을 기준으로 한다.

사용자가 승인한 후속 범위는 날짜 입력과 달력이다. 시간 피커·인증·Duo 설치는 변경하지 않는다.

- Figma Desktop에서 일반 전화기 수정 화면 `2217:123929`와 달력 시트 `1702:15160`의 실제 스크린샷을 비교했다. 어두운 채움 입력, `YYYY.MM.DD (한글 요일)`과 달력 아이콘, 밝은 둥근 시트·손잡이·월 제목·이전/다음·월요일 시작·회색 선택일·전체 너비 확인 버튼을 따른다.
- `ConcertDateInput`과 `showConcertDateSheet`를 기존 공연 편집에 연결한다. 날짜는 달력 안의 임시 값으로 선택하며 확인해야만 폼에 반영된다. 닫기·바깥 영역·뒤로 가기는 원래 값을 유지한다.
- `null` 반환(취소)과 `(date: null)` 반환(미정 확인)을 구분한다. 기존 `날짜 미정` 버튼도 즉시 지우지 않고 미정 상태의 시트를 열어 확인받는다.
- 기존 지난 공연 날짜는 선택 상태로 보존하고 그대로 확인할 수 있다. 다른 지난 날짜는 선택하지 못한다. 날짜 비교는 앞서 확인한 Asia/Seoul 업무 날짜 기준을 유지하며, 요청은 계속 `YYYY-MM-DD`이다.
- `CalendarWeekRow`·`CalendarDayCell`·`AppButton`·기존 간격·모서리·색 토큰을 재사용한다. 이 시트 안에서만 공통 날짜 칸의 선택색을 회색 계열로 연결하며, 공통 컴포넌트의 기존 색은 바꾸지 않는다. 테마 색을 덮을 때 기존 타이포그래피 확장도 보존한다.
- 어두운 입력은 기존 `inverseBackground`·`inverseLabel`, 선택일은 `fillStrong`·`labelAlternative`로 연결했다. Figma의 개별 화면 원시 색을 새 전역 토큰으로 추가하지 않아 일부 원시 색·폰트 수치의 픽셀 동일성은 보장하지 않는다.
- 달력의 연월·요일·월 길이·윤년·빈 칸·행 수는 실제 날짜로 계산한다. 예시 일정 점이나 예시 날짜를 하드코딩하지 않는다. 처음 미정이면 서울 기준 현재 월을 표시하고 임의의 날을 자동 선택하지 않는다.
- Layout: 날짜 시트 - 짧은 화면의 달력 탐색 → scroll-body-shell; scroll owner: `concertDate_scroll`; 손잡이·확인 영역은 고정하고 월 제목·요일·주간 그리드만 필요할 때 세로로 스크롤한다.
- 회귀 검증 대상: 미정·지난 날짜 초기 상태, 요일 표시·월요일 정렬, 윤년·연말·월 이동, 선택 중 취소와 확인, 미정 확인, 375×812 및 320×480에서 확인 버튼·마지막 날짜 접근.

일반 iPhone 렌더와 최종 검사 결과는 이 절에 이어 기록한다. 이전 Duo HOME 증거는 이전 작업의 결과이며 이번 후속의 배포 대상으로 사용하지 않는다.

### 후속 검증 결과

- 포맷: `fvm dart format --set-exit-if-changed --output=none lib test tool` → 239개 파일 변경 없음.
- 계층: `fvm dart run tool/check_imports.dart` → 152개 파일 통과.
- 전체 테스트: `fvm flutter test --reporter expanded` → `00:30 +346: All tests passed!`, 종료 코드 0. 날짜 관련을 포함한 presentation 테스트 35개도 별도 통과했다.
- 분석: 한글 경로 충돌을 피한 동일 소스 복사본 `/tmp/ject153-date-analyze.0Ajk5u`에서 `fvm flutter analyze` → `No issues found!`, 종료 코드 0.
- 빌드: 실제 작업 트리에서 `fvm flutter build ios --simulator --debug --flavor dev -t lib/main_preview.dart` → `Xcode build done. 34.4s`, 종료 코드 0. 자동 변경된 iOS 설정·잠금 파일은 이번에도 원복했고 원본과 diff가 없음을 확인했다.
- 일반 기기: iPhone 18 Pro, iOS 27.0, `0E7CC0BE-3FE0-4124-9D2D-825E14BBB18D`. 이 기기에만 설치·실행했다. Duo에 설치하거나 실행하지 않았다.
- 실제 렌더: 미정 초기 상태 → 2026년 11월 월요일 시작 6주 그리드 → 날짜 선택 → 회색 선택 원과 `11.27 (금) 선택` 확인 버튼을 직접 확인했다. 실제 월의 주 수이므로 Figma의 5주 예시보다 한 줄 길다. 전체 너비 버튼·손잡이·이전/다음·모서리·텍스트에 넘침이 없으며 달력을 열린 채 남겼다.
- 일반 iPhone에서 마지막 확인 버튼을 누르려는 시점에 OS의 `secure-input-active`로 도구 입력이 거절됐다. 우회 입력은 하지 않았다. 따라서 네이티브 확인 후 폼 반영은 직접 검증 완료로 기록하지 않는다. 선택·취소·확인·미정에 따른 폼 반영과 API 문자열 보존은 위젯 통합 테스트로 검증했다.
- 로컬 캡처: `apps/mobile/build/ject153-date-qa/calendar-unset.png`, `apps/mobile/build/ject153-date-qa/calendar-selected.png`. 선택된 날짜는 아직 폼에 확인 반영하지 않은 상태다. 화면의 확인을 누르면 반영되고 시트를 닫으면 원래 값이 유지된다.

재실행 명령(이 작업 트리의 `apps/mobile`):

```sh
fvm flutter run --flavor dev --debug -t lib/main_preview.dart -d 0E7CC0BE-3FE0-4124-9D2D-825E14BBB18D
```

HOME의 공연 정보 수정 미리보기 → 어두운 날짜 입력을 누른다. 날짜를 고른 뒤 닫기와 확인을 각각 실행해 차이를 직접 확인할 수 있다. 기존 `날짜 미정` 버튼 역시 시트 확인 후에만 반영된다. 시간 피커, 인증 경로, 실제 서버 데이터는 이번 후속에서 변경하지 않았다. 커밋·푸시하지 않았다.

## 최신 수정: 실제 날짜·시간 컨트롤

- 사용자 지시로 앞선 날짜 미정 추가 액션과 시간 시작/종료 버튼을 교체한다. 날짜는 필수 표시 제목·채움 필드·24px 달력 아이콘만 둔다. API의 기존 null은 날짜를 건드리지 않았으면 그대로 둔다. 새 날짜 지우기 동작을 추가하지 않는다.
- Figma Desktop `2217:123929`의 실제 렌더와 메타데이터를 확인했다. 시간 헤더 오른쪽에 18px 체크박스·6px 간격·`아직 미정이에요`, 아래에는 HH:mm 채움 입력 두 개와 `~`를 둔다. 별도의 펼친 시간 피커는 시안이 없어 만들지 않는다.
- 해당 렌더의 `Background/Normal #141416`, `Background/Surface #222125`, `Label/Normal #eaeaeb`, `Label/Assistive #747477`을 기능 전용 토큰으로 사용한다. 공통 `AppColors`나 다른 운영 화면은 변경하지 않는다.
- Layout: 날짜·시간 - 헤더와 입력의 수직 stack, 시간은 같은 너비의 두 입력을 inline row로 배치한다. scroll owner: 기존 `concertEdit_scroll`; 저장 버튼은 기존 고정 영역을 유지한다. 영역만 다크 처리하며 전체 화면 다크 전환은 이번 범위가 아니다.
- 시간 미정 체크는 두 API 값을 함께 null로 설정하되 표시 중인 이전 입력과 초·소수 초를 별도로 보존한다. 해제하면 되돌린다. 처음 두 값이 null이면 체크되어 시작한다. 해제 후 한쪽만 입력하거나 둘 다 비었으면 검증 오류로 저장을 막는다.
- 기존 공통 `AppTextField`를 국소 테마로 재사용한다. 기존 `AppCheckbox`는 14px 고정이므로 공유 UI를 바꾸지 않고 네이티브 Checkbox의 18px 컨트롤을 쓴다. 저장·재조회·읽기 전용 상태에서는 날짜·시간·체크 입력을 비활성화한다.
- 공식 Flutter `Checkbox.onChanged` 문서에서 값은 부모가 관리하고 null 콜백은 비활성화임을 확인했다. 테스트에서는 실제 폼 조작과 저장 경계의 값을 검증한다.
- 검증 기기는 전용 일반 iPhone `JECT-153-date-time`이다. 기존 기기와 로그인 세션, Duo는 조작하지 않는다.

### 최신 검증 결과와 직접 확인

- 전체 테스트: `fvm flutter test --reporter expanded` → `00:18 +352: All tests passed!`, 종료 코드 0.
- 포맷: `fvm dart format --set-exit-if-changed --output=none lib test tool` → 240개 파일 변경 없음. import 검사 → 153개 파일 통과.
- 분석: 동일 소스의 `/tmp/ject153-date-time-analyze.Tl8Utz`에서 `fvm flutter analyze` → `No issues found!`, 종료 코드 0. 테스트의 폐기된 `hasFlag` 사용은 고정 SDK의 `flagsCollection.isChecked`로 교체했다.
- 최종 iOS 빌드: `fvm flutter build ios --simulator --debug --flavor dev -t lib/main_preview.dart` → 37.3초, 종료 코드 0. 빌드의 자동 iOS 설정 변경은 복원했고 설정 diff가 없음을 확인했다.
- 회귀 테스트는 기존 날짜 미정 액션 기대를 API null 보존으로 교체했다. 초기 시간 null/값 있음, 미정 체크의 접근성 상태, 원본 초·소수 초 복구, 수정한 시간 복구, 미정일 때 두 값 동시 null, 한쪽만 입력한 범위의 저장 차단, 저장 중·읽기 전용 비활성화를 검사한다.
- 테스트에서 늦게 초기화되는 시간 백업이 체크 후 null을 읽는 결함을 발견했다. `_EditFormState.initState`에서 원본을 먼저 보관하도록 수정했다. `_time`은 실제 수정값을 보관하며 `_undecided`는 API 값과 보관된 입력을 분리한다. 확인 위치: `concert_edit_view.dart:119`, `:157`, `:173`.
- 전용 기기: iPhone 18 Pro / iOS 27.0 / `77106B03-419B-40D4-AA55-8A75864A8FFA`. 최종 캡처 1206×2622에서 Figma의 날짜·시간 구조와 비교했다. 20px 좌우 여백, 다크 바탕·필드, 날짜 표기·달력 아이콘, 오른쪽 체크박스와 레이블, 같은 너비 시간 필드·물결을 확인했다.
- 실제 기기에서 달력의 2026년 11월 27일 선택 → 확인 → `2026.11.27 (금)` 반영을 확인했다. 미정 체크 시 두 시간 입력이 비활성화되고 `19:00`·`21:00`은 보관된다. 체크 해제 시 동일한 두 값과 입력 가능 상태가 복구된다. 접근성 트리에서도 Checkbox `0 → 1 → 0`과 입력 역할 변화를 확인했다.
- 실제 화면의 날짜·시간 영역에는 넘침이 없었다. 320·1024 폭의 기존 폼 회귀도 전체 테스트에 포함된다. 기본 캡처: `apps/mobile/build/ject153-date-time-qa/date-time.png`. 미정 캡처: `apps/mobile/build/ject153-date-time-qa/date-time-undecided.png`. 첫 렌더의 불필요한 좌우 다크 여백은 수정했고 `first-render.png`는 수정 전 비교용이다.

한계: 전체 편집 화면은 기존 라이트 UI를 유지해 Figma 전체 화면과 동일하다고 주장하지 않는다. 요청받은 날짜·시간 영역만 확인한 다크 스타일을 적용했다. 시간은 시안에 없는 확장 피커 대신 일반 HH:mm 입력과 기본 키보드를 사용한다. 네이티브 키보드 입력의 모든 조합·VoiceOver 음성·실서버 저장은 검증하지 않았고 시간 문자열·검증·저장 경계는 위젯 테스트로 확인했다. 미정 상태에서 이전 시간을 흐리게 보존하는 표현은 시안에 없는 상태 처리이므로 실제 검토 대상으로 남긴다.

직접 확인: 전용 시뮬레이터에서 공연 수정 미리보기 → 날짜 필드 → 날짜 선택·확인, 이어서 시간 미정 체크를 켰다 끈다. 시간을 하나만 입력하고 저장하면 오류가 나며, 둘 다 올바른 HH:mm이면 저장 가능해야 한다. 문제가 나면 `ConcertDateTimeSection`의 입력 활성화 → `_undecided`의 두 값 전환 → 기존 `ConcertEditForm.validate` 순서로 확인한다.

이 작업은 기존 JECT-153 작업 트리에서 날짜·시간 관련 파일과 이 기록만 변경했다. 기존 브랜치 작업·공통 테마·인증·실제 서버 세션·Duo는 변경하지 않았다. 커밋·푸시하지 않았다.
