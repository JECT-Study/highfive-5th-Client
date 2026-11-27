# 개인 프로필

`GET /api/v1/codes` · `GET /api/v1/users/nickname-availability` · `PUT /api/v1/users/me/profile` · `POST /api/v1/uploads/presigned-url`

- dev 서버: `https://dev-api.highfive-app.link` (Swagger `/swagger-ui/index.html`)
- 사진 업로드(presigned URL)는 아직 동작하지 않는다. 사진을 고르고 "다음"을 누르면 업로드 실패 안내가 뜨고, "건너뛰기"(`profileImageUrl: null`)는 저장된다.
- 밴드 기능(JECT-71) 전이라 프로필 저장 후 `nextStep`은 항상 `BAND_START`다.
- dev DB는 개발 중 초기화될 수 있다.

BE 명세를 앱에서 쓰는 부분만 옮겼다. 명세가 바뀌면 이 파일과 프로필 DTO를 같이 고친다.

- 호출 시점: 약관 동의 저장 응답(또는 로그인 응답)의 `nextStep`이 `PROFILE`일 때 온보딩 프로필 화면에서. 마이페이지 프로필 수정도 같은 API를 쓴다.
- 순서: 정보 화면이 열리면 코드 목록을 받는다 → 닉네임 확인 통과, 장르·포지션 선택 → 사진 화면 "다음"(사진 있음: 업로드 URL 발급 → S3 업로드 → 저장) 또는 "건너뛰기"(바로 저장).

## 코드 목록 `GET /api/v1/codes?types=GENRE,POSITION`

정보 화면이 열릴 때 부른다. 칩에는 `name`을, 저장에는 `code`를 쓴다. 서버 ENUM이라 거의 바뀌지 않으므로 앱 실행 중 한 번 받아 저장소에 둔다 (`ProfileRepository.fetchOptions`). 못 받으면 칩 자리에 "다시 시도"를 보인다.

| 위치 | 이름 | 값 |
| --- | --- | --- |
| Header | Authorization | `Bearer {accessToken}` |
| Query | types | `GENRE,POSITION` |

```json
{
  "status": 200,
  "code": "COMMON_000",
  "message": "요청이 성공했습니다.",
  "data": {
    "GENRE": [{ "code": "ROCK", "name": "록" }, { "code": "ETC", "name": "기타" }],
    "POSITION": [{ "code": "VOCAL", "name": "보컬" }, { "code": "CUSTOM", "name": "직접입력" }]
  }
}
```

- 장르 `ETC`와 포지션 `GUITAR`는 둘 다 "기타"로 보인다. 앱은 code로 구분한다. Figma는 장르를 "직접입력"으로 그렸다 (디자이너 확인).
- `ETC`·`CUSTOM`을 고르면 입력칸이 나온다 (`ProfileDraft.genreCustomCode`·`positionCustomCode`).

## 닉네임 사용 가능 여부 `GET /api/v1/users/nickname-availability`

입력이 500ms 멈추면 저절로 부른다 (글자마다 부르지 않는다). 허용하지 않는 문자는 입력하자마자 안내하고 서버에 묻지 않으며, 길이가 틀리면 멈춘 뒤 서버에 묻지 않고 안내한다. 중복·형식 오류도 에러가 아니라 200 + `available: false`다.

- 명세(회의 D2)와 Figma는 "중복 확인" 버튼을 눌러 부른다. 앱은 버튼 없이 입력하며 확인한다 (기획 확인).

| 위치 | 이름 | 값 |
| --- | --- | --- |
| Header | Authorization | `Bearer {accessToken}` |
| Query | nickname | 확인할 닉네임 (URL 인코딩) |

### 응답 (200)

| 필드 | 타입 | Null | 설명 |
| --- | --- | --- | --- |
| available | Boolean | X | 사용 가능 여부 |
| reason | String | O | `INVALID_LENGTH` / `INVALID_CHARACTER` / `DUPLICATED`. 가능하면 `null` |

```json
{
  "status": 200,
  "code": "COMMON_000",
  "message": "요청이 성공했습니다.",
  "data": { "available": false, "reason": "DUPLICATED" }
}
```

| reason | 화면 문구 |
| --- | --- |
| `INVALID_LENGTH` | 닉네임은 2~10자로 입력해 주세요 |
| `INVALID_CHARACTER` | 한글, 영문, 숫자만 쓸 수 있어요 |
| `DUPLICATED` | 이미 사용 중인 닉네임이에요 |

서버 규칙: 2~10자, `^[가-힣a-zA-Z0-9]+$` (완성형 한글만), 영문 대소문자 구분 (`Rock` ≠ `rock`), 내 현재 닉네임은 중복에서 제외, 탈퇴 계정 닉네임도 제외.

### 에러

| HTTP | code | 상황 | 앱 처리 |
| --- | --- | --- | --- |
| 400 | COMMON_004 | `nickname` 파라미터 없음 | 개발 오류 |
| 401 | AUTH_002 | 액세스 토큰 만료 | 인터셉터가 재발급 후 다시 요청 |

확인 결과는 참고용이다. 저장 직전 다른 사람이 가져갈 수 있어 프로필 저장의 `USER_001`이 최종 판단이다.

## 프로필 저장 `PUT /api/v1/users/me/profile`

닉네임·장르·포지션·사진을 한 번에 저장한다. 온보딩 중(`PENDING`)이면 `ACTIVE`로 바뀐다.

| 위치 | 이름 | 값 |
| --- | --- | --- |
| Header | Authorization | `Bearer {accessToken}` |
| Header | Content-Type | `application/json` |

### Body

| 필드 | 타입 | 필수 | 설명 |
| --- | --- | --- | --- |
| nickname | String | O | 2~10자, 한글·영문·숫자 |
| genreCodes | String[] | O | 1개 이상, 개수 제한 없음. `ETC`(기타)를 고르면 `genreCustomName` 필수 |
| genreCustomName | String | △ | 앞뒤 공백 제거 후 1~10자, 한글·영문·숫자. `ETC`가 없으면 `null` |
| positionCodes | String[] | O | 1개 이상, 개수 제한 없음. `CUSTOM`(직접입력)을 고르면 `positionCustomName` 필수 |
| positionCustomName | String | △ | 앞뒤 공백 제거 후 1~10자, 한글·영문·숫자. `CUSTOM`이 없으면 `null` |
| profileImageUrl | String | X | 업로드 URL 발급에서 받은 `fileUrl`. 건너뛰면 `null` (최대 500자) |

```json
{
  "nickname": "두현",
  "genreCodes": ["ROCK", "ETC"],
  "genreCustomName": "시티팝",
  "positionCodes": ["VOCAL", "CUSTOM"],
  "positionCustomName": "하모니카",
  "profileImageUrl": null
}
```

### 응답 (200)

| 필드 | 타입 | Null | 설명 |
| --- | --- | --- | --- |
| status | String | X | `ACTIVE` |
| nextStep | String | X | 속한 밴드가 없으면 `BAND_START`, 있으면 `HOME` |

```json
{
  "status": 200,
  "code": "COMMON_000",
  "message": "요청이 성공했습니다.",
  "data": { "status": "ACTIVE", "nextStep": "BAND_START" }
}
```

### 에러

| HTTP | code | 상황 | 앱 처리 |
| --- | --- | --- | --- |
| 409 | USER_001 | 저장 시점 닉네임 중복 | 닉네임 화면으로 돌아가 다시 입력 |
| 400 | COMMON_004 | 필수값 누락, 형식 위반, 없는 코드, 직접 입력 값 누락·초과 (`errors[].field`·`reason`) | 필드별 안내 |
| 400 | USER_003 | 필수 약관 미동의 (JECT-213 전까지는 안 옴) | 약관 시트로 |
| 404 | USER_005 | 토큰의 회원이 없음 | 토큰 삭제 후 로그인 화면 |
| 401 | AUTH_002 | 액세스 토큰 만료 | 인터셉터가 재발급 후 다시 요청 |

```json
{
  "status": 400,
  "code": "COMMON_004",
  "message": "입력값이 올바르지 않습니다.",
  "errors": [
    { "field": "genreCodes", "reason": "선호 장르를 1개 이상 골라 주세요." },
    { "field": "nickname", "reason": "닉네임은 2~10자여야 합니다." }
  ]
}
```

## 업로드 URL 발급 `POST /api/v1/uploads/presigned-url` (아직 동작 안 함)

사진을 고른 직후 부른다. 앱이 S3에 직접 올릴 임시 주소를 받는다. 온보딩은 `purpose = USER_PROFILE`만 쓴다.

| 위치 | 이름 | 값 |
| --- | --- | --- |
| Header | Authorization | `Bearer {accessToken}` |
| Header | Content-Type | `application/json` |
| Body | purpose | `USER_PROFILE` |
| Body | contentType | `image/jpeg` / `image/png` / `image/heic` |
| Body | fileSize | 바이트, 1 이상 (최대 용량은 아래 "확인 필요") |

### 응답 (200)

| 필드 | 타입 | Null | 설명 |
| --- | --- | --- | --- |
| uploadUrl | String | X | 파일을 `PUT`으로 올릴 주소 (5분 유효) |
| fileUrl | String | X | 프로필 저장의 `profileImageUrl`로 보낼 주소 |
| expiresAt | String | X | `uploadUrl` 만료 시각 |

### 업로드 순서

1. 이 API로 `uploadUrl`·`fileUrl`을 받는다.
2. `uploadUrl`에 `PUT`. `Content-Type`은 1번과 같은 값, **Authorization 헤더는 넣지 않는다** (앱 Dio 인터셉터를 거치지 않는 별도 클라이언트로 보낸다).
3. 200이면 `fileUrl`을 프로필 저장에 넣는다.
4. 실패·만료면 1번부터 다시.

| HTTP | code | 상황 | 앱 처리 |
| --- | --- | --- | --- |
| 400 | COMMON_004 | 형식·용량 위반, 필드 누락 | 용량·형식 안내 후 다시 고르기 |
| 401 | AUTH_002 | 액세스 토큰 만료 | 인터셉터가 재발급 후 다시 요청 |

## 확인 필요

- **최대 용량**: 기능명세서는 10MB("사진은 10MB까지 올릴 수 있어요"), 이 API는 5MB(제안). 어느 쪽인지 BE와 맞춘다.
- **코드 목록 서버 제공** (회의 D4): 앱은 서버 목록을 쓴다. 이 API를 지우지 않도록 BE에 알린다.
- **장르 "기타" 표시 이름**: 서버 `ETC`는 "기타", Figma는 "직접입력". 포지션 "기타"(`GUITAR`)와 겹쳐 보인다.
- **닉네임 확인 시점**: 명세·Figma는 "중복 확인" 버튼, 앱은 입력하며 자동 확인 (버튼 없음).
- **허용 문자 안내 문구**: 기능명세서 "한글, 영문, 숫자만 쓸 수 있어요" / API 명세 "사용할 수 있어요". 위 표는 기능명세서를 따랐다.
