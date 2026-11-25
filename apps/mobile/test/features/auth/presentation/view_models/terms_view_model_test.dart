import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/network/session_expiry.dart';
import 'package:highfive/core/storage/secure_store.dart';
import 'package:highfive/features/auth/data/repositories/session_repository.dart';
import 'package:highfive/features/auth/data/repositories/terms_repository.dart';
import 'package:highfive/features/auth/data/services/terms_service.dart';
import 'package:highfive/features/auth/models/next_step.dart';
import 'package:highfive/features/auth/models/term.dart';
import 'package:highfive/features/auth/models/terms_failure.dart';
import 'package:highfive/features/auth/presentation/providers/session_providers.dart';
import 'package:highfive/features/auth/presentation/providers/terms_providers.dart';
import 'package:highfive/features/auth/presentation/view_models/session_view_model.dart';
import 'package:highfive/features/auth/presentation/view_models/terms_view_model.dart';

const _terms = [
  Term(id: 1, title: '서비스 이용약관', required: true, contentUrl: 'https://t/1'),
  Term(id: 2, title: '개인정보 수집 및 이용 동의', required: true),
  Term(id: 3, title: '마케팅 정보 수신', required: false),
];

/// 서버 대신 목록·저장 결과를 돌려주고 받은 동의를 기록한다.
/// [save]가 있으면 저장 응답 시점을 테스트가 정하고, [saveError]가 있으면 저장이 실패한다.
class _FakeTermsRepository extends TermsRepository {
  _FakeTermsRepository({this.fetchError, this.save, this.saveError})
    : super(TermsService(Dio()));

  Object? fetchError;
  final Completer<NextStep>? save;
  final Object? saveError;
  int fetchCount = 0;
  final saved = <Set<int>>[];

  @override
  Future<List<Term>> fetchTerms() async {
    fetchCount++;
    if (fetchError case final error?) throw error;
    return _terms;
  }

  @override
  Future<NextStep> saveAgreements(List<Term> terms, Set<int> agreedIds) {
    saved.add(agreedIds);
    if (saveError case final error?) return Future.error(error);
    return save?.future ?? Future.value(NextStep.profile);
  }
}

Future<ProviderContainer> _container(_FakeTermsRepository repository) async {
  FlutterSecureStorage.setMockInitialValues({
    SecureStore.accessTokenKey: 'a',
    SecureStore.nextStepKey: NextStep.terms.name,
  });
  final container = ProviderContainer(
    overrides: [
      termsRepositoryProvider.overrideWithValue(repository),
      sessionExpiryProvider.overrideWithValue(SessionExpiry()),
      sessionRepositoryProvider.overrideWithValue(
        SessionRepository(SecureStore(const FlutterSecureStorage())),
      ),
    ],
  );
  addTearDown(container.dispose);
  // autoDispose라 테스트 동안 구독해 둔다.
  container.listen(termsViewModelProvider, (_, _) {});
  await container.read(sessionProvider.future);
  await container.read(termsViewModelProvider.future);
  return container;
}

TermsState _state(ProviderContainer container) =>
    container.read(termsViewModelProvider).value!;

TermsViewModel _viewModel(ProviderContainer container) =>
    container.read(termsViewModelProvider.notifier);

void main() {
  test('처음 읽을 때 목록을 받고, 아무것도 체크되지 않아 계속할 수 없다', () async {
    final container = await _container(_FakeTermsRepository());

    expect(_state(container).terms, _terms);
    expect(_state(container).agreedIds, isEmpty);
    expect(_state(container).canSubmit, isFalse);
  });

  test('목록을 못 받으면 오류이고, 다시 시도하면 다시 받는다', () async {
    final repository = _FakeTermsRepository(
      fetchError: const TermsFailure(TermsFailureReason.network),
    );
    FlutterSecureStorage.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [termsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(termsViewModelProvider, (_, _) {});

    await expectLater(
      container.read(termsViewModelProvider.future),
      throwsA(isA<TermsFailure>()),
    );

    repository.fetchError = null;
    container.read(termsViewModelProvider.notifier).retry();
    expect(await container.read(termsViewModelProvider.future), isNotNull);
    expect(repository.fetchCount, 2);
  });

  test('약관 하나를 누르면 체크되고 다시 누르면 풀린다', () async {
    final container = await _container(_FakeTermsRepository());

    _viewModel(container).toggle(_terms.first);
    expect(_state(container).isAgreed(_terms.first), isTrue);

    _viewModel(container).toggle(_terms.first);
    expect(_state(container).isAgreed(_terms.first), isFalse);
  });

  test('필수 약관만 모두 체크해도 계속할 수 있고, 전체 동의는 선택까지 다 체크해야 한다', () async {
    final container = await _container(_FakeTermsRepository());

    _viewModel(container).toggle(_terms[0]);
    expect(_state(container).canSubmit, isFalse);

    _viewModel(container).toggle(_terms[1]);
    expect(_state(container).canSubmit, isTrue);
    expect(_state(container).allAgreed, isFalse);
  });

  test('전체 동의는 비어 있으면 모두 체크하고, 모두 체크되어 있으면 모두 푼다', () async {
    final container = await _container(_FakeTermsRepository());
    _viewModel(container).toggle(_terms.first);

    _viewModel(container).toggleAll();
    expect(_state(container).allAgreed, isTrue);

    _viewModel(container).toggleAll();
    expect(_state(container).agreedIds, isEmpty);
  });

  test('필수를 다 고르지 않으면 저장하지 않는다', () async {
    final repository = _FakeTermsRepository();
    final container = await _container(repository);

    await _viewModel(container).submit();

    expect(repository.saved, isEmpty);
  });

  test('저장에 성공하면 세션의 nextStep이 서버가 준 단계로 바뀌고 저장소에도 남는다', () async {
    final repository = _FakeTermsRepository();
    final container = await _container(repository);
    _viewModel(container).toggle(_terms[0]);
    _viewModel(container).toggle(_terms[1]);

    await _viewModel(container).submit();

    expect(repository.saved, [
      {1, 2},
    ]);
    expect(container.read(sessionProvider).value!.nextStep, NextStep.profile);
    final restored = await container.read(sessionRepositoryProvider).restore();
    expect(restored!.nextStep, NextStep.profile);
  });

  test('저장 중에는 다시 눌러도 한 번만 보내고 체크도 바뀌지 않는다', () async {
    final save = Completer<NextStep>();
    final repository = _FakeTermsRepository(save: save);
    final container = await _container(repository);
    _viewModel(container).toggleAll();

    final first = _viewModel(container).submit();
    expect(_state(container).submitting, isTrue);
    unawaited(_viewModel(container).submit());
    _viewModel(container).toggleAll();

    expect(repository.saved, hasLength(1));
    expect(_state(container).allAgreed, isTrue);

    save.complete(NextStep.home);
    await first;
  });

  test('저장에 실패하면 이유를 상태에 담고 버튼을 다시 누를 수 있다', () async {
    final container = await _container(
      _FakeTermsRepository(
        saveError: const TermsFailure(TermsFailureReason.network),
      ),
    );
    _viewModel(container).toggleAll();

    await _viewModel(container).submit();

    expect(_state(container).failure, TermsFailureReason.network);
    expect(_state(container).submitting, isFalse);
    expect(_state(container).allAgreed, isTrue);
    expect(container.read(sessionProvider).value!.nextStep, NextStep.terms);
  });

  test('약관이 바뀌었으면(COMMON_004) 목록을 다시 받는다', () async {
    final repository = _FakeTermsRepository(
      saveError: const TermsFailure(TermsFailureReason.termsChanged),
    );
    final container = await _container(repository);
    _viewModel(container).toggleAll();

    await _viewModel(container).submit();
    await container.read(termsViewModelProvider.future);

    expect(repository.fetchCount, 2);
    expect(_state(container).agreedIds, isEmpty);
  });
}
