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
│   └── router.dart                  (있음) AppRoutes 경로 상수 + routerProvider. 인증 redirect는 여기
│
├── core/                            기술 기반. 도메인(공연·예매)을 모른다
│   ├── di/locator.dart              (있음) getIt 인스턴스
│   ├── network/
│   │   ├── dio_client.dart          (있음) createDio: baseUrl·timeout·디버그 로그
│   │   ├── auth_interceptor.dart    토큰 첨부, 401 → 한 번만 갱신 후 재시도
│   │   └── api_error_mapper.dart    DioException → AppException 변환
│   ├── error/app_exception.dart     sealed class: network / unauthorized / notFound / conflict / server / unknown
│   ├── storage/
│   │   ├── secure_store.dart        FlutterSecureStorage 래퍼 + 키 상수 (토큰)
│   │   └── prefs_store.dart         SharedPreferencesAsync 래퍼 + 키 상수 (설정)
│   ├── sdk/                         소셜 로그인·지도·푸시·QR 스캔 SDK 래퍼 (각 1파일)
│   └── webview/app_bridge.dart      웹 → 앱 명령 수신·검증 (출처·명령·버전)
│
├── shared/                          공통 UI. 도메인을 모른다
│   ├── theme/
│   │   ├── app_colors.dart          (있음) 색 토큰 (ThemeExtension), context.colors
│   │   ├── app_spacing.dart         (있음) 간격 토큰
│   │   ├── app_radius.dart          (있음) 모서리 토큰
│   │   ├── app_typography.dart      (있음) 글자 크기 토큰 → TextTheme
│   │   └── app_theme.dart           (있음) 토큰을 ThemeData로 묶음
│   ├── widgets/                     app_button.dart, app_text_field.dart,
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
- `core`와 `shared`의 차이: core는 "어떻게 통신·저장하는가", shared는 "어떻게 보이는가". 둘 다 공연·예매 같은 도메인 단어를 모른다.
- 여러 기능에서 쓴다는 이유만으로 기능 코드를 core/shared로 옮기지 않는다. 다른 기능이 필요하면 그 기능의 Repository·모델을 import한다.

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

- `AppException`은 `core/error/app_exception.dart`의 sealed class. 화면은 종류별로 문구·행동(재시도, 로그인 이동)을 정한다.
- View는 `AsyncValue.when`으로 로딩·오류·빈 결과를 반드시 그린다. `shared/widgets`의 `LoadingView`·`ErrorView`·`EmptyView`를 쓴다(첫 화면 만들 때 생성).
- 네트워크 단절·5xx로 로그아웃하지 않는다. `unauthorized`(갱신 실패)만 세션을 정리한다.

## 7. 하면 안 되는 것

- View에서 Dio·Repository·getIt 직접 호출
- ViewModel에서 `BuildContext`·위젯·`Navigator` 사용
- `getIt<...>()`을 `app/di.dart`, `app/providers.dart`, `presentation/providers/` 밖에서 호출
- ViewModel을 get_it에 등록
- Provider `build()`에서 신청·예매·결제 같은 쓰기 요청
- 다른 기능의 `presentation/` import (View·ViewModel·widgets·providers)
- `Colors.*`, hex, 숫자 패딩·폰트 크기 직접 사용 — 토큰만 (`context.colors`, `AppSpacing`, `textTheme`)
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
| 라우트 경로 | `AppRoutes`에만 | `AppRoutes.performanceDetail` |
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

- 값이 정해지는 순서: `--flavor dev`를 주면 Flutter가 `FLUTTER_APP_FLAVOR=dev`를 넣고, `AppEnv.fromEnvironment()`가 그 값을 먼저 읽는다. 없으면 `--dart-define=FLAVOR`(flavor 없이 도는 테스트·도구용)를, 그것도 없으면 dev를 쓴다. 모르는 값이면 시작할 때 바로 실패한다.
- 설정 위치: Android는 `android/app/build.gradle.kts`의 `productFlavors`다. 앱 이름은 `resValue("string", "app_name", ...)`로 넣고, AGP 9는 이 기능이 기본으로 꺼져 있어 `buildFeatures.resValues = true`가 필요하다. iOS는 빌드 구성 `Debug-dev`·`Release-dev`·`Profile-dev`(prod도 같은 셋)와 공유 스킴 `dev`·`prod`다. Flutter는 스킴 이름이 flavor 이름과 같아야 찾는다. iOS 앱 이름은 빌드 설정 `APP_DISPLAY_NAME`이 `Info.plist`의 `CFBundleDisplayName`으로 들어간다.
- **명령에는 항상 `--flavor`를 붙인다.** Android는 flavor 없이 빌드하면 `Gradle build failed to produce an .apk file` 오류로 실패한다. iOS는 원래 `Runner` 스킴이 남아 있어 flavor 없이도 빌드되지만, 결과는 prod 앱 ID에 dev 환경(DEV 배너·dev API)이 섞인 앱이다. 이 빌드는 배포에 쓰지 않는다.
- Xcode에서 직접 Run·Archive하지 않는다. 그때 Dart 쪽 flavor는 고른 스킴이 아니라, 마지막 `fvm flutter` 명령이 `ios/Flutter/Generated.xcconfig`에 남긴 `FLAVOR` 값을 따른다(flutter_tools `bin/xcode_backend.dart`). 그래서 스킴과 환경이 어긋날 수 있다.
- CocoaPods를 쓰게 되면 `ios/Podfile`의 `project 'Runner', {...}`에 새 구성 6개를 매핑해야 한다(`Debug-dev`는 `:debug`, `Release-dev`·`Profile-dev`는 `:release`, prod도 같게). 각 구성의 Pods xcconfig도 include해야 한다. 지금은 SwiftPM을 써서 Podfile이 없다.
