# JECT-153 공연 정보 수정

## 범위

JECT-148의 공연 상세 모델·공용 provider 위에 수정 화면과 **메모리 저장 흐름**을 구현한다.
실서버 PUT은 미연결·미검증이다. PUT 서비스·직렬화·기능 전용 실패 매핑은 보존하고
그 실행 검증은 루프백 서버에서만 한다.

## 선택 이유

- 이미 읽은 상세와 version을 재사용해 공연 페이지와 수정 화면이 같은 정보를 보게 한다.
- 조회와 수정을 같은 fake 객체에 연결해 저장 뒤 상세에서도 같은 값을 읽게 한다.
- 값 변경·검증은 Form, 저장 명령·중복 방지·상세 갱신은 ViewModel, 표시·입력·이동은 View가 담당한다.
- source 전체를 바꾸지 않고 실제 수정한 항목만 정규화한다. 지역·포스터 URL·수정하지 않은 시각은 원문을 보존한다.

## 읽는 순서

`app/router.dart` → `concert_edit_view.dart` → `concert_edit_form.dart`
→ `concert_edit_view_model.dart` → `concert_edit_repository.dart` → `fake_concert_edit_repository.dart`.
전송 구현은 `concert_edit_repository.dart`의 원격 어댑터 → `concert_edit_service.dart`
→ `concert_update_request_dto.dart` 순서로 읽는다. `concert_edit_repository_test.dart`가 이 실제 구현을 루프백에서 검증한다.

## 확인할 동작

- 제목·장르·날짜·시간·장소·대관비·모집 팀 수 입력과 미정 전환.
- 바뀐 항목 확인, 저장 중 입력·닫기 잠금, 나가기 확인.
- 저장 뒤 상세 invalidate·version 증가·수정 화면 재진입.
- 같은 version의 동시 저장 방지, 충돌 재조회 중 입력 방지.
- 다른 공연으로 이동 시 폼 재생성, 화면 종료·provider 재생성 뒤 늦은 응답 무시.
- 좁은 화면의 줄바꿈·스크롤·날짜 터치 영역.

## 직접 확인

단독 브랜치의 진입은 다음 위젯 테스트로 확인한다.

```sh
cd apps/mobile
fvm flutter test test/features/performances test/app/concert_edit_route_test.dart test/app/concert_di_test.dart
```

150과 결합한 화면에서는 공연 페이지 → 정보 수정 → 제목 변경 → 수정 완료 → 확인 → 상세 반영 → 재진입 순서로 확인한다.
QA 결과와 캡처는 이 작업의 별도 게시 자료에 기록한다. 자동 검증 통과와 사용자 이해·직접 확인은 별개다.

## 한계와 확인 순서

실제 서버 저장·실제 GET 호환성·포스터 업로드·장소 검색·실기기 확인은 완료로 간주하지 않는다.
메모리 저장값은 앱을 다시 시작하면 사라진다.
문제 시 ID → 상세 provider → Form 검증 → ViewModel 상태 → DI 동일 인스턴스 → 저장 후 invalidate 순서로 본다.
