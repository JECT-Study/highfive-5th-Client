import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/term.dart';
import '../../models/terms_failure.dart';
import '../providers/terms_providers.dart';
import 'session_view_model.dart';

/// 약관 동의 시트의 상태와 명령.
///
/// 처음 읽을 때 약관 목록을 받는다 (로딩·오류는 `AsyncValue`, 다시 받기는 [TermsViewModel.retry]).
/// 상세 화면(`/terms/:termId`)이 위에 쌓여도 시트가 남아 있으므로 고른 체크가 유지된다.
///
/// Riverpod 자동 재시도는 끈다. 실패하면 바로 안내하고 사용자가 "다시 시도"를 누른다.
final termsViewModelProvider =
    AsyncNotifierProvider.autoDispose<TermsViewModel, TermsState>(
      TermsViewModel.new,
      retry: (_, _) => null,
    );

/// 약관 목록을 받은 뒤의 시트 상태.
class TermsState {
  const TermsState({
    required this.terms,
    this.agreedIds = const {},
    this.submitting = false,
    this.failure,
  });

  /// 서버가 준 순서 그대로 (필수 → 선택).
  final List<Term> terms;

  /// 사용자가 동의에 체크한 약관 `id`.
  final Set<int> agreedIds;

  /// 동의를 저장하는 중. 버튼은 로딩으로 보이고 다시 눌리지 않는다.
  final bool submitting;

  /// 마지막 저장이 실패한 이유. 화면은 이 값이 생길 때 안내를 띄운다.
  final TermsFailureReason? failure;

  bool isAgreed(Term term) => agreedIds.contains(term.id);

  /// "전체 동의하기"가 체크되어 보이는지. 약관이 하나도 없으면 false.
  bool get allAgreed =>
      terms.isNotEmpty && terms.every((term) => agreedIds.contains(term.id));

  /// 필수 약관에 모두 동의해야 "동의하고 계속하기"를 누를 수 있다.
  /// 서버도 `USER_003`으로 한 번 더 막는다.
  bool get canSubmit =>
      terms.isNotEmpty &&
      terms
          .where((term) => term.required)
          .every((term) => agreedIds.contains(term.id));

  TermsState _with({Set<int>? agreedIds, bool? submitting}) => TermsState(
    terms: terms,
    agreedIds: agreedIds ?? this.agreedIds,
    submitting: submitting ?? this.submitting,
  );
}

class TermsViewModel extends AsyncNotifier<TermsState> {
  @override
  Future<TermsState> build() async {
    final terms = await ref.read(termsRepositoryProvider).fetchTerms();
    return TermsState(terms: terms);
  }

  /// 목록을 못 받았을 때 "다시 시도".
  void retry() => ref.invalidateSelf();

  /// 약관 하나의 체크를 바꾼다. 저장 중에는 무시한다.
  void toggle(Term term) {
    final current = state.value;
    if (current == null || current.submitting) return;
    final agreedIds = {...current.agreedIds};
    if (!agreedIds.remove(term.id)) agreedIds.add(term.id);
    state = AsyncData(current._with(agreedIds: agreedIds));
  }

  /// 모두 체크되어 있으면 모두 풀고, 하나라도 비어 있으면 모두 체크한다.
  void toggleAll() {
    final current = state.value;
    if (current == null || current.submitting) return;
    state = AsyncData(
      current._with(
        agreedIds: current.allAgreed
            ? const {}
            : {for (final term in current.terms) term.id},
      ),
    );
  }

  /// 동의를 저장한다. 필수를 다 고르지 않았거나 저장 중이면 무시한다.
  /// 성공하면 세션의 `nextStep`이 바뀌고 라우터가 다음 화면으로 옮긴다 (시트도 같이 닫힌다).
  /// 보낸 약관이 최신이 아니면(`COMMON_004`) 안내한 뒤 목록을 다시 받는다.
  Future<void> submit() async {
    final current = state.value;
    if (current == null || current.submitting || !current.canSubmit) return;
    state = AsyncData(current._with(submitting: true));
    final result = await AsyncValue.guard(() async {
      final nextStep = await ref
          .read(termsRepositoryProvider)
          .saveAgreements(current.terms, current.agreedIds);
      await ref.read(sessionProvider.notifier).updateNextStep(nextStep);
    });
    if (kDebugMode && result.hasError) {
      debugPrint('[Terms] 동의 저장 실패: ${result.error}');
    }
    // 성공하면 화면이 바뀌며 이 ViewModel도 정리된다. 남아 있으면 버튼을 풀어 둔다.
    if (!ref.mounted) return;
    final failure = switch (result.error) {
      null => null,
      TermsFailure(:final reason) => reason,
      _ => TermsFailureReason.unknown,
    };
    state = AsyncData(
      TermsState(
        terms: current.terms,
        agreedIds: current.agreedIds,
        failure: failure,
      ),
    );
    // 약관이 바뀌었다: 안내(화면이 failure를 보고 띄운다)와 함께 최신 목록을 다시 받는다.
    if (failure == TermsFailureReason.termsChanged) ref.invalidateSelf();
  }
}
