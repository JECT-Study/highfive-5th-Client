import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_component_tokens.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/app_selection_controls.dart';
import '../../models/term.dart';
import '../../models/terms_failure.dart';
import '../view_models/terms_view_model.dart';

/// 약관 동의 BottomSheet 내용 (Figma `로그인_약관동의_선택_컴포넌트`, node `1965:11471`).
/// 로그인 화면이 `showAppBottomSheet`로 띄운다. 손잡이·흰 판·여백은 `AppBottomSheet`가 그린다.
class TermsAgreementSheet extends ConsumerWidget {
  const TermsAgreementSheet({super.key, required this.onViewTerm});

  /// "보기"를 눌렀다. 약관 상세는 시트 위에 쌓인다.
  final ValueChanged<Term> onViewTerm;

  static const allKey = ValueKey('terms_all');
  static ValueKey<String> termKey(Term term) => ValueKey('terms_${term.id}');
  static const submitKey = ValueKey('terms_submit');
  static const retryKey = ValueKey('terms_retry');

  static String _failureMessage(TermsFailureReason reason) => switch (reason) {
    TermsFailureReason.network => '네트워크 상태를 확인하고 다시 시도해 주세요.',
    TermsFailureReason.termsChanged => '약관이 바뀌었어요. 다시 확인해 주세요.',
    TermsFailureReason.unknown => '잠시 후 다시 시도해 주세요.',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(termsViewModelProvider);
    final viewModel = ref.read(termsViewModelProvider.notifier);
    // 다시 받는 중에도 이전 목록이 있으면 그대로 보여 준다.
    final data = state.value;

    ref.listen(termsViewModelProvider.select((state) => state.value?.failure), (
      _,
      failure,
    ) {
      // 오류 안내 시안이 아직 없어 공통 Dialog로 알린다. 문구는 docs/api/terms.md "에러".
      if (failure != null) {
        showAppDialog(
          context,
          title: '약관 동의를 저장하지 못했어요',
          message: _failureMessage(failure),
          confirmLabel: '확인',
        );
      }
    });

    // 동의 없이 나가는 동작은 기획 확인 전이라 뒤로 가기로도 닫히지 않게 한다.
    // 바깥 누르기·끌어내리기는 띄우는 쪽(`showAppBottomSheet`)이 막는다.
    return PopScope(
      canPop: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppBottomSheetTokens.gap,
        children: [
          const AppModalHeader(title: '서비스 이용을 위해\n약관에 동의해 주세요'),
          if (data != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.x1_5,
              children: [
                _TermRow(
                  key: allKey,
                  label: '전체 동의하기',
                  checked: data.allAgreed,
                  highlighted: true,
                  onTap: viewModel.toggleAll,
                ),
                for (final term in data.terms)
                  _TermRow(
                    key: termKey(term),
                    label: '${term.required ? '[필수]' : '[선택]'} ${term.title}',
                    checked: data.isAgreed(term),
                    onTap: () => viewModel.toggle(term),
                    onView: term.contentUrl == null
                        ? null
                        : () => onViewTerm(term),
                  ),
              ],
            )
          else if (state.hasError && !state.isLoading)
            _LoadFailure(
              message: _failureMessage(switch (state.error) {
                TermsFailure(:final reason) => reason,
                _ => TermsFailureReason.unknown,
              }),
              onRetry: viewModel.retry,
            )
          else
            const _Loading(),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              key: submitKey,
              label: '동의하고 계속하기',
              loading: data?.submitting ?? false,
              onPressed: (data?.canSubmit ?? false) ? viewModel.submit : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// 약관 목록을 받는 중.
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x8),
      child: Center(
        child: CircularProgressIndicator(color: context.colors.labelAssistive),
      ),
    );
  }
}

/// 약관 목록을 받지 못했다. 안내와 "다시 시도".
class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.x3,
      children: [
        Text(
          '약관을 불러오지 못했어요.\n$message',
          textAlign: TextAlign.center,
          style: context.textStyles.body1Regular.copyWith(
            color: context.colors.labelNeutral,
          ),
        ),
        AppButton(
          key: TermsAgreementSheet.retryKey,
          label: '다시 시도',
          variant: AppButtonVariant.weak,
          size: AppButtonSize.medium,
          onPressed: onRetry,
        ),
      ],
    );
  }
}

/// 약관 한 줄: 동그란 체크 + 제목 + "보기".
/// Figma는 `ListRow`지만 높이·여백을 바꿔 써서 `AppListRow` 대신 따로 그린다.
/// 체크는 줄의 왼쪽 부분 어디를 눌러도 바뀌고, "보기"는 따로 눌린다.
class _TermRow extends StatelessWidget {
  const _TermRow({
    super.key,
    required this.label,
    required this.checked,
    required this.onTap,
    this.onView,
    this.highlighted = false,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  /// null이면 "보기"를 보이지 않는다.
  final VoidCallback? onView;

  /// "전체 동의하기"처럼 회색 바탕을 깐다.
  final bool highlighted;

  /// Figma SuffixIcon 자리 ("보기"를 누르는 영역).
  static const _viewSize = 44.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted ? colors.fillNormal : null,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x1_5),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                checked: checked,
                label: label,
                onTap: onTap,
                child: ExcludeSemantics(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTap,
                    child: Row(
                      spacing: AppListRowTokens.gap,
                      children: [
                        // 모양만 빌려 쓴다. 누르기·접근성은 이 줄이 맡는다.
                        SizedBox.square(
                          dimension: AppListRowTokens.iconSize,
                          child: AppRadio(selected: checked, onTap: null),
                        ),
                        Expanded(
                          child: Text(
                            label,
                            style: textStyles.title2SemiBold.copyWith(
                              color: colors.labelNormal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (onView != null)
              Semantics(
                button: true,
                label: '$label 보기',
                child: ExcludeSemantics(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onView,
                    child: SizedBox.square(
                      dimension: _viewSize,
                      child: Center(
                        child: Text(
                          '보기',
                          style: textStyles.caption1Regular.copyWith(
                            color: colors.labelAlternative,
                            decoration: TextDecoration.underline,
                            decorationColor: colors.labelAlternative,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
