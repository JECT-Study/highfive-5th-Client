# JECT-155 문의 채팅 계약

2026-11-28 Swagger와 Notion API snapshot에는 채팅 endpoint가 없다.
HTTP/STOMP/WebSocket 주소, DTO, 재접속/멱등성 정책은 만들지 않았다.
이 구현은 명시적으로 선택한 dev fake에서만 동작한다.

## 연결과 수명

- `app/env.dart`: `--flavor dev --dart-define=CHAT_FAKE=true`일 때만 활성화.
  기본 dev와 prod는 차단한다. 기존 인증 redirect를 그대로 따른다.
- `app/chat_composition.dart`: 인증 완료 세션마다 `FakeChatStore`를 만든다.
  로그인 세션 변경/로그아웃/복원 오류에서 이전 store와 모든 actor 핸들을 폐기한다.
  토큰을 actor/밴드/대표자 권한으로 해석하지 않는다.
- 로그아웃 버튼의 app router 콜백이 네트워크 완료를 기다리기 전에 채팅 gate를
  닫는다. auth 구현은 수정하지 않는다. 약관 완료 후 profile/bandStart/home은
  기존 router가 허용하는 동일한 인증 진입 범위로 취급한다.
- 앱 조합 계층은 기존 `SessionExpiry` 알림도 구독해 같은 gate를 닫는다.
  인증 저장소 정리가 완료되기를 기다리지 않고 채팅 수명을 끝낸다.
  dev fake에서는 router 생성부터 gate 구독을 유지하므로 첫 채팅 진입 전 만료도 기록한다.
- 메시지 탭의 `FAKE` 표시와 actor 선택으로 참여희망팀 대표와 주최팀 대표를
  바꿔 같은 방에서 양방향 메시지를 주고받는다. 서버에 저장하지 않는다.
- 화면 이동은 router composition의 `chatPostNavigationProvider`로 주입한다.
  공고 상세가 아직 없으므로 기본은 null이고 공고 이동은 비활성이다.

## 공개 seam과 가정

`features/chat/models/chat_room.dart`, `data/repositories/chat_repository.dart`:

| 항목 | 계약 |
| --- | --- |
| `actor` | `ChatActor` (인증과 독립적인 fake 신원) |
| `openInquiry(InquiryTarget)` | `Future<ChatRoom>`, 공고/주최팀/참여희망팀 조합으로 중복 방 방지 |
| `rooms()` | `Stream<List<ChatRoom>>`, actor 소속 팀의 방 snapshot |
| `watchRoom(roomId)` | `Stream<ChatRoom>`, 메시지와 현재 actor 접근 권한 snapshot |
| `send(roomId, text)` | `Future<void>`, 공백 제거, 빈 메시지/팀원/외부 팀/폐기 핸들 거부 |
| `dispose()` | 구독 종료, 보관된 핸들의 읽기·쓰기 재사용 거부 |

모든 필드는 서버 명세가 없는 로컬 가정이다. `fake-room-N`은 로그인 수명 안의
식별자이며 서버 방 ID가 아니다. 메시지 ID·작성자 ID·팀 ID·시각은 변경하지 않고
snapshot은 읽기 전용이다. 중복 방 방지는 fake 프로세스 안에서만 보장한다.
실제 멱등성·권한·메시지 전달 보장은 서버 계약과 서버 검증이 필요하다.

고정 fixture: `fake-applicant-leader`/`fake-applicant` (소음공장 대표),
`fake-host-leader`/`fake-host` (오프비트 대표),
`fake-applicant-member`/`fake-applicant` (소음공장 팀원).
공고 ID는 `fake-post`. 어느 것도 실제 로그인 계정/역할을 뜻하지 않는다.

## 후속 작업 경계

- 156: `ChatRoomAccess.canDecide`는 주최팀 대표만 true.
  `ChatRoomView.decisionBuilder` 슬롯에 수락/거절 UI를 연결한다.
  참가 수락·권한 반영·초대 메시지 전송은 이 PR에 없다.
- 157: `rooms()` snapshot과 방 이동 콜백을 사용해 목록/미확인 필터를 확장한다.
- 158: `ChatRoomKind`와 `ChatRoomAccess`로 공연 채팅/읽기 전용을 확장한다.
  이 PR이 생성하는 방은 inquiry뿐이다.
- 176: 저장된 메시지는 작성자 ID를 보존한다. 이후 서버가 반환하는 현재 권한을
  snapshot에 반영하는 구현으로 확장한다. 대표자 이관 명령은 이 PR에 없다.

## 화면과 상태

Figma 실제 프레임 `1539:8705`, `1539:8765`를 읽었다.
주요 동작은 메시지 보내기이며, 상대 팀 → 공고 → 대화 → 입력 순서다.
상단/공고 띠/말풍선/시스템 문구/입력은 기존 v3 공통 위젯을 사용한다.
주최자 수락 카드, 더보기 동작, 응답시간 통계는 후속 작업/서버 계약이 없어 비활성이다.

Layout: 고정 상단 바와 공고 띠, 역방향 메시지 `ListView` 하나, SafeArea 입력창.
방은 root navigator에 열어 하단 탭과 입력창이 겹치지 않는다.
키보드가 열리면 보조 공고 띠/역할 선택기를 접어 작은 화면의 입력 공간을 확보한다.
FAKE 표시는 상단 바에도 남는다. 팀원 보기에서는 작성자 이름을 표시한다.
대표자 보기에서도 각 말풍선의 접근성 label에 작성자와 송수신 방향을 제공한다.

| 상태 | 표시와 다음 동작 |
| --- | --- |
| 미연결/로그인 없음 | 채팅 준비 안내. 운영 데이터처럼 빈 목록을 표시하지 않음 |
| 첫 구독 대기 | 로딩. 빈 대화나 입력창을 표시하지 않음 |
| 빈 목록/대화 | 문의 없음/문의 시작 시스템 문구. fake 신청팀 대표는 문의 시작 가능 |
| 구독 실패/없는 방 | 오류와 재시도/뒤로가기 |
| 전송 중 | 중복 명령과 입력 차단 |
| 전송 성공 | 스트림 갱신과 입력 초기화 |
| 전송 실패 | 입력 유지, 원인 안내, 다시 보내기 |
| 팀원 | 읽기 전용 입력창 |
| 세션/actor 교체 | 이전 핸들 폐기, 입력과 늦은 명령 결과 제거 |

명령은 완료 시 backing actor 핸들을 다시 확인한다. 일시정지된 구독의 대기열에는
데이터 대신 갱신 신호만 넣고 전달 시 snapshot을 읽어 폐기된 세션의 데이터를 버린다.
연결 불가/접근 불가 오류는 자동 재시도하지 않고 즉시 안내한다.

## 확인 순서와 남은 한계

실패 시 `chatFakeStoreProvider`의 환경/세션 조건 → `appChatRepositoryProvider`의
actor → repository 접근 권한 → `chatRoomProvider` 구독 → command 상태 순으로 확인한다.

직접 확인: 인증된 dev fake에서 메시지 탭 → 문의 시작 → 메시지 보내기 →
주최 대표로 전환 → 받은 메시지 확인/응답 → 팀원으로 전환해 입력 차단 확인 →
로그아웃/다른 계정으로 로그인 후 이전 방이 사라졌는지 확인한다.
사용자의 이해 완료나 실기기 검증은 에이전트가 대신 선언하지 않는다.

실서버 전송/영속 저장/오프라인 재전송/다중 기기/접근성 수동 검증은 미확인이다.
시뮬레이터와 브라우저를 실행하지 않는다. PR에는 자동 검증 로그의 로컬 artifact를
캡처 대체 근거로 명시한다. 픽셀 일치나 WCAG 전체 통과를 주장하지 않는다.
