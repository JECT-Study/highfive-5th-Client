# 웹 구조 (apps/web)

React + TypeScript + Vite. 이벤트·공지·FAQ 같은 공개 페이지와, 관객용 모바일 웹(공연 안내·비로그인 예매·조회·e-티켓, 팀 합의 필요)을 담당한다.
앱 WebView 안에서도 열리고 일반 브라우저에서도 열린다. 모바일 폭을 기준으로 만든다.

## 1. 폴더와 들어가는 파일

```
src/
├── main.tsx                         (있음) createRoot + RouterProvider. global.css import
├── vite-env.d.ts                    (있음) VITE_* 타입
│
├── app/                             앱 전체를 묶는 것만
│   ├── routes.ts                    (있음) 경로 문자열 상수. 여기 말고는 경로를 쓰지 않는다
│   ├── router.tsx                   (있음) appRoutes(RouteObject[]) + createBrowserRouter
│   ├── router.test.tsx              (있음)
│   ├── providers.tsx                QueryClientProvider 등 전역 Provider (필요해지면)
│   └── NotFoundPage.tsx             잘못된 경로 (첫 공개 페이지 만들 때)
│
├── shared/                          도메인을 모르는 공통 코드
│   ├── config/env.ts                (있음) VITE_FLAVOR, VITE_API_BASE_URL 읽기·검증. 아무것도 import하지 않는다
│   ├── styles/
│   │   ├── tokens.css               (있음) 디자인 토큰 (CSS 변수)
│   │   └── global.css               (있음) 리셋, body 기본
│   ├── ui/                          Button.tsx + Button.module.css, TextField, Spinner, ErrorMessage
│   ├── api/
│   │   ├── http.ts                  (있음) fetch 래퍼, HttpError
│   │   └── errors.ts                HttpError → 화면용 오류 변환 (필요해지면)
│   ├── bridge/
│   │   └── appBridge.ts             웹 → 앱 명령 전송, 앱 버전·지원 명령 확인
│   └── utils/                       formatDate.ts, formatMoney.ts 같은 순수 함수
│
└── features/
    └── <feature>/                   notices · events · help · performances · reservations · tickets
        ├── api/                     http 호출 + 요청·응답 타입
        │   └── noticesApi.ts
        ├── hooks/                   데이터 상태 (useNotices, useReservation)
        ├── components/              이 기능 안에서만 쓰는 조각
        │   └── NoticeCard.tsx (+ .module.css)
        └── pages/                   라우트 단위 화면
            ├── NoticeListPage.tsx   (있음, 자리만)
            └── NoticeListPage.module.css
```

- 파일 하나면 폴더를 만들지 않아도 된다. 빈 폴더·미래용 파일을 미리 만들지 않는다.
- 테스트는 파일 옆에 `*.test.tsx`로 둔다(앱과 달리 같은 폴더). 라우트·훅·변환 함수가 우선, 단순 표시 컴포넌트는 선택.

## 2. 의존성 방향

```
main.tsx ─► app ─► features ─► shared
              └──────────────► shared
```

| import 하는 쪽 \ 되는 쪽 | app | features | shared |
| --- | --- | --- | --- |
| **app** | - | O (router가 pages) | O |
| **features** | **X** (경로는 `app/routes.ts`만 예외) | 다른 기능 **X** | O |
| **shared** | X | X | - |

기능 안에서는 `pages → components, hooks → api`. `api`가 `hooks`나 컴포넌트를 모른다.

표의 X는 ESLint `import-x/no-restricted-paths`(`eslint.config.js`)가 막는다. 기능 폴더 목록은 설정이 `src/features/`를 읽어 자동으로 만드므로 새 기능을 추가해도 설정을 고칠 필요가 없다.

`features → app/routes.ts`만 허용하는 이유: 링크를 만들려면 경로 상수가 필요한데, 경로를 기능마다 복사하면 바뀔 때 깨진다. `routes.ts`는 상수만 있고 아무것도 import하지 않으므로 순환이 생기지 않는다.

## 3. 상태

| 상태 | 위치 |
| --- | --- |
| 입력값·열림/닫힘 | 컴포넌트 `useState` |
| 필터·페이지 번호 | URL search params (새로고침·공유에 살아남아야 하는 것) |
| 서버 데이터 | `features/<x>/hooks`. 첫 API 연동 기능에서 TanStack Query 도입 여부를 정한다. 그 전까지는 `useEffect` + `useState`로 작게 |
| 앱 전역 | 없음. 비로그인 웹이라 세션을 두지 않는다 |

비로그인 예매 조회는 추측 불가능한 조회 수단(서버 발급)을 쓰고, 그 값을 URL 외의 곳(로그·분석 이벤트·localStorage)에 남기지 않는다. 앱 세션 토큰은 어떤 경우에도 웹 URL에 넣지 않는다.

## 4. 스타일

- CSS Modules(`*.module.css`) + `tokens.css` 변수. 전역 클래스는 `global.css`의 리셋뿐.
- 컴포넌트 CSS에서는 `var(--color-*)`, `var(--space-*)`, `var(--radius-*)`, `var(--font-size-*)`만 쓴다. hex·px 직접 사용 금지(토큰 파일 제외).
- 모바일 우선. 본문 최대 폭 480px 가운데 정렬. 데스크톱 전용 레이아웃은 만들지 않는다.
- 레이아웃 폭(`max-width`, breakpoint)과 `1px` 테두리 두께는 토큰이 아니다. 숫자를 그대로 쓴다.
- 인라인 `style={{ }}`는 동적 값(진행률 등)에만.

## 5. 앱 ↔ 웹 bridge (만들 때 지킬 것)

- bridge 코드는 `shared/bridge/appBridge.ts` 한 곳. 페이지는 `appBridge.open({ kind: 'performance', id })`처럼 함수만 호출한다.
- 웹은 허용된 명령과 ID만 보낸다. 라우팅·권한 판단은 앱과 서버가 한다.
- 앱 버전·지원 명령을 먼저 확인하고, 미지원이면 웹 안에서 대체 동작(안내 문구·브라우저 링크)을 한다.
- 일반 브라우저(bridge 없음)에서도 모든 페이지가 깨지지 않아야 한다.
- 외부 HTTPS 링크는 브라우저로, 외부 앱 scheme은 허용 목록으로.

## 6. 환경

| 파일 | 용도 | 로드되는 때 |
| --- | --- | --- |
| `.env` | dev 값 (기본) | `pnpm dev`, `pnpm build:dev` |
| `.env.production` | prod 값 | `pnpm build` |

- `VITE_*`는 번들에 그대로 들어간다. 비밀값을 넣지 않는다.
- 환경값은 `shared/config/env.ts`로만 읽는다. `import.meta.env`를 다른 파일에서 직접 쓰지 않는다. `shared`에 두는 이유: `shared/api`가 쓰는데 `shared`는 `app`을 import할 수 없기 때문이다.
- 잘못된 값은 두 번 걸린다: `vite.config.ts`가 빌드·dev 서버 시작 때 검사해 실패시키고(잘못된 산출물이 배포되지 않게), `env.ts`가 실행 시작 때 한 번 더 검사한다.
- dev 배포는 `pnpm build:dev`(mode `dev`, NODE_ENV는 production). `--mode development`로 배포 빌드를 만들지 않는다(React 개발 빌드가 들어간다).

## 7. 도구 버전

- Node 24 (`.nvmrc`), pnpm 12 (`packageManager`, `corepack enable`). TypeScript는 `~6.0.x`로 고정 — Vite 템플릿은 7.0을 깔지만 `typescript-eslint`가 아직 7을 지원하지 않는다. 지원되면 같이 올린다.
- `pnpm-workspace.yaml`은 pnpm 12의 "갓 배포된 패키지 설치 보류" 예외 목록이다. 세팅 당시 막 나온 `@vitejs/plugin-react`만 들어 있고, 며칠 지나면 지워도 된다.

## 8. 하면 안 되는 것

- 컴포넌트에서 `fetch`·`http` 직접 호출 (→ `features/<x>/api`)
- `import.meta.env`를 `shared/config/env.ts` 밖에서 읽기
- 경로 문자열을 `app/routes.ts` 밖에 쓰기
- 다른 기능의 `components`·`hooks`·`pages` import
- `shared`에서 `features`·`app` import
- CSS에 hex·px 직접 쓰기 (토큰 파일 제외)
- bridge 호출을 `shared/bridge` 밖에서 하기, 토큰·조회용 비밀값을 URL·로그에 남기기
- `any`, `// @ts-ignore`, `eslint-disable`로 오류 숨기기
- 문구를 고정하는 테스트

## 9. 이름

| 대상 | 규칙 | 예 |
| --- | --- | --- |
| 컴포넌트·페이지 파일 | PascalCase, 페이지는 `Page` 접미사 | `NoticeListPage.tsx`, `NoticeCard.tsx` |
| 훅 | `useXxx.ts` | `useNotices.ts` |
| api 파일 | `<feature>Api.ts`, 함수는 동사 | `noticesApi.ts` → `fetchNotices()` |
| 그 외 ts | camelCase | `formatDate.ts`, `appBridge.ts` |
| CSS Module | 컴포넌트와 같은 이름 | `NoticeCard.module.css` |
| 테스트 | 파일 옆 `*.test.tsx`, 테스트명은 한국어 문장 | `'/ 는 /notices 로 보낸다'` |
