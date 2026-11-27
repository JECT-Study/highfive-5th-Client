/// 프로필 사진을 고르지 못한 이유. 화면은 이유별로 안내하고 다시 고르게 한다.
enum PhotoPickProblem {
  /// 10MB를 넘는다.
  tooLarge,

  /// 서버가 받지 않는 형식이다 (jpg·png·heic만).
  unsupportedType,

  /// 카메라 접근을 거부했다. 설정에서 켜야 한다.
  cameraDenied,

  /// 사진 접근을 거부했다. 설정에서 켜야 한다.
  albumDenied,

  /// 그 밖의 오류.
  unknown,
}
