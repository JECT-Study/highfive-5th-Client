/// 파일을 올리지 못한 이유.
enum UploadFailureReason {
  /// 서버나 저장소에 닿지 못했다.
  network,

  /// 서버가 형식·용량을 받지 않았다 (`COMMON_004`).
  rejected,

  /// 그 밖의 오류 (올릴 주소 만료 포함). 처음부터 다시 올린다.
  unknown,
}

/// 업로드 URL 발급 또는 저장소 업로드에 실패했다.
class UploadFailure implements Exception {
  const UploadFailure(this.reason, [this.cause]);

  final UploadFailureReason reason;

  /// 원래 오류. 디버그 로그에서 서버 오류 코드를 보려고 둔다.
  final Object? cause;

  @override
  String toString() => 'UploadFailure(${reason.name}, $cause)';
}
