# highfive-5th-Client

highfive 5기 클라이언트 저장소. 앱(Flutter)과 웹(React, 예정)을 같은 저장소에서 관리한다.

```
apps/mobile   Flutter 앱
apps/web      React + TypeScript + Vite (예정)
docs/         API·앱↔웹 계약·배포 절차 (예정)
```

작업 규칙은 [AGENTS.md](./AGENTS.md)를 본다.

## 앱 실행

Flutter 버전은 `apps/mobile/.fvmrc`에 고정한다(현재 3.47.9).

```bash
cd apps/mobile
fvm install                                # .fvmrc 버전 설치
fvm flutter pub get
fvm flutter run --dart-define=FLAVOR=dev   # FLAVOR 생략 시 dev
```

PR 전 검증:

```bash
fvm dart format --set-exit-if-changed lib test
fvm flutter analyze
fvm flutter test
```
