# CI/CD 배포 파이프라인

```
feature 브랜치 → PR → (PR Check 통과) → develop / main merge
```

| 대상 | 트리거 | 동작 |
| --- | --- | --- |
| PR 검증 | `develop`, `main` 대상 PR | `flutter analyze` · `flutter test` (Flutter 버전은 `.fvmrc`) |
| 앱 release | `develop`, `main` push (`lib/`, `android/`, `ios/`, `assets/`, `pubspec.*` 변경 시) | Shorebird release 빌드 → Fastlane 업로드 → TestFlight · Play 내부 테스트 |
| 긴급 patch | Actions 탭에서 수동 실행 | Shorebird patch (Dart 코드만) → staging → 검증 후 수동 게시 |

- `develop` → **dev** flavor (`com.ject.highfive.dev`), `main` → **prod** flavor (`com.ject.highfive`). flavor가 달라서 두 앱 동시 설치 가능.
- App Store 심사 제출 · Google Play 출시는 **prod만, 콘솔에서 수동 승인**.

## 코드가 따라야 할 구조

- Flutter 앱: 저장소 루트
  - flavor: `dev`, `prod` (Android `productFlavors`, iOS scheme/configuration)
  - entrypoint: `lib/main_dev.dart`, `lib/main_prod.dart`
  - `shorebird init`으로 `shorebird.yaml` 생성 (flavor별 app_id 포함)
  - Android `build.gradle`에서 `android/key.properties`로 release 서명 (Flutter 공식 방식)
  - iOS Release 빌드 설정은 **manual signing** (CI가 설치한 프로파일 사용)

## GitHub 설정

### 1. Repository secrets
Settings → Secrets and variables → Actions → New repository secret. 파일은 git에 넣지 않는다.
바이너리 파일은 `base64 -i <파일> | pbcopy`, 텍스트 파일은 `pbcopy < <파일>`로 복사해서 붙여넣는다.

| Secret | 파일 / 값 |
| --- | --- |
| `IOS_DISTRIBUTION_P12_BASE64` | `Highfive_Distribution.p12` (base64) |
| `IOS_P12_PASSWORD` | `비밀번호.txt` |
| `IOS_PROFILE_PROD_BASE64` | `Highfive_AppStore.mobileprovision` (base64) |
| `IOS_PROFILE_DEV_BASE64` | `Highfive_Dev_AppStore.mobileprovision` (base64) |
| `ASC_KEY_ID` | App Store Connect API 키 ID (`highfive-ci`) |
| `ASC_ISSUER_ID` | App Store Connect Issuer ID |
| `ASC_KEY_P8` | `AuthKey_<KEY_ID>.p8` (원문) |
| `ANDROID_KEYSTORE_BASE64` | `highfive-upload.jks` (base64) |
| `ANDROID_KEYSTORE_PASSWORD` | `비밀번호.txt` |
| `ANDROID_KEY_PASSWORD` | keystore 암호와 같음 |
| `ANDROID_KEY_ALIAS` | `highfive-upload` |
| `PLAY_SERVICE_ACCOUNT_JSON` | `highfive-play-ci.json` (원문) |
| `SHOREBIRD_TOKEN` | `shorebird login:ci`로 발급 |

Apple Team ID(`Q4E6NKD9VN`)는 비밀이 아니라서 workflow에 직접 적었다.

### 2. Branch protection (`develop`, `main`)
Settings → Branches → Require a pull request + Require status checks: `PR Check / app`.

## 처음 한 번은 수동
- Google Play: 첫 AAB는 Play Console에서 직접 업로드해야 API 업로드가 가능.
- App Store Connect: `com.ject.highfive`, `com.ject.highfive.dev` 앱 레코드를 먼저 생성.

## 긴급 patch 절차
1. Actions → **Shorebird Patch** → flavor · platform · 대상 release version(예: `1.0.0+42`) 입력 후 실행
2. staging 트랙에서 검증 (rollback 준비)
3. Shorebird 콘솔에서 stable로 수동 게시 → 설치된 앱 다음 실행 시 반영

네이티브 코드 · 권한 · SDK · 에셋 변경은 patch 불가 → 앱 release로 배포.
