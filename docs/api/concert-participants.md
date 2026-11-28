# JECT-150 참여 밴드 조회 계약

출처: 2026-11-28 Notion API 명세의 `GET /api/v1/concerts/{concertId}/lineup`
(라인업 조회, JECT-228 초안, 로컬 원문 2211–2322행). 같은 날짜 Swagger 사본에는 이 경로가 없다.
공연 페이지(`ConcertDetailView`)의 접근 확인과 정보 탭의 참여 밴드 미리보기(`ConcertParticipantsPreview`)가 이 계약을 쓴다.

## 읽는 순서

`app/di.dart`의 `setupDi` → `ConcertParticipantsRepository.fetchParticipants(int concertId)`
→ `FakeConcertParticipantsRepository` → `ConcertParticipant`.
화면은 `features/performances/presentation/providers/concert_participants_providers.dart`의
`concertParticipantsProvider(int concertId)`(`FutureProvider.autoDispose.family`)를 쓴다.
참여 밴드를 바꾸는 쓰기(빼기 등)는 성공 후 이 family와 `concertDetailProvider`를 invalidate한다.

## 읽는 값

라인업 응답 `data.teams[]`(공연 순서대로)에서 아래 세 값만 읽는다.
공연 순서·셋리스트 미리보기·빈자리 수(`emptySlotCount`)는 라인업 기능(JECT-165)이,
밴드 사진·장르·인원은 참여 밴드 프로필(JECT-152)이 필요할 때 읽는다.

| 응답 필드 | `ConcertParticipant` | null |
| --- | --- | --- |
| `teams[].band.bandId` | `bandId` (JSON 정수만) | 불가 |
| `teams[].band.name` | `name` | 불가 |
| `teams[].isHost` | `isHost` | 불가 |

필수 값이 없거나 null이면 파싱 실패다. 주최 여부를 false로 채우거나 소수 ID를 정수로 자르지 않는다.
`isHost`는 주최 팀 표시용이다. 관리 버튼은 공연 상세의 `myPermissions`(서버 판단)로 정한다.

## 오류

| HTTP | code | 상황 | 앱 처리 |
| --- | --- | --- | --- |
| 404 | CONCERT_001 | 공연 없음 (삭제 포함) | 상세·참여 밴드 중 어느 조회든 이 오류면 이전 내용을 숨기고 안내 후 이전 화면으로 보낸다 |
| 403 | AUTH_005 | 참여 팀 멤버가 아님 | 위와 같다 |

403·404는 자동 재시도하지 않는다. 화면은 위 HTTP·code 쌍만 접근 차단으로 분류한다.
다른 오류는 갱신 전 값이 있어도 실패와 다시 시도 버튼을 보인다. 수동 재시도 응답을 기다리는 동안에는 버튼을 다시 누를 수 없다.

## 임시 구현과 교체

- `app/di.dart`가 모든 flavor에서 `FakeConcertParticipantsRepository`를 등록한다. 네트워크·세션·저장소를 쓰지 않는다.
- 기본 데이터는 공연 12 하나다. 주최 밴드 3(`새벽세시`)은 명세 예시이고 공연 상세 fake의 `hostBandId`·`myBandIds`와 같다.
  두 번째 팀 9001(`오프비트`)은 합류 1팀(`recruitment.joinedTeamCount`)을 보이려고 만든 합성 데이터로, 실제 밴드가 아니다.
- 실제 API가 배포되면 Service가 응답 `data`를 `ConcertParticipantsDto.fromJson`으로 읽고
  Repository가 `toModel()`로 바꾸는 구현을 추가한 뒤 DI 한 줄을 교체한다.
- 라인업 기능이 같은 응답을 읽는 Repository를 만들면, 이 계약을 그 결과의 투영으로 합칠지 정한다. 같은 응답을 두 번 부르지 않게 한다.

## 검증

`apps/mobile`에서:

```sh
fvm flutter test test/features/performances/data test/app/concert_participants_di_test.dart
```

실서버 응답 호환성과 사용자 직접 확인은 미확인이다.
