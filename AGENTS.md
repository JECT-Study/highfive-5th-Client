# highfive-5th-Client 작업 규칙

사람과 코딩 에이전트가 같이 보는 입구다. 여기에는 **항상 지킬 것**과 문서 지도만 두고, 규칙의 본문은 `docs/` 한 곳에만 둔다. 규칙을 바꿀 때는 `docs/`를 고치고 여기는 링크만 유지한다.

| 알고 싶은 것 | 문서 |
| --- | --- |
| 전체를 그림으로 한 번에 (처음 읽을 때) | [docs/overview.md](./docs/overview.md) |
| 일을 어떤 순서로 하나 (Jira → 브랜치 → 구현 순서 → 검증 → PR → 리뷰 → 릴리스) | [docs/workflow.md](./docs/workflow.md) |
| 앱 폴더에 어떤 파일이 들어가고 누가 누구를 import하나, dev/prod flavor | [docs/mobile-architecture.md](./docs/mobile-architecture.md) |
| 웹 폴더 구조·의존성·bridge·환경 | [docs/web-architecture.md](./docs/web-architecture.md) |
| 색·간격·글자 크기 값과 바꾸는 절차 | [docs/design-tokens.md](./docs/design-tokens.md) |
| PR 올리기 전·리뷰할 때 무엇을 왜 보나 | [docs/pr-checklist.md](./docs/pr-checklist.md) |

## 저장소와 명령

```
apps/mobile/   Flutter 앱. 명령은 이 폴더에서 `fvm flutter ...`
apps/web/      React + TypeScript + Vite. 명령은 이 폴더에서 `pnpm ...`
docs/          규칙 문서. BE API 명세는 docs/api/ 에 둔다
.github/       PR 템플릿, CI (mobile.yml · web.yml — PR마다 아래 검증을 돌린다)
```

| | 앱 (`apps/mobile`) | 웹 (`apps/web`) |
| --- | --- | --- |
| 설치 | `fvm install && fvm flutter pub get` | `corepack enable && pnpm install` |
| 실행 | `fvm flutter run --flavor dev` (`prod`) | `pnpm dev` |
| 포맷 | `fvm dart format lib test tool` | `pnpm format` |
| 분석·린트 | `fvm flutter analyze && fvm dart run tool/check_imports.dart` | `pnpm lint && pnpm typecheck` |
| 테스트 | `fvm flutter test` | `pnpm test` |
| 빌드 | `fvm flutter build apk\|ipa --flavor prod` | `pnpm build` (prod) / `pnpm build:dev` |
| 코드 생성 | `fvm dart run build_runner build --delete-conflicting-outputs` | - |

Flutter 버전은 `apps/mobile/.fvmrc`, Node는 `apps/web/.nvmrc`·`packageManager`로 고정한다. CI도 같은 파일을 읽는다. 한글 경로에서 `flutter analyze`가 크래시하면 영문 경로에 복사해서 돌린다.

## 항상 지킬 것

1. feature-first. 실제 구현하는 기능부터 만들고 빈 폴더·UseCase·미래용 인터페이스를 미리 만들지 않는다. → [mobile 1절](./docs/mobile-architecture.md#1-폴더와-들어가는-파일)
2. import는 `app → features → core/shared` 한 방향. 웹은 ESLint, 앱은 `tool/check_imports.dart`가 막는다. → [mobile 2절](./docs/mobile-architecture.md#2-의존성-방향) · [web 2절](./docs/web-architecture.md#2-의존성-방향)
3. View는 표시·입력·이동, ViewModel은 상태·명령, Repository는 변환·캐시, Service는 호출만. `getIt`은 `app/di.dart`와 연결 Provider에서만. → [mobile 3절](./docs/mobile-architecture.md#3-계층-책임)
4. 신청·예매·결제 같은 쓰기 명령은 버튼 → ViewModel 메서드로만, 중복 실행을 막고, 권한·재고·가격은 서버가 최종 판단. → [mobile 4절](./docs/mobile-architecture.md#4-상태를-어디에-두는가)
5. 로그아웃·계정 전환 시 세션·캐시·소켓·보안 저장소를 정리하고 이전 세션의 늦은 응답은 버린다. → [mobile 4절](./docs/mobile-architecture.md#4-상태를-어디에-두는가)
6. 토큰·개인정보는 로그·URL·prefs·분석 이벤트에 넣지 않는다. 인증 정보는 `FlutterSecureStorage`에만. → [checklist A9](./docs/pr-checklist.md#a9-데이터보안설정-위치)
7. 색·간격·모서리·글자 크기는 토큰만 쓴다. 토큰 변경은 앱·웹·문서를 한 PR에서. → [design-tokens](./docs/design-tokens.md)
8. 환경값은 앱 `app/env.dart`, 웹 `shared/config/env.ts`에서만 읽는다. 경로 문자열은 `AppRoutes`/`routes.ts`에만. 앱 명령에는 항상 `--flavor dev|prod`를 붙인다. → [mobile 10절](./docs/mobile-architecture.md#10-환경flavor)
9. 생성 파일(`*.g.dart`, `*.freezed.dart`)은 손대지 않고 커밋한다. `any`, `// ignore:`, `eslint-disable`로 오류를 숨기지 않는다.
10. 테스트는 앱 `test/`에 `lib/` 미러, 웹은 파일 옆. 문구 고정·고정 sleep 금지. → [checklist A10](./docs/pr-checklist.md#a10-테스트)
11. PR 전 로컬 검증 전부 통과 + 체크리스트. DI·모델·라우팅·네이티브·bridge·토큰·의존성 변경은 PR 전에 상대에게 한 줄 알린다. → [workflow 4·5절](./docs/workflow.md#4-로컬-검증-pr-전-필수)

## Git

브랜치 `feat/JECT-123-login` · 커밋 `feat(JECT-123): 한글 요약` · PR `[JECT-123] 요약` · 기능 → `develop` squash(제목은 커밋 규칙으로) · `develop` → `main` merge. 자세히 [workflow 2절](./docs/workflow.md#2-브랜치에서-머지까지). `develop` 브랜치는 아직 없다.

## 아직 안 한 것

- Shorebird, Fastlane, 스토어 배포, 실기기 서명
- 토큰 갱신·세션 복원·WebView bridge, `shared/widgets`(Loading/Error/Empty), `core/error`
- 웹 서버 데이터 라이브러리(TanStack Query) 도입 여부, 웹 호스팅
- `develop` 브랜치, `docs/api/`, `docs/releases.md`
