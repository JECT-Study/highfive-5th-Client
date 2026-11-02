# highfive-5th-Client 작업 규칙

사람과 코딩 에이전트가 같이 보는 규칙이다. 설계 결정의 배경은 팀 아키텍처 문서를 따르고, 여기에는 코드를 쓸 때 지킬 것만 적는다.

## 저장소

```
apps/mobile/   Flutter 앱. flutter 명령은 이 폴더에서 `fvm flutter ...`로 실행
apps/web/      React + TypeScript + Vite (아직 없음)
docs/          API·앱↔웹 계약·배포 절차 (아직 없음)
```

- Flutter 버전은 `apps/mobile/.fvmrc`로 고정한다. `fvm install` 후 `fvm flutter`, `fvm dart`만 쓴다. SDK 업그레이드는 PR로 합의한다.
- 앱에만 영향 있는 변경은 웹을, 웹에만 영향 있는 변경은 앱을 건드리지 않는다. 앱↔웹 공통 계약은 양쪽을 검증한다.

## 명령 (apps/mobile 에서)

| 할 일 | 명령 |
| --- | --- |
| 의존성 | `fvm flutter pub get` |
| 실행 | `fvm flutter run --dart-define=FLAVOR=dev` (`prod`도 가능, 생략 시 dev) |
| 테스트 | `fvm flutter test` |
| 분석 | `fvm flutter analyze` |
| 포맷 | `fvm dart format lib test` |
| 코드 생성 | `fvm dart run build_runner build --delete-conflicting-outputs` |

PR 전에 포맷·분석·테스트가 모두 통과해야 한다. 경로에 한글이 있으면 `flutter analyze`가 크래시할 수 있다(analysis server 버그). 그럴 때는 영문 경로에 복사해서 돌린다.

## 폴더 (apps/mobile/lib)

```
main.dart                 진입. AppEnv 결정 → setupDi → ProviderScope로 앱 시작
app/                      초기화·DI·환경·라우팅
  app.dart                MaterialApp.router, dev 배너
  di.dart                 get_it 등록 (setupDi)
  env.dart                Flavor, AppEnv
  providers.dart          get_it → Riverpod 연결 Provider
  router.dart             AppRoutes 경로 상수 + routerProvider
core/                     기술 기반: 네트워크·오류·저장소·SDK·WebView
  network/dio_client.dart
shared/                   공통 UI·디자인 토큰
  theme/app_theme.dart
features/<feature>/       기능 단위
  models/                 도메인 모델 (freezed)
  data/                   dto/ services/ repositories/
  presentation/           providers/ view_models/ views/ widgets/
```

기능 이름: `auth`, `bands`, `performances`, `recruitments`, `venues`, `ticketing`, `payments`, `settlements`, `chat`.

- 실제 구현하는 기능부터 만든다. 빈 폴더·UseCase·인터페이스를 미리 만들지 않는다. 지금은 `features/auth`에 로그인 화면 자리만 있다.
- 기능 안의 하위 폴더도 필요한 것만 만든다.
- 여러 기능에서 쓴다는 이유만으로 core/shared로 옮기지 않는다. core는 기술 기반, shared는 공통 UI.
- 다른 기능의 View·ViewModel을 import하지 않는다. 기능 간 데이터는 Repository·모델 계약으로만 주고받고 순환 의존을 만들지 않는다.
- 협업 단위(페이지·API Task)와 코드 배치는 별개다. 페이지 단위로 나눠 작업해도 폴더는 feature-first를 유지한다.

## 계층 책임

```
View ── 사용자 명령 ──→ ViewModel ──→ Repository ──→ Service ──→ 서버/SDK
  ↑                      │
  └── Riverpod 상태 구독 ──┘
```

| 역할 | 담당 | 하지 않는 것 |
| --- | --- | --- |
| View | 표시·입력·화면 이동 | HTTP 호출, 권한·재고·상태 판단 |
| ViewModel | 상태·사용자 명령. Riverpod `Notifier`/`AsyncNotifier` | 위젯 import, getIt 직접 조회 |
| Repository | 모델 변환·저장·캐시·데이터 처리 | 위젯·Riverpod 의존 |
| Service | HTTP(Dio)·소켓·SDK 호출 | 모델 변환, 캐시 |
| get_it | Service·Repository 등 공유 객체 생성·연결 | ViewModel 등록 |

권한·재고·가격·마감은 서버가 최종 판단한다. 화면에서 버튼을 숨기는 것으로 확정하지 않는다.

## DI와 상태

- `getIt`은 `app/di.dart`(등록)와 `app/providers.dart`(연결 Provider)에서만 조회한다. 그 외 코드는 연결 Provider를 `ref.watch/read` 한다.
- ViewModel은 Riverpod만 관리한다. get_it에 중복 등록하지 않는다.
- 상태 범위: 입력값은 위젯 로컬 상태, 로그인 세션은 앱 공통 Provider, 상세 조회는 `.family`로 ID별 상태.
- 신청·예매·결제처럼 결과가 남는 명령은 Provider의 `build()`에서 실행하지 않는다. 버튼 → ViewModel 메서드로 명시적으로 실행하고 ViewModel에서 중복 실행을 막는다. 서버 멱등성 키 계약이 있으면 따르고, 타임아웃은 실패 확정이 아니므로 기존 결과를 먼저 조회한다.
- 로그아웃·계정 전환 시 사용자 상태·Repository 캐시·소켓·보안 저장소를 정리한다. Riverpod 초기화만으로 Repository 캐시가 정리됐다고 가정하지 않는다. 이전 세션 요청의 늦은 응답은 버린다.
- 테스트는 `ProviderScope(overrides: [...])`로 연결 Provider를 바꿔 끼운다. 전역 getIt 등록에 기대지 않는다. `test/app/app_test.dart`가 예다.

연결 Provider와 ViewModel 모양:

```dart
// app/providers.dart
final authRepositoryProvider =
    Provider<AuthRepository>((ref) => getIt<AuthRepository>());

// features/auth/presentation/view_models/login_view_model.dart
class LoginViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> login(String email, String password) async {
    if (state.isLoading) return; // 중복 실행 방지
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(email, password),
    );
  }
}

final loginViewModelProvider =
    AsyncNotifierProvider<LoginViewModel, void>(LoginViewModel.new);
```

## 환경과 저장

- `--dart-define=FLAVOR=dev|prod`로 `AppEnv`를 만든다. 생략하면 dev. API 주소 등 환경값은 `app/env.dart`에만 둔다.
- dev 빌드는 release 모드로도 배포하므로 화면 왼쪽 위에 `DEV` 배너가 붙는다.
- 네이티브 flavor(앱 ID·이름 분리, 두 앱 동시 설치)는 아직 없다. 추가할 때 Android `productFlavors`와 iOS scheme·xcconfig를 같이 만든다.
- 인증 정보는 `FlutterSecureStorage`에만 저장한다. `SharedPreferencesAsync`·로그·URL·분석 이벤트에 넣지 않는다. 디버그 로그 인터셉터는 헤더를 남기지 않는다.

## 모델과 코드 생성

- 모델은 `freezed` + `json_serializable`. DTO(서버 응답)와 도메인 모델을 구분하고 변환은 Repository에서 한다.
- `*.freezed.dart`, `*.g.dart`는 직접 수정하지 않는다. 모델을 바꾸면 build_runner를 돌리고 생성 파일도 함께 커밋한다(CI가 build_runner 없이 분석·테스트).
- `pubspec.yaml`의 SDK 제약과 패키지 메이저 버전 변경은 PR에서 따로 알린다.

## 이름

- 파일은 snake_case, 접미사로 역할을 드러낸다: `login_view.dart`, `login_view_model.dart`, `auth_repository.dart`, `auth_service.dart`, `login_request_dto.dart`.
- Provider 변수는 `xxxProvider`. 라우트 경로 문자열은 `AppRoutes`에만 둔다.
- 테스트는 `test/`에 `lib/`와 같은 경로. 순수 로직은 단위 테스트, 화면은 위젯 테스트. 문구를 고정하는 테스트는 만들지 않는다.

## Git·Jira

| 항목 | 규칙 |
| --- | --- |
| 브랜치 | `feat/JECT-123-login`, `fix/JECT-124-login-error` (type: feat / fix / chore / refactor / docs) |
| 커밋 | `feat(JECT-123): 로그인 기능 구현`. 본문은 "왜"만, 파일 나열 금지 |
| PR | `[JECT-123] 로그인 기능 구현`. 본문: 변경 / 검증 / UI 캡처 / 호환성 |
| 기능 머지 | 기능 브랜치 → `develop`, 상대 1명 리뷰 후 squash |
| 릴리스 | `develop` → `main`, 이력 유지하는 merge |
| 긴급 수정 | `main`에서 fix 브랜치 → PR로 main 반영 → develop에도 반영 |
| 공통 변경 | DI·모델·라우팅·네이티브·bridge는 사전 공유 후 상대 리뷰 |

`JECT-123`은 예시다. `develop` 브랜치는 아직 없으므로 첫 기능 작업 전에 만든다.

## 아직 안 한 것

- 네이티브 flavor, Shorebird, Fastlane, GitHub Actions
- 토큰 갱신(동시 401은 한 번만 갱신)·세션 복원·WebView bridge
- `develop` 브랜치, `apps/web`, `docs/`
