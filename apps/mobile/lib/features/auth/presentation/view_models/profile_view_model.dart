import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/sdk/photo_picker.dart';
import '../../../uploads/models/upload_failure.dart';
import '../../../uploads/models/upload_purpose.dart';
import '../../models/next_step.dart';
import '../../models/nickname_check_result.dart';
import '../../models/photo_pick_problem.dart';
import '../../models/profile_draft.dart';
import '../../models/profile_failure.dart';
import '../../models/profile_rules.dart';
import '../providers/profile_providers.dart';
import 'session_view_model.dart';

part 'profile_view_model.freezed.dart';

/// 온보딩 개인 프로필 두 화면(정보 입력 → 사진)의 상태와 명령.
///
/// 사진 화면은 정보 화면 위에 쌓이므로 두 화면이 같은 상태를 본다.
/// 둘 다 닫히면(저장 성공·로그아웃) 정리된다.
final profileViewModelProvider =
    NotifierProvider.autoDispose<ProfileViewModel, ProfileState>(
      ProfileViewModel.new,
    );

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default('') String nickname,

    /// [nickname]의 "중복 확인" 결과. 닉네임을 고치면 null(다시 확인해야 함).
    NicknameCheckResult? nicknameCheck,

    /// 중복 확인 중. 버튼은 다시 눌리지 않는다.
    @Default(false) bool checkingNickname,

    /// 고른 순서대로.
    @Default(<String>[]) List<String> genreCodes,
    @Default('') String genreCustomName,
    @Default(<String>[]) List<String> positionCodes,
    @Default('') String positionCustomName,

    /// 고른 프로필 사진. 없으면 기본 이미지 (건너뛰기).
    PickedPhoto? photo,

    /// 사진 선택기가 열려 있다. 다시 열리지 않는다.
    @Default(false) bool pickingPhoto,

    /// 마지막 사진 고르기가 실패한 이유. 화면은 이 값이 생길 때 안내를 띄운다.
    PhotoPickProblem? photoProblem,

    /// 저장 중. 버튼은 로딩으로 보이고 다시 눌리지 않는다.
    @Default(false) bool saving,

    /// 마지막 확인·저장이 실패한 이유. 화면은 이 값이 생길 때 안내를 띄운다.
    ProfileFailureReason? failure,
  }) = _ProfileState;

  const ProfileState._();

  /// 입력하자마자 "한글, 영문, 숫자만 쓸 수 있어요"를 보일지.
  bool get nicknameHasForbiddenCharacter => hasForbiddenCharacter(nickname);

  bool get canCheckNickname =>
      nickname.isNotEmpty &&
      !nicknameHasForbiddenCharacter &&
      nicknameCheck == null &&
      !checkingNickname;

  bool get nicknameAvailable => nicknameCheck == NicknameCheckResult.available;

  bool get genreCustomSelected =>
      genreCodes.contains(ProfileDraft.genreCustomCode);

  bool get positionCustomSelected =>
      positionCodes.contains(ProfileDraft.positionCustomCode);

  /// 정보 화면의 "다음". 닉네임 확인 통과, 장르·포지션 1개 이상,
  /// 직접입력을 골랐으면 그 값도 규칙에 맞아야 한다.
  bool get canProceed =>
      nicknameAvailable &&
      genreCodes.isNotEmpty &&
      positionCodes.isNotEmpty &&
      (!genreCustomSelected || isValidCustomName(genreCustomName)) &&
      (!positionCustomSelected || isValidCustomName(positionCustomName));
}

class ProfileViewModel extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  /// 닉네임을 고치면 이전 확인 결과는 버린다.
  void changeNickname(String value) {
    if (state.saving || value == state.nickname) return;
    state = state.copyWith(nickname: value, nicknameCheck: null, failure: null);
  }

  /// "중복 확인". 길이·문자가 틀리면 서버에 묻지 않고 바로 결과를 정한다.
  /// 확인하는 사이 닉네임을 고쳤으면 늦게 온 결과는 버린다.
  Future<void> checkNickname() async {
    if (!state.canCheckNickname || state.saving) return;
    final nickname = state.nickname;
    if (!hasValidNicknameLength(nickname)) {
      state = state.copyWith(nicknameCheck: NicknameCheckResult.invalidLength);
      return;
    }
    if (!isValidNickname(nickname)) {
      // 조합이 끝나지 않은 자음·모음이 남았다.
      state = state.copyWith(
        nicknameCheck: NicknameCheckResult.invalidCharacter,
      );
      return;
    }
    state = state.copyWith(checkingNickname: true, failure: null);
    NicknameCheckResult? result;
    ProfileFailureReason? failure;
    try {
      result = await ref
          .read(profileRepositoryProvider)
          .checkNickname(nickname);
    } on ProfileFailure catch (error) {
      failure = error.reason;
    }
    if (!ref.mounted) return;
    state = state.copyWith(
      checkingNickname: false,
      nicknameCheck: state.nickname == nickname ? result : null,
      failure: failure,
    );
  }

  /// 장르 칩을 누르면 고르고, 다시 누르면 푼다.
  void toggleGenre(String code) {
    if (state.saving) return;
    state = state.copyWith(genreCodes: _toggle(state.genreCodes, code));
  }

  void togglePosition(String code) {
    if (state.saving) return;
    state = state.copyWith(positionCodes: _toggle(state.positionCodes, code));
  }

  void changeGenreCustomName(String value) {
    if (state.saving) return;
    state = state.copyWith(genreCustomName: value);
  }

  void changePositionCustomName(String value) {
    if (state.saving) return;
    state = state.copyWith(positionCustomName: value);
  }

  /// 앨범·카메라에서 사진을 고른다. 취소하면 이전 사진을 그대로 둔다.
  /// 10MB를 넘거나 받지 않는 형식이면 고르지 않은 것으로 하고 이유를 알린다.
  Future<void> pickPhoto(PhotoSource source) async {
    if (state.saving || state.pickingPhoto) return;
    state = state.copyWith(pickingPhoto: true, photoProblem: null);
    PickedPhoto? photo;
    PhotoPickProblem? problem;
    try {
      photo = await ref.read(photoPickerProvider).pick(source);
    } on PhotoAccessDenied catch (error) {
      problem = error.source == PhotoSource.camera
          ? PhotoPickProblem.cameraDenied
          : PhotoPickProblem.albumDenied;
    } on Exception catch (error) {
      if (kDebugMode) debugPrint('[Profile] 사진 고르기 실패: $error');
      problem = PhotoPickProblem.unknown;
    }
    if (photo != null) {
      if (photo.sizeBytes > profilePhotoMaxBytes) {
        problem = PhotoPickProblem.tooLarge;
        photo = null;
      } else if (photo.contentType == null) {
        problem = PhotoPickProblem.unsupportedType;
        photo = null;
      }
    }
    if (!ref.mounted) return;
    state = state.copyWith(
      pickingPhoto: false,
      photo: photo ?? state.photo,
      photoProblem: problem,
    );
  }

  /// 이미 올린 사진 (파일 경로 → 저장소 주소). 사진은 올렸는데 저장이 실패해
  /// 다시 누르면 같은 사진을 또 올리지 않는다.
  ({String path, String url})? _uploaded;

  /// 사진 화면의 "다음"·"건너뛰기". 정보가 다 맞지 않거나 저장 중이면 무시한다.
  /// 사진을 골랐으면 먼저 저장소에 올리고, 받은 주소로 프로필을 저장한다.
  /// 성공하면 세션의 `nextStep`이 바뀌고 라우터가 밴드 시작 화면으로 옮긴다.
  Future<void> save() async {
    final current = state;
    if (current.saving || !current.canProceed) return;
    state = current.copyWith(saving: true, failure: null);
    final session = ref.read(sessionProvider.notifier);
    ProfileFailureReason? failure;
    try {
      final draft = ProfileDraft(
        nickname: current.nickname,
        genreCodes: current.genreCodes,
        genreCustomName: current.genreCustomName,
        positionCodes: current.positionCodes,
        positionCustomName: current.positionCustomName,
        // 사진이 없으면 기다리지 않고 바로 저장한다 (건너뛰기 → 기본 이미지).
        profileImageUrl: switch (current.photo) {
          final photo? => await _uploadPhoto(photo),
          null => null,
        },
      );
      final nextStep = await ref
          .read(profileRepositoryProvider)
          .saveProfile(draft);
      await session.updateNextStep(nextStep);
    } on ProfileFailure catch (error) {
      failure = error.reason;
    } on UploadFailure catch (error) {
      failure = error.reason == UploadFailureReason.network
          ? ProfileFailureReason.network
          : ProfileFailureReason.photoUploadFailed;
    } on Exception catch (error) {
      if (kDebugMode) debugPrint('[Profile] 저장 실패: $error');
      failure = ProfileFailureReason.unknown;
    }
    switch (failure) {
      // 서버가 세션을 끝냈다: 토큰을 지우고 로그인 화면으로.
      case ProfileFailureReason.userNotFound:
        await session.signOut();
      // 약관을 건너뛰었다: 로그인 화면의 약관 시트로.
      case ProfileFailureReason.termsRequired:
        await session.updateNextStep(NextStep.terms);
      case _:
    }
    // 성공하면 화면이 바뀌며 이 ViewModel도 정리된다. 남아 있으면 버튼을 풀어 둔다.
    if (!ref.mounted) return;
    state = state.copyWith(
      saving: false,
      failure: failure,
      // 그 사이 다른 사람이 가져갔다: 정보 화면에서 다시 확인해야 한다.
      nicknameCheck: failure == ProfileFailureReason.nicknameTaken
          ? NicknameCheckResult.duplicated
          : state.nicknameCheck,
    );
  }

  /// 사진을 저장소에 올리고 주소를 돌려준다. [pickPhoto]가 형식을 거른 사진만 담으므로
  /// [PickedPhoto.contentType]이 비어 있으면 올리지 않는다.
  Future<String> _uploadPhoto(PickedPhoto photo) async {
    if (_uploaded case (:final path, :final url) when path == photo.path) {
      return url;
    }
    final contentType = photo.contentType;
    if (contentType == null) {
      throw const UploadFailure(UploadFailureReason.rejected);
    }
    final url = await ref
        .read(uploadRepositoryProvider)
        .uploadImage(
          purpose: UploadPurpose.userProfile,
          path: photo.path,
          sizeBytes: photo.sizeBytes,
          contentType: contentType,
        );
    _uploaded = (path: photo.path, url: url);
    return url;
  }

  static List<String> _toggle(List<String> codes, String code) =>
      codes.contains(code)
      ? [
          for (final c in codes)
            if (c != code) c,
        ]
      : [...codes, code];
}
