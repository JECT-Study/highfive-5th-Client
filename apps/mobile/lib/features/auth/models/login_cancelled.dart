/// 사용자가 소셜 로그인 화면에서 취소했다. 오류가 아니라 오류 안내를 띄우지 않는다.
class LoginCancelled implements Exception {
  const LoginCancelled();
}
