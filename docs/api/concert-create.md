# 합동공연 생성

`POST /api/v1/concerts`

- dev 서버: `https://dev-api.highfive-app.link` (Swagger `/swagger-ui/index.html`). 2026-11-28 Swagger와 Notion `합동공연 생성`(JECT-217)을 대조했다. 둘이 다르면 Swagger를 따른다.
- BE 명세를 앱에서 쓰는 부분만 옮겼다. 명세가 바뀌면 이 파일과 `features/performances/data/dto/concert_create_dto.dart`를 같이 고친다.
- 기본 앱 실서버 POST 비활성, 인증된 dev 환경 미검증. 아래는 로컬 HTTP 테스트로 확인하는 서버 계약이며 라이브 생성 연동 완료를 뜻하지 않는다.
- 요청한 밴드(`bandId`)가 주최 팀(라인업 1번)이 되고, 만든 사람(그 밴드의 대표자)이 초기 주최 대표자가 된다.

## 진입·임시 데이터의 경계

- 공용 진입: `context.push<int>(AppRoutes.showNew)`. `extra`가 없으면 밴드 선택 시트를 연 뒤 생성 폼으로 간다. 취소하면 이전 화면으로 돌아온다. JECT-154의 추가 버튼도 이 주소만 사용한다.
- 인증된 서버 응답/밴드 프로필에서 현재 계정이 대표자임을 확인했을 때만 `HostBand.authenticated(...)`를 `extra`로 넘겨 폼을 바로 연다. 기본 DI는 이 밴드를 넘겨도 실제 POST를 하지 않고 비활성 안내를 표시한다. 실제 밴드 프로필 화면과 대표 밴드 조회 API는 아직 없다.
- 기본 `HostBand(...)`와 `FakeHostBandRepository`는 임시 출처다. 모든 flavor에서 `LocalConcertCreationRepository`에만 생성하며 공유 dev 서버에도 POST하지 않는다. 음수 로컬 ID와 입력을 메모리에 보관하며 앱 종료 시 사라진다. prod는 임시 목록도 노출하지 않는다.
- 기본 `ConcertCreationRepository`는 로컬 생성만 허용하며 `ConcertCreationService`를 DI에 등록하지 않는다. 원격 어댑터는 `ConcertCreationRepository.forContractTest(service)`의 명시적인 로컬 테스트 주입으로만 사용한다. 실제 POST 계약은 loopback HTTP 서버로 검증한다.

## 요청

| 필드 | 타입 | 필수 | 서버 검증 | 앱에서 |
| --- | --- | --- | --- | --- |
| bandId | Long | O | | 밴드 선택 시트에서 고른 밴드. 밴드 조회 API가 없어 지금은 임시 목록(`FakeHostBandRepository`) |
| title | String | O | 공백 불가, 최대 30자 | 앞뒤 공백을 빼고 보낸다 |
| genres | String[] | O | 1개 이상, `ROCK`·`INDIE`·`METAL`·`PUNK`·`POP`·`JAZZ`·`ETC` | Figma 칩 7개. "직접입력"은 `ETC` (직접 입력 값은 서버가 아직 받지 않는다) |
| recruitTeamCount | Integer | O | 1 이상 | 주최 팀 제외, 1부터 |
| performDate | LocalDate | - | 오늘보다 이전이면 거절, null = 미정 | 생성 시안에서 필수 정보라 꼭 고르게 한다 |
| startTime · endTime | LocalTime | - | 함께 보내거나 함께 null | 생성 시안에 없어 보내지 않는다 |
| place · address | String | - | 100자 · 200자 | 장소 검색 계약이 없어 보내지 않는다 (미정) |
| region | String | - | 지역 코드 | 코드 목록이 `/api/v1/codes`에 아직 없어 보내지 않는다 |
| rentalFee | Integer | - | 0 이상, null = 미정 | "아직 미정이에요"면 null |
| posterImageUrl | String | - | 업로드 API의 `fileUrl` | 업로드 용도(`purpose`)가 `USER_PROFILE`뿐이라 보내지 않는다 |

```json
{
  "bandId": 1,
  "title": "겨울 합동공연",
  "genres": ["ROCK", "INDIE"],
  "recruitTeamCount": 3,
  "performDate": "2026-12-20",
  "rentalFee": null
}
```

## 응답 (201)

| 필드 | 타입 | Null | 설명 |
| --- | --- | --- | --- |
| concertId | Long | X | 만든 공연 ID |

```json
{ "status": 201, "code": "COMMON_000", "message": "요청이 성공했습니다.", "data": { "concertId": 12 } }
```

## 에러

| HTTP | code | 상황 | 앱 처리 |
| --- | --- | --- | --- |
| 400 | COMMON_004 · COMMON_001 · CONCERT_010 | 필수값·길이·형식·코드 오류 | "입력한 내용을 확인해 주세요" (앱 검증이 먼저 막는다) |
| 400 | CONCERT_002 | 공연 날짜가 오늘 이전 | 날짜 칸에 오류 표시 + 안내 |
| 403 | AUTH_005 | 밴드 대표자가 아님 | 안내 후 이전 화면 |

결과 조회·멱등성 키 계약이 없다. 그래서 앱은 실패를 두 가지로 나눈다.

- 다시 보내도 되는 실패: 본문을 보내기 전 연결 실패(`NetworkException`), 입력 오류, 그 밖의 4xx. 고치거나 다시 누른다.
- 만들어졌는지 모르는 실패: 본문 전송 후 연결 끊김·응답 시간 초과, 3xx·5xx, 성공 응답을 해석하지 못함. 계약 테스트용 저장소가 밴드별로 기억해 화면 재진입 후에도 같은 밴드의 POST를 막는다. 앱 재시작까지 보장하는 영속 잠금은 아니므로 최종 중복 방지는 서버의 조회·멱등성 계약이 필요하다. 생성 POST는 자동 리다이렉트를 하지 않는다.
- 화면이 폐기되면 요청을 취소한다. 이미 서버가 받은 요청을 되돌리는 것은 아니다. 본문 전송 전 취소는 결과 불명 잠금을 남기지 않는다.

## 아직 없는 것

- 만든 뒤 공연 페이지(`/shows/:showId`, JECT-150)로 이동. 지금은 만든 ID를 연 쪽에 돌려주고 화면을 닫는다.
- 내가 대표자인 밴드 목록 API → `HostBandRepository` 실제 구현으로 `app/di.dart` 한 줄 교체.
- 밴드 프로필의 "공연 추가하기" 연결: 실제 프로필 화면이 아직 없어 이번 범위에서 추가하지 않는다.
- 포스터 업로드 용도, 장소 검색(Figma `합동공연생성-장소검색` 2217:123484), 지역 코드 형식, 장르 직접 입력·최대 개수 [합의 필요].
