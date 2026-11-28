# JECT-159 티켓 신청 페이지 생성

## 범위와 선택 이유

Jira 완료 기준은 주최 대표자의 생성 버튼과 중복 생성 방지다. 제공된
Notion API 본문과 Swagger에는 티켓 endpoint가 없다. 따라서 HTTP·DTO를
추측하지 않고 `PreviewTicketPageRepository`의 메모리 상태만 만든다.
진짜 신청 링크, 개인정보, 계좌, QR, 관객 웹은 생성하지 않는다.

사용자가 구현·로컬 검증·읽기 전용 Codex 검토·로컬 커밋을 지시했다.
사용자 이해 확인과 직접 UI 확인은 미확인이다. 푸시·배포는 이 작업에 없다.

## 화면 계약

기준: `figma-2216-136008.png`의 생성 전 안내·버튼, 공통 디자인 시스템.
제공 PNG의 어두운 밴드 스타일은 확정 팔레트가 아니므로 기존 앱의
`AppTheme.light`, `AppTopBar`, `AppButton`, `AppNotice`, 토큰을 사용한다.
신청 링크가 실제로 생긴다는 문구는 로컬 미리보기라는 문구로 바꾼다.

- 주 동작: 티켓 신청 페이지 만들기.
- 읽는 순서: 합성 공연의 식별 → 현재 생성 상태 → 생성 또는 결과 확인.
- 필요한 내용: 공연 제목, 로컬 미리보기 표시, 생성 전 안내, 생성 버튼,
  로딩, 오류와 재조회, 권한 제한, 생성 결과.
- 후속 티켓 담당: 설정 폼(J160), 공유(J161), 판매 관리(J162), 계좌주인(J163).
- Layout: 단일 ListView가 공연 요약 → 생성 상태 → 주 동작 순서로 스크롤한다.

| 상태 | 결정 조건 | 화면 | 다음 동작 | 저장소 호출 | 표시하면 안 되는 것 |
| --- | --- | --- | --- | --- | --- |
| 확인 중 | 최초 조회 대기 | 진행 표시 | 조회 완료 대기 | find 1회, 8초 기한 | 생성 전 빈 상태 |
| 생성 전 | 조회 성공, page 없음 | 안내와 주 동작 | 생성 | 없음 | 발행된 실제 링크 |
| 설정 중 | onConfigure 대기 | 생성 버튼 비활성 | 설정 완료 또는 취소 | 쓰기 없음 | 두 번째 설정 진입 |
| 생성 중 | create 대기 | 생성 버튼 로딩 | 완료 대기 | create 1회, 8초 기한 | 두 번째 쓰기 |
| 생성 완료 | page 있음 | 로컬 생성 안내/통합 슬롯 | 후속 티켓의 동작 | 없음 | 재생성 버튼 |
| 조회 실패 | find 실패/기한 초과 | 오류, 다시 시도 | 재조회 | find | 생성 전 상태로 추정 |
| 확정 생성 실패 | create의 확정 오류 | 오류와 재시도 | 다시 생성 | 사용자 명령 때만 create | 성공 안내 |
| 결과 미확정 | create 기한 초과 | 재생성 차단, 결과 확인 | 재조회 | find, 8초 기한 | 실패 확정과 재송신 |
| 권한 없음 | 합성 역할/공연 불일치 | 제한 안내 | 합성 역할 확인 | 저장소 경계에서 거절 | 생성 버튼 |

설정 콜백은 사람이 화면에서 입력하는 시간이며 요청 timeout과 분리한다.
설정 취소는 생성하지 않는다. 구독이 끝난 설정 콜백은 첫 쓰기 전에도 무효다.

## 통합 시그니처

`models/ticket_role.dart`:

```dart
enum TicketRole { organizer, accountOwner, member, outsider }
const ticketPreviewConcertId = 'demo-concert';
const ticketPreviewActorId = 'demo-host';
const ticketPageRequiredRole = TicketRole.organizer;
typedef TicketPageScope = ({
  String concertId,
  String actorId,
  TicketRole role,
});
```

`demo-host`만 organizer이고 `demo-member-a`, `demo-member-b`는 member,
`demo-guest`는 outsider다. accountOwner 정적 승격은 없다. J163에서 지정한다.

```dart
TicketPageView({
  String concertId = ticketPreviewConcertId,
  String actorId = ticketPreviewActorId,
  TicketRole role = TicketRole.outsider,
  ValueListenable<TicketPageScope>? actorScope,
  Future<bool> Function()? onConfigure,
  Widget Function(BuildContext, TicketApplicationPage)? createdBuilder,
});
```

J160은 `onConfigure`에서 설정 화면의 확인 여부를 반환한다.
View의 로컬 진행 상태가 설정 중복 진입을 막고, 확인 후 VM의 create를 호출한다.
역할이 바뀌는 통합 화면은 `actorScope`로 변경 원본을 전달한다. 각 record는
불변 합성 identity이며 원본의 변경 알림에서 즉시 이전 콜백을 무효화한다.
부모의 다음 프레임이나 다른 화면의 구독에 기대지 않는다. 같은 프레임의
A→B→A 전환도 이전 콜백으로 첫 쓰기를 하지 않는다. 고정 dev fixture는
기존 생성자 인수만 사용한다. 설정 화면의 overlay는 actor 변경이 아니다.
`createdBuilder`는 생성 후 UI의 조합 지점이다. 인증 계정과 연결하지 않는다.
`ticketPageViewModelProvider(scope)`는 공연·사용자·역할이 모두 같은 경우만
상태를 공유한다. 저장소는 동일 공연의 create를 원자적으로 하나로 합친다.
권한을 검사하는 `watch(scope)`는 같은 공연의 생성 결과를 기존 구독자에게도
전달한다. writer를 invalidate하지 않으며 이미 알려진 생성 결과를 timeout이
다시 미확정 상태로 바꾸지 않는다.

## 코드 읽기와 장애 확인 순서

1. `app/router.dart`: `isDev` 안에서만 `/dev/ticket-page` 등록 및 인증 예외.
2. `ticket_page_view.dart`: 버튼 → VM의 create, 실패와 미확정 결과 분리.
3. `ticket_page_view_model.dart`: 생성 중복 차단, 요청 기한, 세대 비교와
   `ref.mounted`, 미확정 명령의 keepAlive.
4. `ticket_page_repository.dart`: 합성 공연·사용자·역할 권한 검증 후
   동기 메모리 기록 후 변경 알림; HTTP·영속 저장·로그 기록 없음.
5. 미러 테스트: 저장소의 동시 생성, VM의 오류·기한·전환, 실제 버튼과
   dev/prod의 로그인 전후 라우트, 프레임 전 사용자 전환, 이미 열린 멤버
   화면의 갱신, 변경 알림 중 보류 writer의 단일 실행.

문제가 있으면 먼저 flavor와 경로 → scope 세 값 → VM 상태 →
저장소 생성 여부 순서로 확인한다. timeout에 create를 다시 호출하지 않는다.

## 검증 방법과 한계

Codex 검토는 R3에서 종료한다. R1의 P2 3건(설정 overlay와 구독 종료 혼동,
재진입 중복 생성, prod 로그인 상태 검증 공백), R2의 P2 2건(프레임 전
사용자 전환, 이미 열린 멤버 상태 미갱신)을 수정했다.
R3 판정은 승인 보류이며 P2 1건(누른 채 역할 전환 후 이전 버튼으로 설정
진입)을 남겼다. 이후 버튼이 그려진 epoch와 scope를 콜백에 고정하고,
설정 진입 전에 live actor·scope·VM.canCreate를 다시 검사하도록 수정했다.
같은 프레임의 down→outsider 전환→up 및 down→outsider→host 복귀→up에서
설정 콜백 0회와 저장 결과 없음을 검증하는 실제 gesture 회귀를 추가했다.
R3 이후 독립 재검토는 하지 않는다. 수정 후 자동 검증과 독립 승인 여부를
구분하며 마지막 실행 로그는 `final-fix-gates.log`에 기록한다.

FVM 명령은 영문 `/tmp` 복사본에서 기존 lock inode를 잡는
`~/dori-lanes/hf-ticket/heavy.py`로 직렬 실행한다. 앱 전체 테스트·정적 분석·
import 검사와 기능 테스트를 실행하고, 위젯 렌더 PNG와 검토 로그는 저장소
밖 `~/dori-lanes/hf-ticket/evidence/JECT-159`에 보관한다.

직접 확인: dev 빌드에서 `/dev/ticket-page`를 열고 생성 버튼을 누른다.
로컬 생성 안내 뒤 생성 버튼이 사라져야 한다. prod에서는 진입할 수 없다.
앱의 ProviderContainer를 새로 만들면 초기화된다. 같은 앱 메모리 안의 화면
재진입은 기존 생성 결과와 미확정 명령을 유지한다. 원격 발행·서버 멱등성·실제 계정 권한은
검증하거나 구현하지 않았으며 티켓 API 계약이 나온 뒤 별도 연결해야 한다.

Riverpod 3의 family 생성자와 비동기 이후 `ref.mounted` 사용 원리는
공식 3.0 migration 문서에서 확인했다. 실제 실행 결과와 Codex 지적은
위 evidence 디렉터리의 로그를 따른다. 캡처는 위젯 테스트이며 실기기 확인,
다크 테마 지원, 운영 준비 완료를 의미하지 않는다.
