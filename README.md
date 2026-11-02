# highfive-5th-Client

highfive 5기 클라이언트 저장소. 앱(Flutter)과 웹(React + TypeScript + Vite)을 같은 저장소에서 관리한다.

```
apps/mobile   Flutter 앱 (Flutter 3.47.9, fvm)
apps/web      공개 웹·관객용 모바일 웹 (Node 24, pnpm)
docs/         작업 흐름·구조·디자인 토큰 규칙
```

처음이면 [docs/overview.md](./docs/overview.md)(그림으로 보는 전체 구조)부터, 작업 규칙은 [AGENTS.md](./AGENTS.md)에서 시작한다.

## 앱 실행

```bash
cd apps/mobile
fvm install                                # .fvmrc 버전 설치
fvm flutter pub get
fvm flutter run --flavor dev               # dev / prod 두 앱이 나란히 설치된다
```

PR 전 검증 (CI도 같은 명령):

```bash
fvm dart format --set-exit-if-changed lib test tool
fvm flutter analyze
fvm dart run tool/check_imports.dart
fvm flutter test
```

## 웹 실행

```bash
cd apps/web
corepack enable                            # pnpm 버전은 package.json의 packageManager를 따른다
pnpm install
pnpm dev
```

PR 전 검증 (CI도 같은 명령):

```bash
pnpm format:check && pnpm lint && pnpm typecheck && pnpm test && pnpm build
```
