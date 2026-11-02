# 작업 흐름

두 명의 FE가 기능 단위로 나눠 개발한다. 이 문서는 "일을 어떤 순서로 하는가"만 다룬다.
코드 배치는 [mobile-architecture.md](./mobile-architecture.md), [web-architecture.md](./web-architecture.md),
색·간격 값은 [design-tokens.md](./design-tokens.md)를 본다.

## 1. 작업 단위

| Jira | 뜻 | 예 |
| --- | --- | --- |
| Epic | 기능 | 티켓팅 |
| Story | 사용자 흐름 | 관객이 공유 링크로 예매하고 예매번호를 받는다 |
| Task / Sub-task | 구현·검증 단위 | 예매 폼 화면, 예매 API 연동, 예매 완료 위젯 테스트 |

- Task 하나 = PR 하나가 기본. 이틀 안에 끝나지 않으면 Task를 쪼갠다.
- Task를 시작하기 전에 확인한다: 수락 기준(무엇이 되면 끝인가), 필요한 API 계약이 있는가(`docs/api/`, BE가 주는 명세를 여기 둔다), 상대의 공통 변경과 겹치지 않는가.
- 기능 담당자는 그 기능의 통합 책임자다. 페이지·API Task를 나눠 맡아도 머지 순서와 충돌 해결은 담당자가 본다. 영구 소유권은 아니다.

## 2. 브랜치에서 머지까지

```
develop ──┬── feat/JECT-123-reservation-form ──(PR, squash)──► develop
          └── fix/JECT-130-ticket-qr-blank ────(PR, squash)──► develop
develop ──(merge 커밋, 이력 유지)──► main ──► 스토어·웹 배포
main ──── fix/JECT-140-hotfix ──(PR)──► main ──(merge)──► develop
```

1. `develop`에서 분기: `git switch -c feat/JECT-123-reservation-form develop`
2. 구현 (3절 순서)
3. 로컬 검증 (4절)
4. PR: 제목 `[JECT-123] 예매 폼 화면`, 본문은 `.github/PULL_REQUEST_TEMPLATE.md`
5. 상대 리뷰 → 수정 → 승인 → squash merge. squash 커밋 제목은 커밋 규칙(`feat(JECT-123): 요약`)으로 고친다 — GitHub 기본값은 PR 제목(`[JECT-123] 요약`)이라 그대로 두면 규칙에 어긋난다
6. 머지 후 브랜치 삭제

`develop` 브랜치는 아직 없다. 첫 기능 작업 전에 `main`에서 만든다.

## 3. 기능 하나를 구현하는 순서

계약 → 모델 → 데이터 → 상태 → 화면 순서로 간다. 아래층이 먼저 있어야 위층을 테스트할 수 있다.

### 앱

| 순서 | 만드는 것 | 위치 (`lib/features/<x>/`) | 끝나는 기준 |
| --- | --- | --- | --- |
| 1 | API 계약 확인 | `docs/api/` | 요청·응답·오류 코드·멱등성 키·상태 전이가 적혀 있다 |
| 2 | 도메인 모델 | `models/` | freezed 클래스, 상태 enum. 화면이 쓰는 모양 |
| 3 | DTO + Service | `data/dto/`, `data/services/` | DTO `fromJson` 단위 테스트. Service는 Dio 호출만 |
| 4 | Repository | `data/repositories/` | DTO→모델 변환, 캐시. Fake Service로 단위 테스트 |
| 5 | 연결 Provider + ViewModel | `presentation/providers/`, `view_models/` | `ProviderContainer` 테스트: 로딩·성공·실패·중복 실행 |
| 6 | View + widgets | `presentation/views/`, `widgets/` | 위젯 테스트: 로딩·빈 결과·실패·정상 각 1개 |
| 7 | 라우트 등록 | `app/router.dart` | 딥링크·뒤로가기 수동 확인 |
| 8 | 수동 확인 | 시뮬레이터·실기기 | 수락 기준대로 동작, 캡처를 PR에 첨부 |

### 웹

`features/<x>/api/` → `hooks/` → `components/`·`pages/` → `app/router.tsx` 순서. 끝나는 기준은 앱과 같다.

### 서버가 아직 없을 때

Service를 인터페이스 없이 만들되 생성자 주입으로 받아 테스트에서 Fake로 바꿔 끼운다.
서버가 늦으면 고정 JSON을 돌려주는 임시 Service를 같은 자리에 두고, 실제 서버가 붙으면 그 파일만 지운다. 임시 Service를 기준으로 화면을 완성하지 않는다. 계약이 바뀌면 DTO부터 다시 맞춘다.

## 4. 로컬 검증 (PR 전 필수)

앱 (`apps/mobile`):

```bash
fvm dart format --set-exit-if-changed lib test
fvm flutter analyze
fvm flutter test
```

웹 (`apps/web`):

```bash
pnpm format:check && pnpm lint && pnpm typecheck && pnpm test && pnpm build
```

- 하나라도 실패한 채로 PR을 올리지 않는다. CI가 생기면 같은 명령을 돌린다.
- 명령 통과는 시작일 뿐이다. 구조·명령 처리·화면 상태·토큰·문구·데이터·테스트는 [pr-checklist.md A절](./pr-checklist.md#a-작성자-체크-pr-올리기-전)로 한 번 더 본다.
- 화면을 바꿨으면 캡처(앱: 바꾼 플랫폼, 웹: 모바일 폭)를 PR에 넣는다.
- 경로에 한글이 있으면 `flutter analyze`가 크래시한다(analysis server 버그). 영문 경로에 복사해서 돌린다.

## 5. 리뷰

- 리뷰어는 상대 1명. 하루 안에 첫 응답.
- 읽는 순서: 진입점(라우트·버튼) → 상태·요청 → 실패 방어(중복 실행·오류·빈 결과·늦은 응답) → 테스트 → 일관성 → 범위. PR 본문에 이 순서로 읽을 파일을 적는다. 각 단계에서 무엇을 보는지는 [pr-checklist.md B절](./pr-checklist.md#b-리뷰어-체크-읽는-순서).
- 코멘트는 `[must]`(머지 전 수정) / `[nit]`(막지 않음) 접두사와 근거 절 번호를 붙인다.
- 사전 공유가 필요한 변경: DI 등록, 공유 모델, 라우팅, 네이티브 설정, bridge, 디자인 토큰, `pubspec.yaml`·`package.json`. PR 전에 메시지로 한 줄 알린다.
- "승인 + 사소한 수정"은 작성자가 고치고 바로 머지한다. 설계가 갈리면 PR 댓글로 길게 가지 말고 짧게 통화한 뒤 결론을 PR에 적는다.

## 6. 릴리스·긴급 수정

- `develop` → `main`은 merge 커밋(이력 유지). 머지 전 `develop`에서 검증 통과 + 수동 확인.
- 긴급 수정은 `main`에서 `fix/...` 분기 → `main`에 PR → 머지 후 `main`을 `develop`에 merge.
- Dart만 바뀐 긴급 수정은 Shorebird patch 대상(설정 후). 네이티브·권한·SDK·에셋 변경은 새 스토어 release.
- 배포하면 소스 커밋, 검증 결과, (patch면) 환경·플랫폼·대상 release·patch 번호를 `docs/releases.md`에 한 줄 남긴다. 파일은 첫 배포 때 만든다.

## 7. 장애가 나면 보는 순서

- 앱: 세션 상태 → Provider 상태 → Repository 캐시 → HTTP 응답·토큰 갱신 → 라우팅
- 웹: 라우트·환경값(`shared/config/env.ts`) → API 응답 → bridge 명령·버전·출처
