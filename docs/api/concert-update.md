# JECT-153 공연 정보 수정 미리보기

**실서버 PUT은 연결하지 않았으며 미검증이다.** 앱은 상세 조회와 저장에 같은 메모리 저장소를 쓴다.
PUT 서비스·요청 직렬화·기능 전용 실패 매핑은 보존하되 앱 기본 DI에 연결하지 않는다.
이 어댑터의 실행 검증은 루프백 테스트에서만 한다.

## 앱 흐름

`/shows/:showId/edit` → `ConcertEditView` → 공용 `concertDetailProvider(id)`(JECT-148)
→ `ConcertEditForm` → 확인 팝업 → `ConcertEditViewModel.save`
→ `ConcertEditRepository.update` → `FakeConcertEditRepository`.

- 공연 페이지가 읽은 상세·version을 그대로 재사용하며 직접 진입하면 ID로 상세를 읽는다.
- 폼은 `(concertId, version)`으로 구분한다.
- 저장이 끝나면 **수정 기능의 ViewModel**이 공용 상세를 invalidate한다. 전역 갱신 구독은 추가하지 않는다.
- 라우터는 이전 화면에 `true`를 돌려주고, 이전 화면이 없으면 홈으로 간다.
- `app/di.dart`가 한 fake 객체를 조회·수정 인터페이스로 함께 등록한다.
  저장값은 앱 실행 중 메모리에 남고 다시 시작하면 초기화된다.

## 입력과 메모리 저장 규칙

| 항목 | 처리 |
| --- | --- |
| 제목 | 공백 정리, 1~30자 |
| 장르 | 1개 이상, 기존에 있던 알 수 없는 코드는 보존 |
| 날짜 | 바꿀 때 오늘(서울 기준) 이전·진행 중 모집 마감일 이전은 제한 |
| 시간 | 시작·종료를 함께 입력하거나 함께 미정, `HH:mm` 입력 |
| 장소명·주소 | 각각 선택 입력, 각각 100자·200자 제한, 수정하지 않은 원문 보존 |
| 대관비 | 0~2,147,483,647 정수 또는 미정. 입력 중 숫자 원문, 입력 종료 후 쉼표 표시 |
| 모집 팀 수 | 합류 팀 수보다 적게 줄이지 못함. 주최 대표자에게만 조절 버튼 활성화 |
| 지역·포스터 URL | 화면에서 바꾸지 않고 상세 값 보존 |
| version | 읽은 값으로 비교. fake 저장 성공 시 1 증가 |

같은 version의 동시 저장은 한 번만 성공하며 먼저 저장한 값을 덮어쓰지 않는다.
값이 바뀌지 않았으면 저장하지 않는다. 충돌 재조회 중에는 이전 폼을 숨긴다.
로딩·없음·볼 수 없음·재시도 상태, 입력 오류, 저장 중 잠금, 수정 확인·나가기 팝업을 처리한다.

## PUT 구현과 루프백 계약 검증

`RemoteConcertEditRepository` → `ConcertEditService` → `ConcertUpdateRequestDto.toJson()`을 보존한다.
실패는 `ConcertUpdateErrorDto`에서 HTTP 상태·코드·필드 오류를 받고 `ConcertEditFailure`로 변환한다.
`test/features/performances/data/repositories/concert_edit_repository_test.dart`가 이 실제 구현을
이 기기 안의 HTTP 서버로만 호출한다. 앱의 기본 저장소 등록은 여전히 fake다.

계약은 Swagger `PUT /api/v1/concerts/{concertId}`와 Notion 1.3을 읽고 정리한 것이다.

| 키 | 예시에서 보내는 값 |
| --- | --- |
| title | 제목 |
| genres | 장르 코드 목록 |
| recruitTeamCount | 모집 팀 수 |
| performDate | `yyyy-MM-dd` 또는 null |
| startTime / endTime | `HH:mm:ss` 또는 null |
| place / address | 장소명·주소 또는 null |
| region | 원래 지역 코드 또는 null |
| rentalFee | 정수 또는 null |
| posterImageUrl | 원래 URL 또는 null |
| version | 상세에서 읽은 version |

선택 항목도 키를 빼지 않고 null까지 포함한다. 테스트는 실제 서비스·직렬화를 루프백 서버로 호출해 메서드·경로·본문 12개 키,
응답 예시의 입력 오류·충돌·실패 분류와 연결 끊김을 확인한다.
**이 예시 통과는 실제 서버 호환성·실제 PUT 성공을 증명하지 않는다.**

ViewModel은 테스트 대역으로 결과 미확인 상태도 검증한다. 이때는 최초 제출값을 보관하고
기존 버튼으로 조회만 재확인한다. 폼이 새 상세로 채워져도 확인 기준을 바꾸지 않고 종료 확인을 거친다.
화면이 닫히거나 provider가 재생성된 뒤의 응답은 반영하지 않는다.

## 화면과 공통 위젯

Figma 공연정보수정·수정 확인·나가기 팝업 구조를 공통 토큰과 위젯으로 구현했다.
긴 변경값은 줄바꿈하고 팝업 내용만 스크롤한다. 장소명·주소는 별도 줄로 표시한다.
연도가 다른 날짜 변경은 연도도 보여준다.

- `CalendarWeekRow.padding`은 생성 화면의 호출과 호환된다. 생략 시 44px 날짜 칸을 우선 확보한다.
- `AppBottomSheet.horizontalPadding` 기본값은 기존 토큰이고 좁은 달력에서만 줄인다.
- `AppTextField.focusNode`로 대관비의 포커스별 표시 형식을 처리한다.

## 제한과 후속 작업

- 실제 상세 GET·PUT 연동과 서버 통합 검증은 별도 작업이다.
- 장르 선택값은 `concert_edit_genres.dart`에 둔다. 백엔드 enum은 유지하고 코드 API 사용이 정해지면 공용 테이블로 합친다.
- 포스터 업로드는 비활성이다. 장소 검색 대신 장소명·주소를 직접 입력하고 region은 보존한다.
- 공연 삭제·참여 팀 관리는 별도 기능이다. 푸시 발송을 약속하는 문구는 표시하지 않는다.
- 실기기·시뮬레이터와 사용자 직접 확인은 별도다.

## 문제가 생기면

경로 ID → 상세 provider 상태 → 폼 검증 → ViewModel 상태 → 조회·수정 DI가 같은 fake인지 순서로 확인한다.
상세 반영은 수정 기능의 invalidate와 fake의 새 version을 확인한다.
