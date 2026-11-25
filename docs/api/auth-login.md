# 소셜 로그인 · 회원가입

`POST /api/v1/auth/login/{provider}`

- dev 서버: `https://dev-api.highfive-app.link` (Swagger `/swagger-ui/index.html`). DB는 개발 중 초기화될 수 있다.
- 애플은 서버가 아직 지원하지 않는다 (Apple Developer 설정 전).

BE 명세를 앱에서 쓰는 부분만 옮겼다. 명세가 바뀌면 이 파일과 `features/auth/data/dto/login_response_dto.dart`를 같이 고친다.

- 호출 시점: 로그인 화면에서 카카오·구글·애플 SDK 로그인에 성공한 직후
- 하는 일: 소셜 토큰 검증 → 회원 조회(없으면 가입) → 서비스 토큰 발급 → 다음 화면(`nextStep`) 안내
- 신규 가입과 기존 회원 로그인을 같은 API로 처리한다 (응답 형식 동일, `status`·`nextStep`으로 구분)

## 요청

| 위치 | 이름 | 값 |
| --- | --- | --- |
| Header | Content-Type | `application/json` |
| Path | provider | `kakao` / `google` / `apple` (소문자) |
| Body | token | 카카오: ID 토큰 (OpenID Connect) / 구글: ID 토큰 / 애플: identityToken (`@NotBlank`) |

```json
{ "token": "소셜 SDK에서 받은 토큰" }
```

## 응답 (200)

| 필드 | 타입 | Null | 설명 |
| --- | --- | --- | --- |
| accessToken | String | X | 서비스 액세스 토큰 (JWT, 30분) |
| refreshToken | String | X | 서비스 리프레시 토큰 (JWT, 14일) |
| user.id | Long | X | 사용자 ID |
| user.status | String | X | `PENDING`(약관·프로필 미완료) / `ACTIVE` |
| user.nickname | String | O | 프로필 생성 전 `null` |
| nextStep | String | X | `TERMS` / `PROFILE` / `BAND_START` / `HOME` |

```json
{
  "status": 200,
  "code": "COMMON_000",
  "message": "요청이 성공했습니다.",
  "data": {
    "accessToken": "eyJ...",
    "refreshToken": "eyJ...",
    "user": { "id": 12, "status": "PENDING", "nickname": null },
    "nextStep": "TERMS"
  }
}
```

`nextStep` 계산 규칙 (위에서부터 먼저 맞는 것): 동의 안 한 최신 필수 약관 있음 → `TERMS`, 닉네임 없음 → `PROFILE`, ACTIVE로 속한 밴드 없음 → `BAND_START`, 그 외 → `HOME`.

## 에러

| HTTP | code | 상황 | 앱 처리 |
| --- | --- | --- | --- |
| 400 | AUTH_007 | provider 오류 | 개발 오류. "잠시 후 다시 시도해 주세요" |
| 401 | AUTH_006 | 소셜 토큰 검증 실패 | "소셜 로그인 인증에 실패했어요" 안내 후 로그인 화면 유지 |
| 403 | USER_004 | 탈퇴한 계정 (재가입 정책 결정 전 임시) | "탈퇴한 계정이에요" 안내 |
| 400 | COMMON_004 | token 누락 | 개발 오류. "잠시 후 다시 시도해 주세요" |

연결 실패·시간 초과는 "네트워크 상태를 확인하고 다시 시도해 주세요" (Figma 공통 문구), 그 밖의 오류는 "잠시 후 다시 시도해 주세요". 모두 로그인 화면에 머문다.

## 앱 참고

- 사용자가 소셜 로그인을 취소하면 이 API를 호출하지 않고 로그인 화면에 머문다.
- 받은 두 토큰은 `flutter_secure_storage`에 저장한다 (`SessionRepository`).
- 서버는 `refresh:{userId}`를 덮어쓰므로 새 기기에서 로그인하면 이전 기기의 로그인이 끊긴다 (동시 로그인 불가).
- `nextStep`에 따라 화면을 옮긴다. 약관·프로필·밴드 시작 화면이 생기기 전까지는 모두 홈으로 간다.
- 구글은 SDK에 서버용(웹) 클라이언트 ID를 `serverClientId`로 넣어야 서버 검증을 통과한다 (`env.dart` `googleServerClientId`).
- 이후 요청은 `Authorization: Bearer {accessToken}`. `AUTH_002`(액세스 토큰 만료)일 때만 `POST /api/v1/auth/refresh` 후 원래 요청을 다시 보낸다. 재발급하면 리프레시 토큰도 바뀌므로 새 값으로 저장한다. `AUTH_004`면 로그인 화면으로 (다른 기기 로그인 포함). 로그아웃은 `POST /api/v1/auth/logout` (Bearer). 아직 구현 전.
