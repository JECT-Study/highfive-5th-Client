# 약관 동의

`GET /api/v1/terms` · `POST /api/v1/users/me/term-agreements`

- dev 서버: `https://dev-api.highfive-app.link` (Swagger `/swagger-ui/index.html`)
- 두 API 모두 지금은 가짜 응답이다 (약관 내용 미정, 동의를 저장하지 않음).

BE 명세를 앱에서 쓰는 부분만 옮겼다. 명세가 바뀌면 이 파일과 `features/auth/data/dto/` 아래 약관 DTO를 같이 고친다.

- 호출 시점: 로그인 응답의 `nextStep`이 `TERMS`일 때 로그인 화면 위에 뜬 약관 동의 시트에서
- 순서: 목록을 먼저 받아 `id`를 알고 → 사용자가 고른 동의·거부를 그 `id`로 보낸다. 사용자가 약관 본문을 열어 보지 않아도 목록은 받는다.
- 약관 개정 후 재동의에도 같은 두 API를 쓴다.

## 약관 목록 `GET /api/v1/terms`

현재 시행 중인 최신 버전 약관을 필수 → 선택 순으로 돌려준다. 앱은 받은 순서대로 보여 준다.

| 위치 | 이름 | 값 |
| --- | --- | --- |
| Header | Authorization | `Bearer {accessToken}` |

### 응답 (200)

| 필드 | 타입 | Null | 설명 |
| --- | --- | --- | --- |
| terms[].id | Long | X | 약관 ID. 동의 저장 때 `termId`로 보낸다 |
| terms[].code | String | X | 약관 종류 코드 |
| terms[].title | String | X | 화면에 보이는 제목 |
| terms[].version | String | X | 약관 버전 |
| terms[].required | Boolean | X | 필수 여부 |
| terms[].contentUrl | String | X | 본문 페이지 주소. 상세 화면에서 WebView로 연다 |

```json
{
  "status": 200,
  "code": "COMMON_000",
  "message": "요청이 성공했습니다.",
  "data": {
    "terms": [
      {
        "id": 1,
        "code": "SERVICE",
        "title": "서비스 이용약관",
        "version": "1.0",
        "required": true,
        "contentUrl": "https://..."
      }
    ]
  }
}
```

### 에러

| code | 상황 | 앱 처리 |
| --- | --- | --- |
| AUTH_002 | 액세스 토큰 만료 | 인터셉터가 재발급 후 다시 요청 |
| AUTH_001 · AUTH_003 | 토큰 오류 | 인터셉터가 로그아웃 → 로그인 화면 |

연결 실패·시간 초과는 "네트워크 상태를 확인하고 다시 시도해 주세요", 그 밖의 오류는 "잠시 후 다시 시도해 주세요". 목록을 못 받으면 다시 시도할 수 있게 한다.

## 동의 저장 `POST /api/v1/users/me/term-agreements`

최신 약관 각각의 동의·거부를 저장하고 다음 화면을 돌려준다.

| 위치 | 이름 | 값 |
| --- | --- | --- |
| Header | Authorization | `Bearer {accessToken}` |
| Header | Content-Type | `application/json` |
| Body | agreements[].termId | 목록에서 받은 `id` |
| Body | agreements[].agreed | 동의 `true` / 거부 `false` |

목록에서 받은 약관을 모두 보낸다 (선택 약관은 거부도 `false`로 보낸다).

```json
{
  "agreements": [
    { "termId": 1, "agreed": true },
    { "termId": 2, "agreed": true }
  ]
}
```

### 응답 (200)

| 필드 | 타입 | Null | 설명 |
| --- | --- | --- | --- |
| nextStep | String | X | `TERMS` / `PROFILE` / `BAND_START` / `HOME` (로그인 응답과 같은 규칙) |

```json
{
  "status": 200,
  "code": "COMMON_000",
  "message": "요청이 성공했습니다.",
  "data": { "nextStep": "PROFILE" }
}
```

### 에러

| HTTP | code | 상황 | 앱 처리 |
| --- | --- | --- | --- |
| 400 | USER_003 | 필수 약관 미동의 | 앱은 필수를 다 고르기 전 버튼을 막으므로 정상이면 안 온다. "잠시 후 다시 시도해 주세요" |
| 400 | COMMON_004 | 필드 누락, 최신이 아닌 `termId` | 약관이 바뀐 경우다. 목록을 다시 받는다 |

AUTH_001·002·003은 목록과 같다.

## 앱 참고

- 미동의 가입 차단은 서버가 최종 판단한다 (`USER_003`). 앱은 필수 약관을 다 고르기 전까지 "동의하고 계속하기"를 막고, 저장 중에는 다시 보내지 않는다.
- `nextStep`은 로그인 응답에서만 받는다. 앱을 다시 켜면 토큰과 함께 저장해 둔 `nextStep`으로 화면을 고르고, 동의 저장 응답의 `nextStep`으로 바꾼다. 로그아웃하면 같이 지운다.
- 약관 동의는 별도 화면이 아니라 로그인 화면 위의 BottomSheet다 (화면이 바뀌어 보이지 않게). 라우터는 `nextStep`이 terms인 동안 로그인 화면에 머물게 하고, 로그인 화면이 시트를 띄운다.
- 시트는 바깥 누르기·끌어내리기·뒤로 가기로 닫히지 않는다 (동의 없이 나가는 동작은 기획 확인 후 정한다).
- 약관 상세(`/terms/:termId`)는 시트 위에 쌓인다. 뒤로 가면 시트로 돌아오고 고른 체크는 그대로 남는다.
- 목록을 못 받으면 시트 안에 "다시 시도"를 보인다. 저장 실패는 Dialog로 알리고, `COMMON_004`면 목록을 다시 받는다.
