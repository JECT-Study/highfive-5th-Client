import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sdk/app_settings.dart';
import '../../../../core/sdk/photo_picker.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_list_row.dart';
import '../../../../shared/widgets/app_progress_bar.dart';
import '../../models/photo_pick_problem.dart';
import '../../models/profile_failure.dart';
import '../view_models/profile_view_model.dart';

/// Figma 사진 원 지름·카메라 버튼 지름 (`2216:139847`·`2216:139848`).
const _avatarSize = 136.0;
const _cameraButtonSize = 44.0;
const _cameraIconSize = 20.0;

/// 카메라 버튼이 원 아래로 나온 만큼 (Figma 버튼 y 97 + 44 − 원 136).
const _cameraButtonOverhang = 5.0;

/// 온보딩 개인 프로필 1단계의 사진 화면 (Figma `2216:139829`). docs/api/profile.md
///
/// 정보 화면 위에 쌓여 같은 [profileViewModelProvider]를 본다.
/// 사진 없이 "건너뛰기"하면 기본 이미지로 저장하고, 성공하면 라우터가 밴드 시작으로 옮긴다.
/// 색은 공통 토큰·위젯을 그대로 쓴다 (시안은 다크 팔레트).
class ProfilePhotoView extends ConsumerWidget {
  const ProfilePhotoView({super.key, required this.onBack});

  /// 정보 화면으로 돌아간다. 저장 때 닉네임이 겹치면 이것으로 돌려보낸다.
  final VoidCallback onBack;

  static const pickButtonKey = ValueKey('profile_pick_photo');
  static const albumKey = ValueKey('profile_photo_album');
  static const cameraKey = ValueKey('profile_photo_camera');
  static const submitButtonKey = ValueKey('profile_photo_submit');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileViewModelProvider);
    final viewModel = ref.read(profileViewModelProvider.notifier);
    final colors = context.colors;
    final textStyles = context.textStyles;

    Future<void> choosePhoto() async {
      final source = await showAppBottomSheet<PhotoSource>(
        context,
        builder: (_) => const _PhotoSourceSheet(),
      );
      if (source != null) await viewModel.pickPhoto(source);
    }

    ref
      ..listen(profileViewModelProvider.select((s) => s.photoProblem), (
        _,
        problem,
      ) {
        if (problem != null) _showPhotoProblem(context, problem, choosePhoto);
      })
      ..listen(profileViewModelProvider, (previous, next) {
        final failure = next.failure;
        if (previous?.saving == true && !next.saving && failure != null) {
          _showSaveFailure(context, failure);
        }
      });

    final photo = state.photo;
    return PopScope(
      // 저장 중에는 뒤로 가지 않는다 (결과가 정보 화면에 늦게 도착하지 않게).
      canPop: !state.saving,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.x5),
                const AppStepProgress(current: 1, total: 3),
                Text(
                  '1 / 3 단계',
                  style: textStyles.caption1Regular.copyWith(
                    color: colors.labelAlternative,
                  ),
                ),
                const SizedBox(height: AppSpacing.x8 + AppSpacing.x4),
                Text(
                  '프로필 사진을 선택해주세요!',
                  style: textStyles.head.copyWith(color: colors.labelNormal),
                ),
                const SizedBox(height: AppSpacing.x3),
                Text(
                  '나중에 언제든 바꿀 수 있어요.',
                  style: textStyles.body1Medium.copyWith(
                    color: colors.labelAlternative,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: AppSpacing.x5,
                      children: [
                        _Avatar(
                          photoPath: photo?.path,
                          onTap: state.saving ? null : choosePhoto,
                        ),
                        Text(
                          state.nickname,
                          textAlign: TextAlign.center,
                          style: textStyles.title1Bold.copyWith(
                            color: colors.labelNormal,
                          ),
                        ),
                        InkWell(
                          key: pickButtonKey,
                          onTap: state.saving ? null : choosePhoto,
                          child: Text(
                            '사진 고르기',
                            style: textStyles.body1Medium.copyWith(
                              color: colors.labelNormal,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.x2),
                  child: Row(
                    spacing: AppSpacing.x2_5,
                    children: [
                      Expanded(
                        child: AppButton(
                          label: '이전',
                          variant: AppButtonVariant.weak,
                          onPressed: state.saving ? null : onBack,
                        ),
                      ),
                      Expanded(
                        child: AppButton(
                          key: submitButtonKey,
                          label: photo == null ? '건너뛰기' : '다음',
                          loading: state.saving,
                          // 사진을 고른 뒤 "다음"은 업로드를 붙이면서 연결한다.
                          onPressed: photo == null ? viewModel.save : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 고르지 못한 이유를 알린다. 용량·형식이면 다시 고르게 하고, 권한이면 설정으로 보낸다.
  static Future<void> _showPhotoProblem(
    BuildContext context,
    PhotoPickProblem problem,
    Future<void> Function() choosePhoto,
  ) async {
    switch (problem) {
      case PhotoPickProblem.tooLarge || PhotoPickProblem.unsupportedType:
        final retry = await showAppDialog(
          context,
          title: '사진을 올릴 수 없어요',
          message: problem == PhotoPickProblem.tooLarge
              ? '사진은 10MB까지 올릴 수 있어요'
              : 'jpg, png, heic 사진만 올릴 수 있어요',
          confirmLabel: '다시 고르기',
          cancelLabel: '닫기',
        );
        if (retry) await choosePhoto();
      case PhotoPickProblem.cameraDenied || PhotoPickProblem.albumDenied:
        final camera = problem == PhotoPickProblem.cameraDenied;
        final openSettings = await showAppDialog(
          context,
          title: camera ? '카메라 권한이 필요해요' : '사진 접근 권한이 필요해요',
          message: camera ? '설정에서 카메라 접근을 허용해 주세요.' : '설정에서 사진 접근을 허용해 주세요.',
          confirmLabel: '설정 열기',
          cancelLabel: '닫기',
        );
        if (openSettings) await openAppSettings();
      case PhotoPickProblem.unknown:
        await showAppDialog(
          context,
          title: '사진을 불러오지 못했어요',
          message: '잠시 후 다시 시도해 주세요.',
          confirmLabel: '확인',
        );
    }
  }

  /// 저장 실패 안내. 약관 미동의·회원 없음은 세션이 바뀌어 라우터가 옮기므로 알리지 않는다.
  Future<void> _showSaveFailure(
    BuildContext context,
    ProfileFailureReason failure,
  ) async {
    final (title, message) = switch (failure) {
      ProfileFailureReason.nicknameTaken => (
        '이미 사용 중인 닉네임이에요',
        '닉네임을 다시 정해 주세요.',
      ),
      ProfileFailureReason.invalidInput => ('저장하지 못했어요', '입력한 정보를 다시 확인해 주세요.'),
      ProfileFailureReason.network => (
        '저장하지 못했어요',
        '네트워크 상태를 확인하고 다시 시도해 주세요.',
      ),
      ProfileFailureReason.unknown => ('저장하지 못했어요', '잠시 후 다시 시도해 주세요.'),
      ProfileFailureReason.termsRequired ||
      ProfileFailureReason.userNotFound => (null, null),
    };
    if (title == null) return;
    await showAppDialog(
      context,
      title: title,
      message: message,
      confirmLabel: '확인',
    );
    // 다른 사람이 가져간 닉네임: 정보 화면에서 다시 확인하게 한다.
    if (failure == ProfileFailureReason.nicknameTaken) onBack();
  }
}

/// 사진 원 + 오른쪽 아래 카메라 버튼. 사진이 없으면 빈 원(기본 이미지)이다.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoPath, required this.onTap});

  final String? photoPath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final photoPath = this.photoPath;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox.square(
        dimension: _avatarSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipOval(
              child: SizedBox.square(
                dimension: _avatarSize,
                child: photoPath == null
                    ? ColoredBox(color: colors.fillStrong)
                    : Image.file(
                        File(photoPath),
                        fit: BoxFit.cover,
                        // 임시 파일이 지워졌으면 빈 원으로 둔다.
                        errorBuilder: (_, _, _) =>
                            ColoredBox(color: colors.fillStrong),
                      ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: -_cameraButtonOverhang,
              child: Container(
                width: _cameraButtonSize,
                height: _cameraButtonSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.lineStrong,
                ),
                child: AppIcon(
                  AppIcons.camera,
                  size: _cameraIconSize,
                  color: colors.labelNormal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 앨범·카메라 중 고르는 시트. 고른 값을 돌려주고 닫힌다.
class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppListRow(
          key: ProfilePhotoView.albumKey,
          title: '앨범에서 선택',
          onTap: () => Navigator.of(context).pop(PhotoSource.album),
        ),
        AppListRow(
          key: ProfilePhotoView.cameraKey,
          title: '사진 찍기',
          onTap: () => Navigator.of(context).pop(PhotoSource.camera),
        ),
      ],
    );
  }
}
