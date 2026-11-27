import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_chip_group.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/app_form_section.dart';
import '../../../../shared/widgets/app_progress_bar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../models/nickname_check_result.dart';
import '../../models/profile_failure.dart';
import '../../models/profile_options.dart';
import '../../models/profile_rules.dart';
import '../view_models/profile_view_model.dart';

/// 온보딩 개인 프로필 1단계: 닉네임·선호 장르·연주 포지션
/// (Figma `온보딩-프로필정보 입력1`, node `2216:139626`). docs/api/profile.md
///
/// 색은 공통 토큰·위젯을 그대로 쓴다 (시안은 다크 팔레트, 앱은 아직 라이트 토큰만 있다).
/// "다음"을 누르면 사진 화면이 이 화면 위에 쌓이고, 저장은 사진 화면에서 한 번에 한다.
class ProfileInfoView extends ConsumerStatefulWidget {
  const ProfileInfoView({super.key, required this.onNext});

  /// 정보를 다 채웠다. 라우터가 사진 화면을 위에 쌓는다.
  final VoidCallback onNext;

  static const nicknameFieldKey = ValueKey('profile_nickname');
  static const checkButtonKey = ValueKey('profile_check_nickname');
  static const nicknameMessageKey = ValueKey('profile_nickname_message');
  static const genreCustomFieldKey = ValueKey('profile_genre_custom');
  static const positionCustomFieldKey = ValueKey('profile_position_custom');
  static const nextButtonKey = ValueKey('profile_next');

  /// 서버 결과·입력 규칙별 안내 (docs/api/profile.md "화면 문구").
  static String _nicknameMessage(NicknameCheckResult result) =>
      switch (result) {
        NicknameCheckResult.available => '사용 가능한 닉네임입니다',
        NicknameCheckResult.invalidLength => '닉네임은 2~10자로 입력해 주세요',
        NicknameCheckResult.invalidCharacter => _forbiddenCharacterMessage,
        NicknameCheckResult.duplicated => '이미 사용 중인 닉네임이에요',
        NicknameCheckResult.unavailable => '사용할 수 없는 닉네임이에요',
      };

  static const _forbiddenCharacterMessage = '한글, 영문, 숫자만 쓸 수 있어요';

  static String _failureMessage(ProfileFailureReason reason) =>
      reason == ProfileFailureReason.network
      ? '네트워크 상태를 확인하고 다시 시도해 주세요.'
      : '잠시 후 다시 시도해 주세요.';

  @override
  ConsumerState<ProfileInfoView> createState() => _ProfileInfoViewState();
}

class _ProfileInfoViewState extends ConsumerState<ProfileInfoView> {
  final _nickname = TextEditingController();
  final _genreCustomName = TextEditingController();
  final _positionCustomName = TextEditingController();

  @override
  void dispose() {
    _nickname.dispose();
    _genreCustomName.dispose();
    _positionCustomName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);
    final viewModel = ref.read(profileViewModelProvider.notifier);
    final colors = context.colors;
    final textStyles = context.textStyles;

    // 중복 확인 실패만 여기서 알린다. 저장 실패는 위에 쌓인 사진 화면이 알린다.
    ref.listen(profileViewModelProvider, (previous, next) {
      final failure = next.failure;
      if (previous?.checkingNickname == true &&
          !next.checkingNickname &&
          failure != null) {
        showAppDialog(
          context,
          title: '닉네임을 확인하지 못했어요',
          message: ProfileInfoView._failureMessage(failure),
          confirmLabel: '확인',
        );
      }
    });

    final nicknameMessage = state.nicknameHasForbiddenCharacter
        ? ProfileInfoView._forbiddenCharacterMessage
        : switch (state.nicknameCheck) {
            final result? => ProfileInfoView._nicknameMessage(result),
            null => null,
          };

    return Scaffold(
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.x8 + AppSpacing.x4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '반가워요,\n나를 소개해 주세요!',
                        style: textStyles.head.copyWith(
                          color: colors.labelNormal,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x3),
                      Text(
                        '밴드 활동에 필요한 프로필 정보를 입력해 주세요.',
                        style: textStyles.body1Medium.copyWith(
                          color: colors.labelAlternative,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x8 + AppSpacing.x6),
                      AppFormSection(
                        title: '닉네임',
                        required: true,
                        hint: '2~10자로 설정해주세요.',
                        children: [
                          AppTextField(
                            key: ProfileInfoView.nicknameFieldKey,
                            controller: _nickname,
                            hintText: '이름을 입력해 주세요.',
                            enabled: !state.saving,
                            invalid:
                                nicknameMessage != null &&
                                !state.nicknameAvailable,
                            textInputAction: TextInputAction.done,
                            onChanged: viewModel.changeNickname,
                          ),
                          if (nicknameMessage != null)
                            Text(
                              nicknameMessage,
                              key: ProfileInfoView.nicknameMessageKey,
                              style: textStyles.caption1Regular.copyWith(
                                color: state.nicknameAvailable
                                    ? colors.statusPositive
                                    : colors.statusDestructive,
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: AppButton(
                              key: ProfileInfoView.checkButtonKey,
                              label: '중복 확인',
                              variant: AppButtonVariant.weak,
                              size: AppButtonSize.small,
                              loading: state.checkingNickname,
                              onPressed: state.canCheckNickname
                                  ? viewModel.checkNickname
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.x8),
                      _OptionSection(
                        title: '선호 장르',
                        hint: '여러개 선택할 수 있어요.',
                        options: genreOptions,
                        selectedCodes: state.genreCodes,
                        onToggle: state.saving ? null : viewModel.toggleGenre,
                        customSelected: state.genreCustomSelected,
                        customValue: state.genreCustomName,
                        customFieldKey: ProfileInfoView.genreCustomFieldKey,
                        customController: _genreCustomName,
                        customHint: '장르를 입력해 주세요.',
                        onCustomChanged: viewModel.changeGenreCustomName,
                      ),
                      const SizedBox(height: AppSpacing.x8),
                      _OptionSection(
                        title: '연주 포지션',
                        hint: '우리 팀 포지션을 모두 선택해 주세요.',
                        options: positionOptions,
                        selectedCodes: state.positionCodes,
                        onToggle: state.saving
                            ? null
                            : viewModel.togglePosition,
                        customSelected: state.positionCustomSelected,
                        customValue: state.positionCustomName,
                        customFieldKey: ProfileInfoView.positionCustomFieldKey,
                        customController: _positionCustomName,
                        customHint: '포지션을 입력해 주세요.',
                        onCustomChanged: viewModel.changePositionCustomName,
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
                    // 앞 단계(약관 동의)로는 되돌릴 수 없다. 동작은 기획 확인 후 정하고 그때까지 막아 둔다.
                    const Expanded(
                      child: AppButton(
                        label: '이전',
                        variant: AppButtonVariant.weak,
                        onPressed: null,
                      ),
                    ),
                    Expanded(
                      child: AppButton(
                        key: ProfileInfoView.nextButtonKey,
                        label: '다음',
                        onPressed: state.canProceed ? widget.onNext : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 장르·포지션 항목: 칩 묶음과, "직접입력"을 고르면 나오는 입력칸.
class _OptionSection extends StatelessWidget {
  const _OptionSection({
    required this.title,
    required this.hint,
    required this.options,
    required this.selectedCodes,
    required this.onToggle,
    required this.customSelected,
    required this.customValue,
    required this.customFieldKey,
    required this.customController,
    required this.customHint,
    required this.onCustomChanged,
  });

  final String title;
  final String hint;
  final List<ProfileOption> options;
  final List<String> selectedCodes;
  final ValueChanged<String>? onToggle;
  final bool customSelected;
  final String customValue;
  final Key customFieldKey;
  final TextEditingController customController;
  final String customHint;
  final ValueChanged<String> onCustomChanged;

  /// 직접입력 값이 규칙에 어긋나면 안내. 비어 있으면 "다음"만 막고 안내는 하지 않는다.
  String? get _customMessage {
    final value = customValue.trim();
    if (value.isEmpty || isValidCustomName(value)) return null;
    return value.length > customNameMaxLength
        ? '$customNameMaxLength자까지 쓸 수 있어요'
        : ProfileInfoView._forbiddenCharacterMessage;
  }

  @override
  Widget build(BuildContext context) {
    final onToggle = this.onToggle;
    final customMessage = customSelected ? _customMessage : null;
    return AppFormSection(
      title: title,
      required: true,
      hint: hint,
      children: [
        AppChipGroup(
          labels: [for (final option in options) option.label],
          selectedIndexes: {
            for (final (i, option) in options.indexed)
              if (selectedCodes.contains(option.code)) i,
          },
          onTap: onToggle == null ? null : (i) => onToggle(options[i].code),
        ),
        if (customSelected)
          AppTextField(
            key: customFieldKey,
            controller: customController,
            hintText: customHint,
            invalid: customMessage != null,
            textInputAction: TextInputAction.done,
            onChanged: onCustomChanged,
          ),
        if (customMessage != null)
          Text(
            customMessage,
            style: context.textStyles.caption1Regular.copyWith(
              color: context.colors.statusDestructive,
            ),
          ),
      ],
    );
  }
}
