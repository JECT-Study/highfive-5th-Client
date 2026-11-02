# highfive-5th-Client 작업 규칙

사람과 코딩 에이전트가 같이 보는 규칙이다. 이 파일은 "항상 지킬 것"만 짧게 담고, 자세한 내용은 `docs/`에 있다.

| 알고 싶은 것 | 문서 |
| --- | --- |
| 전체를 그림으로 한 번에 (처음 읽을 때) | [docs/overview.md](./docs/overview.md) |
| 일을 어떤 순서로 하나 (Jira → 브랜치 → 구현 순서 → 검증 → PR → 리뷰 → 릴리스) | [docs/workflow.md](./docs/workflow.md) |
| 앱 폴더에 어떤 파일이 들어가고 누가 누구를 import하나 | [docs/mobile-architecture.md](./docs/mobile-architecture.md) |
| 웹 폴더 구조·의존성·bridge·환경 | [docs/web-architecture.md](./docs/web-architecture.md) |
| 색·간격·글자 크기 값과 바꾸는 절차 | [docs/design-tokens.md](./docs/design-tokens.md) |
| PR 올리기 전·리뷰할 때 무엇을 왜 보나 ("누가 만들어도 같은 느낌"의 검사 항목) | [docs/pr-checklist.md](./docs/pr-checklist.md) |

## 저장소

```
apps/mobile/   Flutter 앱. 명령은 이 폴더에서 `fvm flutter ...`
apps/web/      React + TypeScript + Vite. 명령은 이 폴더에서 `pnpm ...`
docs/          규칙·계약·배포 기록. BE API 명세는 docs/api/ 에 둔다
.github/       PR 템플릿 (CI는 아직 없음)
```

- Flutter 버전은 `apps/mobile/.fvmrc`, Node는 `apps/web/.nvmrc`·`packageManager`로 고정한다. `fvm flutter`/`fvm dart`, `pnpm`만 쓴다. SDK·메이저 버전 업그레이드는 PR로 합의한다.
- 앱에만 영향 있는 변경은 웹을, 웹에만 영향 있는 변경은 앱을 건드리지 않는다. 앱↔웹 공통 계약(bridge·토큰)은 양쪽을 같이 바꾸고 양쪽 검증을 한다.

## 명령

| | 앱 (`apps/mobile`) | 웹 (`apps/web`) |
| --- | --- | --- |
| 설치 | `fvm install && fvm flutter pub get` | `corepack enable && pnpm install` |
| 실행 | `fvm flutter run --dart-define=FLAVOR=dev` | `pnpm dev` |
| 포맷 | `fvm dart format lib test` | `pnpm format` |
| 분석·린트 | `fvm flutter analyze` | `pnpm lint && pnpm typecheck` |
| 테스트 | `fvm flutter test` | `pnpm test` |
| 빌드 | `fvm flutter build apk\|ipa --dart-define=FLAVOR=prod` | `pnpm build` (prod) / `pnpm build:dev` |
| 코드 생성 | `fvm dart run build_runner build --delete-conflicting-outputs` | - |

PR 전에 포맷·분석·테스트(웹은 빌드까지)가 전부 통과해야 한다. 한글 경로에서 `flutter analyze`가 크래시하면 영문 경로에 복사해서 돌린다.

## 항상 지킬 것

구조

- feature-first. `features/<feature>/`에 모델·데이터·화면을 모은다. 실제 구현하는 기능부터 만들고 빈 폴더·UseCase·인터페이스를 미리 만들지 않는다.
- 의존성은 `app → features → core/shared` 한 방향. features는 app을 import하지 않고(웹은 `app/routes.ts`만 예외), 다른 기능의 화면·ViewModel·훅을 import하지 않는다. core·shared는 도메인을 모른다.
- 여러 기능에서 쓴다는 이유만으로 기능 코드를 core/shared로 옮기지 않는다.

앱 계층

- View는 표시·입력·이동만, ViewModel(Riverpod Notifier/AsyncNotifier)은 상태·명령, Repository는 변환·캐시·저장, Service는 HTTP·SDK 호출만.
- `getIt`은 `app/di.dart`(등록), `app/providers.dart`(앱 전역 연결 Provider), `presentation/providers/`(기능 연결 Provider)에서만. ViewModel은 get_it에 등록하지 않는다.
- 신청·예매·결제 같은 쓰기 명령은 Provider `build()`가 아니라 버튼 → ViewModel 메서드로 실행하고 중복 실행을 막는다. 권한·재고·가격은 서버가 최종 판단한다.
- 로그아웃·계정 전환 시 세션·Repository 캐시·소켓·보안 저장소를 정리하고 이전 세션의 늦은 응답은 버린다.
- 인증 정보는 `FlutterSecureStorage`에만. 토큰을 SharedPreferences·로그·URL·분석 이벤트에 넣지 않는다.

디자인

- 색·간격·모서리·글자 크기는 토큰만 쓴다 (앱 `context.colors`·`AppSpacing`·`AppRadius`·`textTheme`, 웹 `var(--color-*)` 등). hex·`Colors.*`·숫자 직접 사용 금지. 토큰은 앱·웹·문서를 한 PR에서 같이 바꾼다.

코드·테스트

- 모델은 freezed + json_serializable. `*.g.dart`·`*.freezed.dart`는 직접 수정하지 않고 생성 파일도 커밋한다.
- 환경값은 앱 `app/env.dart`, 웹 `shared/config/env.ts`에서만 읽는다. 라우트 경로는 앱 `AppRoutes`, 웹 `routes.ts`에만.
- 테스트는 앱은 `test/`에 `lib/`와 같은 경로, 웹은 파일 옆 `*.test.tsx`. 연결 Provider를 바꿔 끼우고 전역 getIt에 기대지 않는다. 문구를 고정하는 테스트, 고정 sleep으로 기다리는 테스트는 만들지 않는다.
- `any`, `// ignore:`, `eslint-disable`로 오류를 숨기지 않는다.

## Git·Jira

| 항목 | 규칙 |
| --- | --- |
| 브랜치 | `feat/JECT-123-login`, `fix/JECT-124-login-error` (type: feat / fix / chore / refactor / docs) |
| 커밋 | `feat(JECT-123): 로그인 기능 구현`. 본문은 "왜"만, 파일 나열 금지 |
| PR | `[JECT-123] 로그인 기능 구현`. 본문은 `.github/PULL_REQUEST_TEMPLATE.md`, 체크 항목은 `docs/pr-checklist.md` |
| 기능 머지 | 기능 브랜치 → `develop`, 상대 1명 리뷰 후 squash. squash 커밋 제목은 커밋 규칙으로 고친다 |
| 릴리스 | `develop` → `main`, 이력 유지하는 merge |
| 긴급 수정 | `main`에서 fix 브랜치 → PR로 main 반영 → develop에도 반영 |
| 사전 공유 | DI·공유 모델·라우팅·네이티브·bridge·토큰·pubspec/package.json 변경은 PR 전에 한 줄 알림 |

`JECT-123`은 예시다. `develop` 브랜치는 아직 없으므로 첫 기능 작업 전에 만든다.

## 아직 안 한 것

- 네이티브 flavor(앱 ID·이름 분리), Shorebird, Fastlane, GitHub Actions
- 토큰 갱신·세션 복원·WebView bridge, `shared/widgets`(Loading/Error/Empty), `core/error`
- 웹 서버 데이터 라이브러리(TanStack Query) 도입 여부, 웹 호스팅
- `develop` 브랜치, `docs/api/`, `docs/releases.md`
