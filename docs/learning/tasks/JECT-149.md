# JECT-149 합동공연 생성 화면

작성일: 2026-11-28. 작업 위치: `.worktrees/JECT-149`, 브랜치 `feat/JECT-149-concert-creation`
(origin/develop `2f420c5`에서 새로 시작). 이전 WIP 브랜치 `feat/JECT-149-create-concert`(fbf7f83),
`feat/JECT-149-concert-flow`(c981e6f)는 지우지 않고 읽기 전용 입력으로만 썼다.

## 현재 상태

- 현재 단계: 구현·로컬 검증·위젯 캡처·3차 읽기 전용 리뷰 승인까지. 커밋은 로컬에만 한다. 푸시·PR은 리드가 연다.
- 허용 범위: 공연 생성(모델·DTO·Service·Repository·ViewModel·화면), 홈 진입 버튼, 라우트·DI 한 줄씩, 문서.
  밴드 프로필(리자 영역)·core 네트워크는 바꾸지 않았다. 날짜 44×44 터치 영역을 위해 공통 바텀시트·달력 줄의 여백 인자를 기본값 유지로 확장했다.
- 사용자의 이해: 미확인. 설명만 남겼고 사용자 확인은 없다.
- 기본 앱 실서버 POST 비활성, 인증된 dev 환경 미검증. 라이브 생성 연동은 완료 범위에 포함하지 않는다.
- 자동 검증: 전체 306개 테스트, Dart·Flutter 분석, import 검사, dev debug APK 빌드를 확인했다. 실기기·사용자 직접 확인은 별도다.

## 요구사항 (Jira JECT-149, 기능명세 10)

- 공연 생성, 모집 팀 수 입력, 초기 주최 대표자 지정, 필수값 검증.
- 진입점: 홈 빈 상태 "공연 열고 팀 모집하기". 내 공연(JECT-154) 추가 버튼도 같은 `/shows/new`를 쓴다. 밴드 프로필 화면은 아직 없어 연결하지 않았다.
- 계약: Swagger `POST /api/v1/concerts` (docs/api/concert-create.md). 만든 사람의 밴드가 주최 팀이 된다.

## 선택과 이유

| 결정 | 이유 | 근거 |
| --- | --- | --- |
| 주최 밴드는 바텀시트에서 고른다 | Figma `마이페이지-공연추가_밴드선택시트`(2216:138580)가 "내가 대표자인 밴드만" 고르게 한다. 생성 폼에는 밴드 칸이 없다 | Figma, Notion `bandId` 설명 |
| 임시 밴드는 로컬 생성에만 연결 | 밴드 조회 API가 없으므로 모든 flavor에서 임시 데이터를 로컬 구현에만 저장한다 | 작업 범위 |
| 기본 DI는 호출 어댑터 없이 구성 | 기본 앱 실서버 POST 비활성, 인증된 dev 환경 미검증. 어댑터는 명시적인 loopback 계약 테스트에서만 주입한다 | `setupDi`, `concert_creation_di_test.dart` |
| 로컬 미리보기는 세션이 끝나면 비운다 | 이전 입력을 다음 사용 시점까지 보관하지 않는다 | `routerProvider`, `clearLocalPreviews`, 라우터 로그아웃 테스트 |
| `/shows/new`에 extra가 없으면 밴드 선택 | JECT-154의 추가 버튼이 같은 주소만 push해도 동작하며 feature→app 교차 import가 필요 없다 | 부모·JECT-154 계약 |
| 시작·종료 시간, 장소·주소·지역, 포스터를 보내지 않는다 | 시간은 시안에 없다. 장소 검색·지역 코드·포스터 업로드 용도는 서버 계약이 없다(지어내지 않는다) | Figma, Swagger |
| 날짜를 필수로 한다 | 시안이 "필수 정보"에 두고 미정 선택지가 없다 | Figma |
| 날짜 선택은 공통 달력 컴포넌트로 만든 시트 | 앱에 한국어 Material 지역화가 없어 `showDatePicker`가 영어로 보인다. 의존성 추가 없이 `_Week`·`_Day`를 쓴다 | `app/app.dart` |
| core 매퍼는 그대로, Service에서 보낸 뒤 시간 초과만 구분 | `NetworkException`이 연결 실패와 응답 대기 시간 초과를 합친다. POST는 응답 대기 시간 초과면 서버가 만들었을 수 있다 | `api_error_mapper.dart` |
| 결과 불명이면 앱 실행 동안 같은 밴드의 원격 생성 잠금 | 조회·멱등성 계약이 없어 화면을 닫아도 중복 전송을 막는다. 앱 재시작 이후까지 보장하지는 않는다 | `ConcertCreationRepository._unconfirmedBands` |
| 만든 뒤에는 ID를 돌려주고 닫는다 | 공연 페이지 라우트는 JECT-150이 등록한다. 없는 경로로 보내지 않는다 | 리드 조정 |
| 항목 제목은 V3 `FormSection`(16 SB) | 화면 시안은 14 SB로 덮어썼지만 사용자 합의가 컴포넌트 V3 기준이다 | design-tokens.md |

## 문제가 생기면 확인 순서

1. 홈 버튼 → `AppRoutes.showNew` → `ConcertCreationEntry` → 밴드 선택 시트(`hostBandsProvider`)가 열리는가.
2. `/shows/new`는 extra가 없으면 `ConcertCreationEntry`가 밴드 선택부터 연다. extra를 줬는데도 선택이 뜨면 값이 `HostBand` 타입인지 확인한다.
3. 만들기를 눌러도 반응이 없으면 `ConcertCreationState.locked`(실서버 비활성·보내는 중·성공·결과 불명·권한 없음)와 검증 오류(`errors`).
4. 서버 오류는 `ConcertCreationRepository._reasonOf`가 어떤 이유로 바꿨는지, dev 로그의 `[ConcertCreation]` 줄.
5. 요청 본문은 `ConcertCreateRequestDto.toJson()`과 Swagger `ConcertCreateRequest`를 대조한다.

## 직접 확인하는 방법

- `fvm flutter test test/features/performances test/features/home test/app/router_test.dart`
- 캡처: `CAPTURE_DIR=<폴더> fvm flutter test test/features/performances test/features/home` → PNG가 생긴다.
- dev 앱: 홈 → 공연 열고 팀 모집하기 → 임시 밴드 고르기 → 제목·장르·날짜 입력 → 공연 만들기. 원격 쓰기는 없고 로컬 미리보기 ID(음수)를 돌려준다. 실제 POST는 loopback HTTP 테스트로 확인한다.

## 남은 것

- 공연 페이지 이동(JECT-150), 밴드 프로필 "공연 추가하기"(밴드 기능), 밴드 목록 API, 포스터·장소 검색·지역 코드.
- 기본 앱 실서버 POST 비활성, 인증된 dev 환경 미검증.
- 실기기 확인은 사용자가 직접 한다.
