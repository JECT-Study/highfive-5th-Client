import '../../../../core/error/app_exception.dart';
import '../../models/next_step.dart';
import '../../models/nickname_check_result.dart';
import '../../models/profile_draft.dart';
import '../../models/profile_failure.dart';
import '../../models/profile_options.dart';
import '../dto/profile_dto.dart';
import '../services/profile_service.dart';

/// 닉네임을 확인하고 개인 프로필을 저장한다. 서버 오류는 [ProfileFailure]로 바꿔 던진다.
/// 온보딩과 마이페이지 프로필 수정이 같이 쓴다.
class ProfileRepository {
  ProfileRepository(this._service);

  final ProfileService _service;

  /// 선택지는 서버 ENUM이라 거의 바뀌지 않는다. 앱 실행 중 한 번 받아 둔다 (명세 FE 참고).
  ProfileOptions? _options;

  /// 장르·포지션 선택지. 받은 적이 있으면 서버에 다시 묻지 않는다.
  Future<ProfileOptions> fetchOptions() async {
    if (_options case final options?) return options;
    try {
      return _options = (await _service.fetchCodes()).toModel();
    } on AppException catch (error) {
      throw ProfileFailure(_reasonOf(error), error);
    }
  }

  /// 결과는 참고용이다. 최종 판단은 [saveProfile]의 `nicknameTaken`.
  Future<NicknameCheckResult> checkNickname(String nickname) async {
    try {
      return (await _service.checkNickname(nickname)).toModel();
    } on AppException catch (error) {
      throw ProfileFailure(_reasonOf(error), error);
    }
  }

  /// 돌려주는 값은 서버가 정한 다음 화면 (밴드 기능 전까지는 `bandStart`).
  Future<NextStep> saveProfile(ProfileDraft draft) async {
    final request = ProfileRequestDto(
      nickname: draft.nickname,
      genreCodes: draft.genreCodes,
      genreCustomName: _customName(
        draft.genreCodes,
        ProfileDraft.genreCustomCode,
        draft.genreCustomName,
      ),
      positionCodes: draft.positionCodes,
      positionCustomName: _customName(
        draft.positionCodes,
        ProfileDraft.positionCustomCode,
        draft.positionCustomName,
      ),
      profileImageUrl: draft.profileImageUrl,
    );
    try {
      return (await _service.saveProfile(request)).toModel();
    } on AppException catch (error) {
      throw ProfileFailure(_reasonOf(error), error);
    }
  }

  /// 직접입력 코드를 골랐을 때만 앞뒤 공백을 뺀 값을 보낸다. 안 골랐으면 null
  /// (입력칸에 남은 값을 보내면 서버가 `COMMON_004`로 막는다).
  static String? _customName(
    List<String> codes,
    String customCode,
    String? name,
  ) => codes.contains(customCode) ? name?.trim() : null;

  /// 서버 오류 코드 → 실패 이유 (docs/api/profile.md "에러").
  static ProfileFailureReason _reasonOf(AppException error) => switch (error) {
    NetworkException() => ProfileFailureReason.network,
    ApiException(code: 'USER_001') => ProfileFailureReason.nicknameTaken,
    ApiException(code: 'COMMON_004') => ProfileFailureReason.invalidInput,
    ApiException(code: 'USER_003') => ProfileFailureReason.termsRequired,
    ApiException(code: 'USER_005') => ProfileFailureReason.userNotFound,
    ApiException() || UnknownApiException() => ProfileFailureReason.unknown,
  };
}
