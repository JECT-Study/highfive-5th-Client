import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

/// 카카오 SDK 로그인 호출. SDK 초기화는 `main.dart`에서 한다.
///
/// 카카오톡이 설치돼 있으면 카카오톡으로, 없으면 카카오계정(웹)으로 로그인한다 (카카오 공식 예제 순서).
class KakaoAuthService {
  /// 카카오 access token을 돌려준다. 사용자가 취소하면 null.
  /// BE가 ID 토큰(OpenID Connect)을 원하면 여기서 `idToken`을 돌려주도록 바꾼다.
  Future<String?> login() async {
    try {
      final talkInstalled = await isKakaoTalkInstalled();
      _log('시작 (카카오톡 설치: $talkInstalled)');
      final token = talkInstalled
          ? await _loginWithTalk()
          : await _loginWithAccount();
      _log('성공 (ID 토큰 있음: ${token.idToken != null})');
      return token.accessToken;
    } on Exception catch (error) {
      if (_isCancel(error)) {
        _log('사용자 취소');
        return null;
      }
      _log('실패 ${_describe(error)}');
      rethrow;
    }
  }

  Future<OAuthToken> _loginWithAccount() {
    _log('카카오계정으로 로그인');
    return UserApi.instance.loginWithKakaoAccount();
  }

  Future<OAuthToken> _loginWithTalk() async {
    try {
      _log('카카오톡으로 로그인');
      return await UserApi.instance.loginWithKakaoTalk();
    } on Exception catch (error) {
      // 카카오톡에서 취소했으면 그대로 취소다. 카카오톡에 연결된 계정이 없는 등
      // 다른 이유로 실패하면 카카오계정으로 다시 시도한다.
      if (_isCancel(error)) rethrow;
      _log('카카오톡 로그인 실패, 카카오계정으로 다시 시도 ${_describe(error)}');
      return _loginWithAccount();
    }
  }

  /// 디버그 빌드에서만 찍는다. 토큰 값은 넣지 않는다.
  static void _log(String message) {
    if (kDebugMode) debugPrint('[KakaoAuth] $message');
  }

  /// 오류 종류와 원인만 남긴다. 카카오 오류는 원인 코드(예: KOE101)와 메시지가 들어 있다.
  static String _describe(Exception error) => switch (error) {
    PlatformException(:final code, :final message) =>
      'PlatformException(code: $code, message: $message)',
    _ => '$error',
  };

  /// 카카오톡 화면의 취소는 `PlatformException('CANCELED')`, SDK 화면의 취소는
  /// `KakaoClientException(cancelled)`로 온다.
  static bool _isCancel(Exception error) =>
      (error is PlatformException && error.code == 'CANCELED') ||
      (error is KakaoClientException &&
          error.reason == ClientErrorCause.cancelled);
}
