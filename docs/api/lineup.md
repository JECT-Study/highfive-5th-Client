# 라인업과 셋리스트 (JECT-165)

2026-11-28 Notion 초안 기준이다. 아래 다섯 작업은 같은 날 dev Swagger에 없다. 앱은 세션 안에서만 유지되는 fake를 사용한다. 실제 음악 서비스 키나 참여 팀 정보를 단말에 보관하지 않는다.

| 작업 | 계약 | 앱 동작 |
| --- | --- | --- |
| 라인업 조회 | `GET /api/v1/concerts/{concertId}/lineup` → `teams`, `emptySlotCount` | 서버 순서로 그린다. `lineupOrder`는 1부터, `setlistPreview`는 앞 3곡, `setlistTotalCount`는 전체 곡 수다. |
| 공연 순서 저장 | 같은 경로 `PUT {"bandIds":[7,3,12]}` → `data: {}` | 주최 팀도 옮길 수 있다. **현재 참여 중인 밴드 전부**를 한 번씩 보낸다. `409 CONCERT_014`이면 팀 구성이 바뀐 것이므로 다시 조회한다. |
| 팀 셋리스트 조회 | `GET /api/v1/concerts/{concertId}/teams/{bandId}/setlist` → `isHost`, `canEdit`, `band`, `songs` | 팀원이면 편집할 수 있다. `isHost`는 권한 값이 아니다. |
| 팀 셋리스트 저장 | 같은 경로 `PUT {"songs":[...]}` → `data: {}` | 완료할 때만 전체 목록을 보낸다. 빈 목록은 모든 곡 삭제, 같은 곡을 두 번 넣는 것도 허용한다. 저장용 곡에는 `externalUrl`이 없다. |
| 곡 검색 | `GET /api/v1/songs?keyword=oasis` → `songs` | 공백 제거 후 1~50자, 최대 20곡. `503 CONCERT_013`일 때도 자작곡을 직접 입력할 수 있다. |

검색 곡(`SEARCHED`)은 `trackId`, `songTitle`, `artist`, `durationSeconds`와 선택적인 `albumImageUrl`을 보낸다. 자작곡(`ORIGINAL`)은 제목과 선택적인 길이만 보낸다. 제목·아티스트는 최대 100자, 길이를 입력하면 1초 이상이다. 검색 곡의 재생 주소는 조회 응답 전용이다.

### 연결 경계

- 공연 상세는 `AppRoutes.showLineupOf(concertId)`로 연다. 라인업 카드는 `AppRoutes.showSetlistOf(showId, bandId)`로 이동한다. 공연 모델이나 다른 기능의 화면을 import하지 않는다.
- 새 팀은 합류 시 서버가 라인업 끝에 붙인다. 밴드 불러오기 화면이 팀 가입·제외 요청을 대신하지 않는다.
- 관객용 티켓 신청 페이지는 별도 웹 기능이다. 위 GET 두 개는 **참여 팀 멤버 전용**이므로 관객 페이지에서 호출하면 안 된다. 공개 페이지의 셋리스트 노출은 해당 공개 조회 계약과 연결해야 한다. 이 PR은 공개 API나 쓰기 권한을 추정하지 않는다.
