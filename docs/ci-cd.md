# CI/CD 배포 파이프라인

```
feature 브랜치 → PR → (mobile / web 검사 통과) → develop / main merge → App Release
```

| 대상 | 트리거 | 동작 |
| --- | --- | --- |
| PR 검증 | PR (`apps/mobile/**`, `apps/web/**` 변경 시) | `mobile.yml`, `web.yml`. 명령은 [workflow.md 4절](./workflow.md#4-로컬-검증-pr-전-필수) |
| 앱 release | `develop`, `main` push (`apps/mobile/**` 변경 시) | Shorebird release 빌드 → Fastlane 업로드 → TestFlight · Play 내부 테스트 |
| 긴급 patch | Actions 탭에서 수동 실행 | Shorebird patch (Dart 코드만) → staging → 검증 후 수동 게시 |

- `develop` → **dev** flavor (`com.ject.highfive.dev`), `main` → **prod** flavor (`com.ject.highfive`). flavor가 달라서 두 앱 동시 설치 가능.
- App Store 심사 제출 · Google Play 출시는 **prod만, 콘솔에서 수동 승인**.

## 배포가 기대는 앱 설정 (`apps/mobile`)

- flavor `dev`, `prod`: [mobile-architecture.md](./mobile-architecture.md) 참고. 진입점은 `lib/main.dart` 하나 (`--flavor`로 환경 결정)
- Flutter 버전: `.fvmrc`를 Shorebird에 `--flutter-version`으로 넘긴다
- `shorebird.yaml`: flavor별 app_id. 비밀 아님, git에 넣는다. `pubspec.yaml` assets에 포함
- `AndroidManifest.xml`의 INTERNET 권한: release 앱이 patch를 받으려면 필요
- Android release 서명: CI가 `android/key.properties`를 만들면 그 키로, 없으면(로컬) debug 키로 서명 (`android/app/build.gradle.kts`)
- iOS `Release-dev`, `Release-prod`: manual signing, Team `Q4E6NKD9VN`, 프로파일 `Highfive Dev AppStore` / `Highfive AppStore`. Debug·Profile은 그대로

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
| `SHOREBIRD_TOKEN` | Shorebird 콘솔(console.shorebird.dev)에서 발급한 API 키 |

Apple Team ID(`Q4E6NKD9VN`)는 비밀이 아니라서 workflow에 직접 적었다.

### 2. Branch protection (`develop`, `main`)
Settings → Branches → Require a pull request + Require status checks: `mobile / check`, `web / check`.

## 처음 한 번은 수동
- Google Play: 첫 AAB는 Play Console에서 직접 업로드해야 API 업로드가 가능.
- App Store Connect: `com.ject.highfive`, `com.ject.highfive.dev` 앱 레코드를 먼저 생성.

## 긴급 patch 절차
1. Actions → **Shorebird Patch** → flavor · platform · 대상 release version(예: `1.0.0+42`) 입력 후 실행
2. staging 트랙에서 검증 (rollback 준비)
3. Shorebird 콘솔에서 stable로 수동 게시 → 설치된 앱 다음 실행 시 반영

네이티브 코드 · 권한 · SDK · 에셋 변경은 patch 불가 → 앱 release로 배포.
배포·patch 기록은 [workflow.md 6절](./workflow.md#6-릴리스긴급-수정)대로 `docs/releases.md`에 남긴다.
