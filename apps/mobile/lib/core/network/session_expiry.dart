import 'dart:async';

/// 서버가 세션을 끝냈다고 알려 온 것을 앱에 전한다.
/// `AuthInterceptor`가 알리고, 세션 ViewModel이 듣고 로그아웃한다 (core는 기능을 모르므로 이렇게 잇는다).
class SessionExpiry {
  final _controller = StreamController<String>.broadcast();

  /// 세션을 끝낸 서버 오류 코드 (`AUTH_001`·`AUTH_003`·`AUTH_004`).
  Stream<String> get stream => _controller.stream;

  void notify(String code) => _controller.add(code);
}
