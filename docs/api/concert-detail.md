# JECT-148 공연 상세 계약

출처: 2026-11-28 Notion API 명세의 `GET /api/v1/concerts/{concertId}`
(JECT-227 초안, 로컬 원문 2650–2777행).
Swagger 같은 날짜 사본에는 이 경로의 PUT만 있고 GET은 없다.
POST·PUT DTO, 티켓 계약, 라인업·피드·일정, 화면·경로는 이번 범위 밖이다.

## 읽는 순서

`app/di.dart`의 실제 `setupDi` → `ConcertRepository.fetchDetail(int concertId)`
→ `FakeConcertRepository` → `ConcertDetail`.
화면의 공용 조회는
`features/performances/presentation/providers/concert_detail_providers.dart`의
`concertRepositoryProvider`, `concertDetailProvider(int concertId)`를 사용한다.
후자는 `FutureProvider.autoDispose.family`이며 쓰기 담당자가 성공 후 해당 ID를 invalidate한다.
403·404는 자동 재시도하지 않고 즉시 오류로 전달한다.
실제 API가 배포되면 Service에서 응답 `data`를 `ConcertDetailDto.fromJson`으로 읽고
Repository에서 `toModel()`로 변환하는 구현을 추가한 뒤 DI 등록을 교체한다.
현재 내 공연 목록(JECT-154)도 같은 상세 fixture를 읽으므로 상세·참여 밴드·목록의
fake 등록을 함께 교체해야 한다. 목록의 합성 ID를 실제 상세 API에 보내지 않는다.
수정 기능(JECT-153)과 조합할 때는 조회·수정이 하나의 `FakeConcertEditRepository`를
공유한다. 합성 ID의 크기는 서버 쓰기 방어가 아니며, 실제 GET을 연결하기 전에는
그 ID·version으로 실서버 PUT을 보내면 안 된다.

## 응답

[원문 예시 JSON](examples/concert-detail.json)은 문서 응답을 그대로 보관한다.
DTO는 envelope가 아닌 `data`를 받는다.

| 필드 | Dart DTO / 모델 | null |
| --- | --- | --- |
| concertId, hostBandId, version | int | 불가 |
| title, updatedAt | String | 불가 |
| genres / myBandIds | List\<String\> / List\<int\> | 불가 |
| recruitTeamCount | int | 불가 |
| performDate, startTime, endTime | String? | 미정이면 null |
| place, address, region, posterImageUrl | String? | 가능 |
| rentalFee | int? | 가능 (0원과 다름) |
| status | ConcertStatus | 불가 |
| myPermissions | ConcertPermissions | 불가 |
| recruitment | ConcertRecruitment? | 공고 없으면 null |

`ConcertStatus`는 BEFORE_RECRUIT / RECRUITING / SELLING / SALE_PAUSED /
SALE_CLOSED와 클라이언트 sentinel `unknown`이다. 모집 상태는 RECRUITING / CLOSED /
`unknown`이다. 새 코드의 의미와 상태 전이를 추측하지 않는다.

`myPermissions`는 `isHostLeader`, `isTeamLeader` 두 필수 bool뿐이다.
누락·null·다른 타입이면 파싱 실패한다. ID 비교나 상태로 권한을 만들어내지 않는다.
실제 쓰기 권한은 서버가 최종 판단한다.

`recruitment`의 필수 필드는 recruitPostId(int), status(RecruitmentStatus),
deadline(String), joinedTeamCount(int), recruitTeamCount(int), newInquiryCount(int).
최상위와 모집 객체의 recruitTeamCount는 각 원문 값을 보존한다.

## 미확정 항목과 선택 이유

- LocalDate·LocalTime·LocalDateTime은 시간대 없는 문자열로 보존한다.
  UTC 변환이나 임의 날짜 결합 없이 수정 요청에 version과 원래 값을 전달할 수 있다.
- 장르·지역은 문자열을 보존한다. 지역 코드 목록은 아직 없으며, GET 초안에 없는
  코드 목록·역할 enum·추가 권한·상태 전이·티켓 필드를 만들지 않았다.
- 공연 상태 값은 서버 제안이며 티켓 담당과의 합의가 남아 있다.
- nullable 필드는 누락도 null로 읽는다. 필수 비nullable 필드는 누락을 기본값으로 숨기지 않는다.
- 정수 converter는 JSON 정수만 받는다. 기본 생성기의 `num.toInt()`로 소수 ID·버전·금액·개수를
  절삭하지 않는다. 잘못된 응답은 파싱 실패다.
- fake 기본 데이터는 공연 12 하나이며 명세 예시와 달리 두 권한이 false다.
  임의 ID를 받아 같은 공연으로 바꾸지 않는다.
  생성자로 공연 목록과 접근 금지 ID를 주입해 후속 화면에서 성공·없음·권한 거부를 재현한다.
- fake는 모든 flavor의 실제 DI에 임시 등록된다. 실제 사용자 권한이나 운영 데이터를
  나타내지 않으며 UI는 아직 연결하지 않았다. 인증·서버 요청·영속 저장·세션 캐시가 없다.

## 작업·학습 기록

구현·커밋·푸시·PR은 이번 요청에서 승인받았다. 설명 제공과 자동 QA는 사용자 이해 완료나
직접 확인을 뜻하지 않는다. 핵심 선택은 서버의 version·null·권한을 바꾸지 않는 것이다.
누락 권한을 true로 채우면 관리 버튼이 잘못 열리고 version을 새로 만들면 수정 충돌을
놓치므로, 필수값 파싱 실패와 명세 예시 변환을 각각 테스트한다.

## 검증과 장애 확인

`apps/mobile`에서 다음 명령으로 CLI 계약을 직접 확인한다.

```sh
fvm dart run tool/prove_concert_contract.dart ../../docs/api/examples/concert-detail.json
fvm flutter test test/features/performances test/app/concert_di_test.dart
```

CLI는 실제 DTO 변환, 권한 기본값, ID별 not-found와 forbidden 오류를 실행한다.
실제 DI 테스트는 공식 `InMemorySharedPreferencesAsync`를 사용한다.
이를 위한 dev dependency만 명시했으며 런타임 의존성 버전은 바꾸지 않았다.
실패하면 JSON의 `data`/필수 권한/version → DTO 변환 → DI 등록 순서로 확인한다.
실서버 GET 호환성과 사용자 직접 확인은 미확인이다.
