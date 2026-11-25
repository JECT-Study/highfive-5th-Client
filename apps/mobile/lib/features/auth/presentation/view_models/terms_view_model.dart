import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/term.dart';

/// 약관 동의 화면의 상태와 명령.
/// 상세 화면(`/terms/:termId`)이 위에 쌓여도 동의 화면이 남아 있으므로 고른 체크가 유지된다.
final termsViewModelProvider =
    NotifierProvider.autoDispose<TermsViewModel, TermsState>(
      TermsViewModel.new,
    );

/// 약관 동의 화면 상태.
class TermsState {
  const TermsState({required this.terms, this.agreedIds = const {}});

  /// 서버가 준 순서 그대로 (필수 → 선택).
  final List<Term> terms;

  /// 사용자가 동의에 체크한 약관 `id`.
  final Set<int> agreedIds;

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
}

class TermsViewModel extends Notifier<TermsState> {
  // API를 붙이기 전 임시 목록. Figma 시안(1965:11471)과 같은 세 항목이다.
  static const _draftTerms = [
    Term(id: 1, title: '서비스 이용약관', required: true, contentUrl: 'about:blank'),
    Term(
      id: 2,
      title: '개인정보 수집 및 이용 동의',
      required: true,
      contentUrl: 'about:blank',
    ),
    Term(id: 3, title: '만 14세 이상입니다', required: true),
  ];

  @override
  TermsState build() => const TermsState(terms: _draftTerms);

  /// 약관 하나의 체크를 바꾼다.
  void toggle(Term term) {
    final agreedIds = {...state.agreedIds};
    if (!agreedIds.remove(term.id)) agreedIds.add(term.id);
    state = TermsState(terms: state.terms, agreedIds: agreedIds);
  }

  /// 모두 체크되어 있으면 모두 풀고, 하나라도 비어 있으면 모두 체크한다.
  void toggleAll() {
    state = TermsState(
      terms: state.terms,
      agreedIds: state.allAgreed
          ? const {}
          : {for (final term in state.terms) term.id},
    );
  }
}
