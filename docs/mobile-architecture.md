# 앱 구조 (apps/mobile)

feature-first + 가벼운 MVVM + Riverpod. 이 문서는 "어떤 파일이 어디에 들어가고, 누가 누구를 import할 수 있는가"를 정한다.
작업 순서는 [workflow.md](./workflow.md), 토큰 값은 [design-tokens.md](./design-tokens.md).

## 1. 폴더와 들어가는 파일

`(있음)`은 지금 존재하는 파일, 나머지는 해당 기능을 만들 때 생긴다. 빈 폴더를 미리 만들지 않는다.

```
lib/
├── main.dart                        (있음) AppEnv 결정 → setupDi → ProviderScope(HighfiveApp)
│
├── app/                             앱 전체를 묶는 것만. 기능 로직 금지
│   ├── app.dart                     (있음) MaterialApp.router, 테마, dev 배너
│   ├── di.dart                      (있음) setupDi: get_it 등록. Service·Repository는 여기에 추가
│   ├── env.dart                     (있음) Flavor, AppEnv(apiBaseUrl 등 환경값)
│   ├── providers.dart               (있음) 앱 전역 연결 Provider (appEnvProvider)
│   ├── main_shell.dart              (있음) 하단 탭 4개 화면 (StatefulShellRoute). 탭 바 모양은 shared/widgets/app_bottom_nav_bar.dart
│   ├── routes.dart                  (있음) AppRoutes 경로 상수만 (11절 지도)
│   └── router.dart                  (있음) routerProvider, GoRoute 등록. 인증 redirect는 여기
│
├── core/                            기술 기반. 도메인(공연·예매)을 모른다
│   ├── di/locator.dart              (있음) getIt 인스턴스
│   ├── network/
│   │   ├── dio_client.dart          (있음) createDio: baseUrl·timeout·디버그 로그
│   │   ├── auth_interceptor.dart    (있음) 토큰 첨부, AUTH_002 → 한 번만 재발급 후 재시도, AUTH_001·003·004 → SessionExpiry
│   │   ├── session_expiry.dart      (있음) 서버가 세션을 끝냈다는 알림. 세션 ViewModel이 듣고 로그아웃
│   │   ├── api_log_interceptor.dart (있음) 디버그 요청·응답 로그 (토큰 값 가림)
│   │   └── api_error_mapper.dart    (있음) DioException → AppException 변환 (서버 본문의 code를 담는다)
│   ├── error/app_exception.dart     (있음) sealed class: NetworkException / ApiException(statusCode, code) / UnknownApiException
│   ├── storage/
│   │   ├── secure_store.dart        (있음) FlutterSecureStorage 래퍼 + 키 상수 (토큰)
│   │   └── prefs_store.dart         SharedPreferencesAsync 래퍼 + 키 상수 (설정)
│   ├── sdk/                         소셜 로그인·지도·푸시·QR 스캔 SDK 래퍼 (각 1파일)
│   └── webview/app_bridge.dart      웹 → 앱 명령 수신·검증 (출처·명령·버전)
│
├── shared/                          공통 UI. 도메인 모델·데이터를 모른다 (값만 받아 그린다)
│   ├── theme/
│   │   ├── app_colors.dart          (있음) 색 토큰 (ThemeExtension), context.colors
│   │   ├── app_spacing.dart         (있음) 간격 토큰
│   │   ├── app_radius.dart          (있음) 모서리 토큰
│   │   ├── app_typography.dart      (있음) 글자 크기 토큰 → TextTheme
│   │   ├── app_shadows.dart         (있음) 그림자 토큰
│   │   ├── app_component_tokens.dart (있음) Button·Input·Chip·Tag 크기·여백 (shared/widgets 안에서만)
│   │   └── app_theme.dart           (있음) 토큰을 ThemeData로 묶음
│   ├── widgets/                     (있음) app_icon.dart: Figma 아이콘(assets/icons/) SVG
│   │                                (있음) app_button, app_text_field, app_text_area, app_dropdown, app_chip(+Filter),
│   │                                app_tag, app_selection_controls(Checkbox·Radio·Toggle), app_notice, app_dialog,
│   │                                app_bottom_sheet, app_list_row, app_tab_list, app_top_bar, app_badge(+Divider),
│   │                                app_progress_bar, app_stepper, app_form_section:
│   │                                Figma 공통 컴포넌트 (docs/design-tokens.md 컴포넌트 표)
│   │   ├── message/                 (있음) Figma '메시지' 섹션: 말풍선, 채팅 목록 항목, 입력 바 등
│   │   ├── show/                    (있음) Figma '공연페이지' 섹션: 라인업, 진행 카드, 피드, 일정, 입금확인, 팝업 등
│   │   ├── home/                    (있음) Figma '홈' 섹션: 공연 카드, 홈 목록 등
│   │   ├── onboarding/              (있음) Figma '온보딩' 섹션
│   │   ├── list/                    (있음) Figma '목록' 섹션: 목록 카드, 알림 줄
│   │   └── qr/                      (있음) Figma 'QR' 섹션
│   │                                loading_view.dart, error_view.dart, empty_view.dart
│   ├── utils/                       date_format.dart, money_format.dart 같은 순수 함수
│   └── extensions/                  context_extensions.dart 등
│
└── features/
    └── <feature>/                   auth · bands · performances · recruitments · venues
        │                            · ticketing · payments · settlements · chat
        ├── models/                  도메인 모델. 화면이 쓰는 모양
        │   ├── performance.dart           freezed 클래스
        │   └── performance_status.dart    enum
        ├── data/
        │   ├── dto/                 서버 응답·요청 모양 (json_serializable) + toModel()
        │   │   └── performance_dto.dart
        │   ├── services/            Dio 호출만. DTO를 돌려준다
        │   │   └── performance_service.dart
        │   └── repositories/        DTO→모델, 캐시, 저장. 다른 기능이 쓰는 계약
        │       └── performance_repository.dart
        └── presentation/
            ├── providers/           연결 Provider (getIt → Riverpod), family 조회 Provider
            │   └── performance_providers.dart
            ├── view_models/         Notifier / AsyncNotifier
            │   └── performance_detail_view_model.dart
            ├── views/               라우트 단위 화면 (Scaffold 하나)
            │   └── performance_detail_view.dart
            └── widgets/             이 기능 안에서만 쓰는 조각 위젯
                └── performance_poster.dart
```

- 파일 하나면 폴더를 만들지 않아도 된다. 둘 이상 되면 위 구조대로 나눈다.
- `core`와 `shared`의 차이: core는 "어떻게 통신·저장하는가", shared는 "어떻게 보이는가". 둘 다 도메인 모델·Repository·Provider를 모른다.
- `shared/widgets`에는 Figma 컴포넌트를 **값만 받아 그리는 표시용 위젯**으로 둔다. 버튼·입력창 같은 범용 위젯은 바로 아래에(`app_*.dart`), 특정 화면 영역의 위젯(말풍선, 공연 카드 등)은 Figma 섹션 이름의 하위 폴더(`message/`, `show/`, `home/` …)에 둔다. 여러 화면·기능이 같이 쓴다.
  - 생성자는 글자·숫자·bool·enum·`ImageProvider`·`Widget` 슬롯·콜백만 받는다. 모델을 받지 않고, Provider를 읽지 않고, 화면 이동·요청을 하지 않는다.
  - 모델을 위젯 값으로 풀어 넣고, 누르면 무엇을 할지 정하는 일은 기능의 View·ViewModel이 한다.
  - 영역 폴더는 화면보다 먼저 만들어 둔 Figma 섹션별 위젯이다(AGENTS.md 1번의 예외, 이유는 design-tokens "영역별 컴포넌트"). 값만 받아 그리고 어느 기능에서든 쓴다. 화면을 만들 때 Figma와 다시 맞춘다. dev 빌드의 `/dev/widgets`에서 폴더별로 볼 수 있다.
- 데이터·상태·규칙이 들어간 코드는 여러 기능에서 쓴다는 이유만으로 core/shared로 옮기지 않는다. 다른 기능이 필요하면 그 기능의 Repository·모델을 import한다. 한 기능의 데이터에 묶인 조각 위젯은 그 기능의 `presentation/widgets`에 둔다.

## 2. 의존성 방향

```
main.dart ─► app ─► features ─► core
              │        │
              └──────► shared ──(드물게)──► core
```

| import 하는 쪽 \ 되는 쪽 | app | features | core | shared |
| --- | --- | --- | --- | --- |
| **app** | - | O (router가 View, di가 Service·Repository) | O | O |
| **features** | **X** | 같은 기능 안 O / 다른 기능은 `data/repositories`·`models`만 | O | O |
| **core** | X | X | - | X |
| **shared** | X | X | 드물게 (오류 타입 표시 등) | - |

기능 안에서는 아래로만 간다:

```
presentation/views ──► widgets, view_models, providers, models
presentation/view_models ──► providers(연결), data/repositories, models
data/repositories ──► data/services, data/dto, models, core
data/services ──► data/dto, core/network
models ──► 패키지만 (flutter 포함 안 함)
```

이 규칙은 `fvm dart run tool/check_imports.dart`가 검사한다(CI에서도 돌아감). 위반이면 파일·줄·이유를 출력하고 종료 코드 1로 끝난다.

왜: 아래층이 위층을 모르면 아래층만 따로 테스트하고 교체할 수 있다. `features → app`을 막는 이유는 순환(app이 features를 import하므로)과, 기능이 앱 전체 설정에 기대는 것을 막기 위해서다. 기능이 환경값이 필요하면 Service·Repository가 생성자로 받는다.

## 3. 계층 책임

```
View ── 사용자 명령 ──► ViewModel ──► Repository ──► Service ──► 서버/SDK
  ▲                      │
  └── Riverpod 상태 구독 ─┘
```

| 역할 | 한다 | 하지 않는다 |
| --- | --- | --- |
| View | 표시, 입력 받기, `context.go`, ViewModel 메서드 호출 | HTTP 호출, 권한·재고·가격 판단, 비즈니스 분기 |
| ViewModel | 상태 보유, 사용자 명령 실행, 중복 실행 방지, 오류를 상태로 변환 | 위젯·BuildContext import, getIt 조회 |
| Repository | DTO→모델, 메모리 캐시, 저장소 읽기·쓰기, 세션 정리 | 위젯·Riverpod 의존 |
| Service | Dio·소켓·SDK 호출, DTO 반환 | 모델 변환, 캐시, 재시도 정책 |
| get_it | Service·Repository 생성과 연결 | ViewModel 등록 |

권한·재고·가격·마감은 서버가 최종 판단한다. 버튼을 숨기는 것으로 확정하지 않는다.

## 4. 상태를 어디에 두는가

| 상태 | 위치 | 예 |
| --- | --- | --- |
| 입력 중인 값 | 위젯 로컬 (`TextEditingController`, `StatefulWidget`) | 로그인 폼, 검색어 |
| 화면 하나의 비동기 상태 | `AsyncNotifier`, `autoDispose` | 공연 상세 로딩·실패 |
| ID별 상태 | `.family` | 공연 ID별 상세 |
| 앱 공통 | `keepAlive` Provider | 세션(로그인 사용자) |
| 서버 데이터 캐시 | Repository 메모리 | 공연 목록 |
| 영속 | `core/storage` (인증은 secure, 설정은 prefs) | 토큰, 마지막 본 탭 |

- 결과가 남는 명령(신청·예매·결제·입금 확인)은 Provider `build()`에서 실행하지 않는다. 버튼 → ViewModel 메서드. ViewModel은 `state.isLoading`이면 무시한다. 서버 멱등성 키가 있으면 같은 작업에 같은 키를 쓴다. 타임아웃은 실패 확정이 아니므로 결과를 먼저 조회한다.
- 로그아웃·계정 전환: 세션 Provider 초기화 → Repository 캐시·소켓 정리 → secure storage 삭제. 이전 세션 요청의 늦은 응답은 세션 ID를 비교해 버린다. Riverpod 초기화만으로 Repository 캐시가 사라졌다고 가정하지 않는다.

## 5. 흐름 예시: 공연 상세

```dart
// features/performances/models/performance.dart
@freezed
abstract class Performance with _$Performance {
  const factory Performance({
    required String id,
    required String title,
    required DateTime startsAt,
    required PerformanceStatus status,
    String? posterUrl,
  }) = _Performance;
}

// features/performances/data/dto/performance_dto.dart
@JsonSerializable()
class PerformanceDto {
  // ...fromJson / toJson
  Performance toModel() => Performance(id: id, title: title, ...);
}

// features/performances/data/services/performance_service.dart
class PerformanceService {
  PerformanceService(this._dio);
  final Dio _dio;

  Future<PerformanceDto> fetch(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/performances/$id');
    return PerformanceDto.fromJson(res.data!);
  }
}

// features/performances/data/repositories/performance_repository.dart
class PerformanceRepository {
  PerformanceRepository(this._service);
  final PerformanceService _service;
  final _cache = <String, Performance>{};

  Future<Performance> get(String id) async {
    final model = (await _service.fetch(id)).toModel();
    _cache[id] = model;
    return model;
  }

  void clear() => _cache.clear(); // 로그아웃 시 호출
}

// app/di.dart (등록)
getIt
  ..registerLazySingleton(() => PerformanceService(getIt<Dio>()))
  ..registerLazySingleton(() => PerformanceRepository(getIt<PerformanceService>()));

// features/performances/presentation/providers/performance_providers.dart (연결)
final performanceRepositoryProvider =
    Provider<PerformanceRepository>((ref) => getIt<PerformanceRepository>());

// features/performances/presentation/view_models/performance_detail_view_model.dart
final performanceDetailProvider = AsyncNotifierProvider.autoDispose
    .family<PerformanceDetailViewModel, Performance, String>(PerformanceDetailViewModel.new);

class PerformanceDetailViewModel extends AsyncNotifier<Performance> {
  PerformanceDetailViewModel(this.id);
  final String id;

  @override
  Future<Performance> build() => ref.read(performanceRepositoryProvider).get(id);
}

// features/performances/presentation/views/performance_detail_view.dart
class PerformanceDetailView extends ConsumerWidget {
  const PerformanceDetailView({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(performanceDetailProvider(id));
    return Scaffold(
      body: state.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(performanceDetailProvider(id))),
        data: (p) => _Body(performance: p),
      ),
    );
  }
}
```

테스트에서는 `ProviderScope(overrides: [performanceRepositoryProvider.overrideWithValue(fakeRepo)])`로 바꿔 끼운다. getIt에는 아무것도 등록하지 않는다.

## 6. 오류 처리

```
Service(DioException) ─► core/network/api_error_mapper ─► AppException
      ─► Repository(통과) ─► ViewModel(AsyncValue.guard → AsyncError) ─► View(ErrorView)
```

- `AppException`은 `core/error/app_exception.dart`의 sealed class. 서버 오류는 `ApiException`에 HTTP 상태와 서버 오류 코드(예: `AUTH_006`)를 담는다. 기능의 Repository가 코드를 그 기능의 실패 이유로 바꾸고(예: `AuthRepository` → `LoginFailureReason`), 화면은 이유별로 문구·행동(재시도, 로그인 이동)을 정한다. 코드별 처리는 `docs/api/`의 명세에 적는다.
- View는 `AsyncValue.when`으로 로딩·오류·빈 결과를 반드시 그린다. `shared/widgets`의 `LoadingView`·`ErrorView`·`EmptyView`를 쓴다(첫 화면 만들 때 생성).
- 네트워크 단절·5xx로 로그아웃하지 않는다. `unauthorized`(갱신 실패)만 세션을 정리한다.

## 7. 하면 안 되는 것

- View에서 Dio·Repository·getIt 직접 호출
- ViewModel에서 `BuildContext`·위젯·`Navigator` 사용
- `getIt<...>()`을 `app/di.dart`, `app/providers.dart`, `presentation/providers/` 밖에서 호출
- ViewModel을 get_it에 등록
- Provider `build()`에서 신청·예매·결제 같은 쓰기 요청
- 다른 기능의 `presentation/` import (View·ViewModel·widgets·providers)
- `Colors.*`, hex, 숫자 패딩·폰트 크기 직접 사용 — 토큰만 (`context.colors`, `AppSpacing`, `context.textStyles`)
- `*.g.dart`·`*.freezed.dart` 수정
- 토큰·개인정보를 SharedPreferences·로그·URL·분석 이벤트에 넣기
- 문구를 고정하는 테스트, 생성 파일 테스트
- 빈 폴더·미래용 인터페이스·UseCase 미리 만들기
- "공통이니까" 기능 코드를 core/shared로 옮기기

## 8. 테스트 배치

`test/`는 `lib/`와 같은 경로. `lib/features/performances/data/repositories/performance_repository.dart` → `test/features/performances/data/repositories/performance_repository_test.dart`.

| 대상 | 방법 | 꼭 넣는 경우 |
| --- | --- | --- |
| DTO | `fromJson` 샘플 JSON | 선택값·enum·날짜 |
| Repository | Fake Service 주입 | 변환, 캐시, 정리 |
| ViewModel | `ProviderContainer` + overrides | 로딩·성공·실패·중복 실행 |
| View | `ProviderScope` overrides + `pumpWidget` | 로딩·빈 결과·실패·정상 |

비동기는 완료 신호를 기다린다(`pumpAndSettle`, `await future`). 고정 `sleep`으로 기다리지 않는다.

## 9. 이름

| 대상 | 규칙 | 예 |
| --- | --- | --- |
| 파일 | snake_case + 역할 접미사 | `login_view.dart`, `login_view_model.dart`, `auth_repository.dart`, `auth_service.dart`, `login_request_dto.dart` |
| 클래스 | 파일명의 PascalCase | `LoginViewModel` |
| Provider | `xxxProvider` | `sessionProvider`, `performanceDetailProvider` |
| 라우트 경로 | `AppRoutes`에만 | `AppRoutes.show`, `AppRoutes.showOf(id)` |
| 테스트 | `<파일>_test.dart`, 테스트명은 한국어 문장 | `'중복 탭은 한 번만 요청한다'` |

## 10. 환경(flavor)

dev와 prod는 네이티브 flavor로 나눈다. 앱 ID가 달라서 두 앱이 한 기기에 같이 설치된다.

| | dev | prod |
| --- | --- | --- |
| 실행 | `fvm flutter run --flavor dev` | `fvm flutter run --flavor prod` |
| 빌드 | `fvm flutter build apk\|ipa --flavor dev` | `fvm flutter build apk\|ipa --flavor prod` |
| 앱 ID (Android `applicationId`, iOS bundle id) | `com.ject.highfive.dev` | `com.ject.highfive` |
| 홈 화면 이름 | `highfive DEV` | `highfive` |
| 환경값 (`app/env.dart`) | `Flavor.dev`: dev API 주소 | `Flavor.prod`: prod API 주소 |
| 화면 | 왼쪽 위 `DEV` 배너 | 배너 없음 |
| 카카오 네이티브 앱 키 | Dev 키 (`8f7351ff…`) | Default 키 (`68320ddf…`) |
| Google iOS 클라이언트 ID | `620350281095-0h5cs8o8…` | `620350281095-gadtuaqo…` |
| Google 서버(웹) 클라이언트 ID | `620350281095-d3ubpmrm…` (같음) | 같음 |

- 값이 정해지는 순서: `--flavor dev`를 주면 Flutter가 `FLUTTER_APP_FLAVOR=dev`를 넣고, `AppEnv.fromEnvironment()`가 그 값을 먼저 읽는다. 없으면 `--dart-define=FLAVOR`(flavor 없이 도는 테스트·도구용)를, 그것도 없으면 dev를 쓴다. 모르는 값이면 시작할 때 바로 실패한다.
- 설정 위치: Android는 `android/app/build.gradle.kts`의 `productFlavors`다. 앱 이름은 `resValue("string", "app_name", ...)`로 넣고, AGP 9는 이 기능이 기본으로 꺼져 있어 `buildFeatures.resValues = true`가 필요하다. iOS는 빌드 구성 `Debug-dev`·`Release-dev`·`Profile-dev`(prod도 같은 셋)와 공유 스킴 `dev`·`prod`다. Flutter는 스킴 이름이 flavor 이름과 같아야 찾는다. iOS 앱 이름은 빌드 설정 `APP_DISPLAY_NAME`이 `Info.plist`의 `CFBundleDisplayName`으로 들어간다.
- 카카오 네이티브 앱 키는 한 카카오 앱의 키 두 개다(dev → Dev, prod → Default). Android 키 해시도 같은 키에 등록한다. 같은 값이 세 곳에 있어 바꿀 때 셋 다 바꾼다: `lib/app/env.dart`(`KakaoSdk.init`), iOS 빌드 설정 `KAKAO_NATIVE_APP_KEY`(`Info.plist`의 URL 스킴 `kakao$(KAKAO_NATIVE_APP_KEY)`), Android `build.gradle.kts`의 `manifestPlaceholders["kakaoNativeAppKey"]`(`AndroidManifest.xml`의 리다이렉트 스킴).
- Google 로그인: iOS 클라이언트 ID는 `lib/app/env.dart`(`googleIosClientId`)와 iOS 빌드 설정 `GOOGLE_REVERSED_CLIENT_ID`(뒤집은 값, `Info.plist` URL 스킴) 두 곳에 있다. Android는 코드에 ID가 없고 Google Cloud 콘솔의 Android 클라이언트(패키지명 + SHA-1)로 알아본다. 그래서 서명 키가 늘면(다른 개발자 Mac의 debug 키, release 키, Play 앱 서명 키) 그 SHA-1로 Android 클라이언트를 추가해야 한다. 서버(웹) 클라이언트 ID는 ID 토큰의 대상이고 BE가 검증에 쓴다.
- **명령에는 항상 `--flavor`를 붙인다.** Android는 flavor 없이 빌드하면 `Gradle build failed to produce an .apk file` 오류로 실패한다. iOS는 원래 `Runner` 스킴이 남아 있어 flavor 없이도 빌드되지만, 결과는 prod 앱 ID에 dev 환경(DEV 배너·dev API)이 섞인 앱이다. 이 빌드는 배포에 쓰지 않는다.
- Xcode에서 직접 빌드할 때 Dart 쪽 flavor는 빌드 구성 이름에서 정해진다. `Debug-dev`처럼 `-` 뒤 이름이 스킴 이름과 같으면 그 flavor를 쓴다(flutter_tools `parseFlavorFromConfiguration`). 그래서 `dev`·`prod` 스킴을 고르면 맞게 들어간다. `Runner` 스킴(구성 `Debug`)은 구성 이름에 flavor가 없어서 마지막 `fvm flutter` 명령이 `ios/Flutter/Generated.xcconfig`에 남긴 `FLAVOR` 값을 쓴다. 그러니 Xcode에서는 `Runner` 스킴으로 빌드하지 않는다.
- CocoaPods를 쓰게 되면 `ios/Podfile`의 `project 'Runner', {...}`에 새 구성 6개를 매핑해야 한다(`Debug-dev`는 `:debug`, `Release-dev`·`Profile-dev`는 `:release`, prod도 같게). 각 구성의 Pods xcconfig도 include해야 한다. 지금은 SwiftPM을 써서 Podfile이 없다.

## 11. 화면 이동 경로

Figma `와이어프레임 New` → `11/8 pm 확정 영역: 티켓 신청 전까지` 기준으로 정한 지도다. 경로 상수는 `app/routes.dart`의 `AppRoutes`에 미리 두고, `GoRoute`는 그 화면을 만드는 PR에서 `app/router.dart`에 등록한다(빈 화면을 미리 만들지 않는다). 바꿀 때는 이 표와 `AppRoutes`를 같은 PR에서 고친다.

- 하단 탭 4개: 홈 · 팀 모집 · 메시지 · 마이페이지 (`app/main_shell.dart`). `StatefulShellRoute.indexedStack`이라 탭을 바꿔도 각 탭의 스택·스크롤이 남는다. 지금 탭을 다시 누르면 그 탭 첫 화면으로 간다. 탭 안에서 이어지는 화면은 해당 branch 아래에 등록한다.
- 하단 탭 라벨·아이콘: Figma 화면마다 라벨이 달라(채팅/메세지/티켓 관리, 내 프로필/마이페이지) 기능명세(기능 53) 기준으로 정했다. 아이콘은 Figma Icon 컴포넌트(Icon: home, search, message, Icon:my). 크기·간격·색은 Figma NavEX 그대로(아이콘 24, 라벨 선택 Caption-1(SB)/아니면 Caption-1(R), 아이콘-라벨 간격 2, 눌림 효과 없음). 크기·간격은 컴포넌트 토큰 `AppBottomNavTokens`, 그리는 위젯은 `AppBottomNavBar`(shared), 탭 목록은 `MainShell.tabs`. 색은 토큰: 선택 아이콘 `gray800`(Figma 아이콘 기본색)·라벨 `labelStrong`, 선택 안 됨 `interactionInactive`, 구분선 `lineNeutral`. 글꼴은 Pretendard.
- 화면 안의 탭(공연 페이지의 정보·피드·일정·티켓 관리, 메시지함의 전체·받은 문의·보낸 문의·공연 채팅, 마이의 내 공연·찜한 공연)은 경로를 나누지 않고 화면 상태로 둔다.
- 팝업·바텀시트·토스트·확인창은 경로가 아니다. 띄운 화면의 ViewModel이 연다.
- 고정 하위 경로(`/recruit/new`, `/recruit/search`, `/shows/new`)는 `:id` 경로보다 먼저 등록한다. 아니면 `new`가 id로 잡힌다.
- `/dev/widgets`(공통 위젯 모음)는 dev flavor 라우터에만 등록한다. 왼쪽 위 DEV 띠를 길게 누르거나 `fvm flutter run --flavor dev --route /dev/widgets`로 연다. 위쪽 칩으로 폴더(범용 · message · show · qr · home · onboarding · list)를 고르고, `--route "/dev/widgets?folder=message"`처럼 폴더를 바로 열 수도 있다. 화면은 `features/dev_gallery/`. 로그인 redirect(`sessionRedirect`)에서 제외해 로그아웃 상태에서도 열린다.
- 로그인 전 화면 외에는 전부 로그인 필요. 인증 redirect는 `routerProvider`의 `sessionRedirect`: 앱 시작 → `/splash`에서 저장된 세션(`sessionProvider`, secure storage) 복원 → 세션 있으면 `/home`, 없거나 복원 실패면 `/login`. 로그아웃하면 `/login`. 온보딩 미완료 → 온보딩 분기는 온보딩 정보를 받을 때 추가한다.
- 지금 로그인은 임시다: 로그인 화면의 "임시 로그인" 버튼이 `AuthService`의 고정 토큰으로 세션을 만든다. 로그인 API가 나오면 `features/auth/data/services/auth_service.dart`만 실제 호출로 바꾸고 버튼을 소셜 로그인으로 교체한다. 로그아웃은 마이페이지 버튼 → 라우터가 넘긴 `onSignOut` → `sessionProvider.signOut()` (설정 화면이 생기면 그쪽으로 옮긴다).

### 로그인 전

| 경로 | 화면 | Figma 프레임 |
| --- | --- | --- |
| `/splash` | 저장된 세션을 읽는 동안 잠깐 (빈 화면) | - |
| `/login` | 로그인 (소셜 로그인 버튼) | 약관 동의 (1117:7761) |
| `/terms` | 약관 동의 | 약관 동의 카카오 |
| `/signup` | 회원가입 | 계정-회원가입 |
| `/onboarding/profile` | 프로필 정보 입력 | 온보딩-프로필정보 입력1 |
| `/onboarding/band/new` | 새 밴드 만들기 (밴드 정보 입력 1·2단계) | 온보딩-계정생성-새밴드만들기, 온보딩-밴드정보 입력1·2 |
| `/onboarding/band/join` | 코드로 밴드 합류 | 온보딩-계정생성-코드로합류, 온보딩-코드합류-밴드확인 |

### 하단 탭

| 경로 | 화면 | Figma 프레임 |
| --- | --- | --- |
| `/home` | 홈 (공연 없음·판매 전·판매 중·공연 당일 상태) | 홈 화면, 합동공연을 만들기 전, 티켓판매 전, 티켓 판매중인 공연이 있음, 공연 당일 |
| `/recruit` | 팀 모집 공고 목록 | 팀 모집 탭-공고목록 |
| `/chat` | 메시지함 (탭 이름: 메시지) | 메세지함-공통 |
| `/my` | 마이페이지 | 마이페이지, 마이페이지-찜한공연탭 |

### 팀 모집 · 채팅 · 마이

| 경로 | 화면 | Figma 프레임 |
| --- | --- | --- |
| `/recruit/search` | 공고 검색·필터 | 팀 모집 검색_결과, 필터 |
| `/recruit/new` | 모집 공고 작성 | 모집 공고작성 |
| `/recruit/:postId` | 모집 공고 상세 (내 공고·타 팀 공고·마감) | 모집공고-상세_내가 보는 내 밴드 공고, 모집공고-타 팀이 보는 내 밴드 공고 |
| `/chat/:roomId` | 채팅방 (문의 채팅·합동공연 대표자 채팅) | 문의채팅-*, 캐주얼 문의, 합동공연 대표자 채팅 |
| `/chat/:roomId/members` | 채팅 참여자 목록 | 합동공연 대표자 채팅-참여자 목록 |
| `/my/profile/edit` | 내 프로필 수정 | 내 프로필 수정 |
| `/settings` | 설정 (계정·탈퇴·고객지원) | 설정 |
| `/notifications` | 알림 목록 | 알림-목록, 알림-비어있음 |

### 합동공연

| 경로 | 화면 | Figma 프레임 |
| --- | --- | --- |
| `/shows/new` | 공연 열고 팀 모집하기 (공연 정보 불러오기 포함) | 공연 열고 팀 모집하기, 공연 정보 불러오기 |
| `/shows/new/place` | 장소 검색·위치 확인 | 합동공연생성-장소검색, 합동공연생성-위치확인 |
| `/shows/:showId` | 공연 페이지 (정보·피드·일정·티켓 관리 탭) | 정보탭_*, 공고상세_피드, 공고상세_일정, N팀 모집 상태 |
| `/shows/:showId/edit` | 공연 정보 수정 | 공연정보수정 |
| `/shows/:showId/feed/new` | 피드 글쓰기 | 피드-글쓰기_대표자용·팀원용, 글쓰기v2 |
| `/shows/:showId/feed/:postId` | 게시글 상세·댓글 | 피드-게시글상세_댓글 |
| `/shows/:showId/schedule/new` | 일정 등록 | 일정-등록v2, 일정-날짜선택 v2 |
| `/shows/:showId/schedule/:scheduleId` | 일정 상세·수정 | 일정 상세-* |
| `/shows/:showId/setlist/:bandId` | 밴드별 셋리스트 (곡 추가·편집) | 라인업-각 밴드 셋리스트 페이지, 셋리스트-편집, 라인업-곡추가 |
| `/shows/:showId/roles` | 역할 관리 (현장 담당자) | 역할관리-페이지, 역할관리-현장담당자추가 |
| `/shows/:showId/account-owner` | 계좌 주인 지정·변경 | 계좌주인_지정화면, 계좌주인 변경-* |
| `/shows/:showId/entry` | 현장 입장 QR 스캔 | 공연당일-현장 입장 시작, 현장입장_* |
| `/shows/:showId/entry/search` | 이름으로 찾아 입장 처리 | 이름으로 찾기, 이름찾기_* |

### 밴드

| 경로 | 화면 | Figma 프레임 |
| --- | --- | --- |
| `/bands/:bandId` | 밴드 프로필 (내 밴드·타 팀) | 밴드프로필, 밴드프로필-타 팀 프로필 열람 |
| `/bands/:bandId/edit` | 밴드 프로필 수정 | 밴드프로필-수정 |
| `/bands/:bandId/members` | 팀원 관리 (대표자 위임·내보내기) | 팀원관리-페이지 |

### 아직 안 정한 것

- 관객 쪽(공유 링크로 공연 보기·예매·현장 신청·내 티켓·환불)은 확정 영역 밖이다. 앱인지 웹(`apps/web`)인지부터 정한다.
- 공유 링크·푸시 알림이 여는 딥링크 형식.

## 12. 화면 크기·방향

- **폰 세로 전용.** iOS는 iPhone만(`TARGETED_DEVICE_FAMILY = 1`, iPad에서는 iPhone 호환 모드), 방향은 세로만(`Info.plist`). Android는 `MainActivity`에 `screenOrientation="portrait"`.
- Android 16(API 36) 이상을 대상으로 하면 짧은 변 600dp 이상 화면(펼친 폴더블·태블릿)에서는 방향 고정이 무시된다([Android 16 변경사항](https://developer.android.com/about/versions/16/behavior-changes-16)). 그래서 넓은·가로 화면도 깨지지 않게 아래 규칙을 지킨다.
- **크기는 고정, 폭은 유연.** 글자·여백·높이는 토큰(dp) 그대로 두고 화면 폭 비율로 키우지 않는다(flutter_screenutil 같은 비율 확대 패키지를 쓰지 않는다). 가로 폭은 `Expanded`·`Flexible`·부모 폭으로 정한다.
- **넓은 창은 본문 최대 폭 + 가운데 정렬**로 폰 레이아웃을 유지한다. 최대 폭 값과 감싸는 위젯은 처음 필요한 화면 PR에서 만든다(값은 디자이너 확인).
- 크기 판단은 화면은 `MediaQuery.sizeOf(context)`(키보드가 열려도 다시 그리지 않는다), 컴포넌트는 `LayoutBuilder`. 폭 320에서 넘침이 없어야 한다.
