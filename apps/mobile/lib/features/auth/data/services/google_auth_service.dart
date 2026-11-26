import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google 로그인 호출.
///
/// iOS는 [iosClientId]로, Android는 패키지명·SHA-1(Google 콘솔에 등록)로 앱을 알아본다.
/// ID 토큰은 [serverClientId](웹 클라이언트) 앞으로 나와 서버가 검증할 수 있다.
class GoogleAuthService {
  GoogleAuthService({required this.iosClientId, required this.serverClientId});

  final String iosClientId;
  final String serverClientId;

  /// 첫 로그인 때 한 번만 초기화한다.
  Future<void>? _initialized;

  /// Google ID 토큰을 돌려준다. 사용자가 취소하면 null.
  Future<String?> login() async {
    final signIn = GoogleSignIn.instance;
    try {
      await (_initialized ??= signIn.initialize(
        clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? iosClientId
            : null,
        serverClientId: serverClientId,
      ));
      _log('시작');
      final account = await signIn.authenticate();
      final idToken = account.authentication.idToken;
      _log('성공 (ID 토큰 있음: ${idToken != null})');
      return idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        _log('사용자 취소');
        return null;
      }
      _log('실패 (code: ${error.code.name}, description: ${error.description})');
      rethrow;
    }
  }

  /// 디버그 빌드에서만 찍는다. 토큰 값은 넣지 않는다.
  static void _log(String message) {
    if (kDebugMode) debugPrint('[GoogleAuth] $message');
  }
}
