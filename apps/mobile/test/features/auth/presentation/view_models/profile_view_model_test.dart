import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/network/session_expiry.dart';
import 'package:highfive/core/storage/secure_store.dart';
import 'package:highfive/features/auth/data/repositories/profile_repository.dart';
import 'package:highfive/features/auth/data/repositories/session_repository.dart';
import 'package:highfive/features/auth/data/services/profile_service.dart';
import 'package:highfive/features/auth/models/next_step.dart';
import 'package:highfive/features/auth/models/nickname_check_result.dart';
import 'package:highfive/features/auth/models/profile_draft.dart';
import 'package:highfive/features/auth/models/profile_failure.dart';
import 'package:highfive/features/auth/presentation/providers/profile_providers.dart';
import 'package:highfive/features/auth/presentation/providers/session_providers.dart';
import 'package:highfive/features/auth/presentation/view_models/profile_view_model.dart';
import 'package:highfive/features/auth/presentation/view_models/session_view_model.dart';

/// 서버 대신 확인·저장 결과를 돌려주고 받은 요청을 기록한다.
/// [check]·[save]가 있으면 응답 시점을 테스트가 정하고, [saveError]가 있으면 저장이 실패한다.
class _FakeProfileRepository extends ProfileRepository {
  _FakeProfileRepository({this.check, this.save, this.saveError})
    : super(ProfileService(Dio()));

  final Completer<NicknameCheckResult>? check;
  final Completer<NextStep>? save;
  final Object? saveError;
  final checked = <String>[];
  final saved = <ProfileDraft>[];

  @override
  Future<NicknameCheckResult> checkNickname(String nickname) {
    checked.add(nickname);
    return check?.future ?? Future.value(NicknameCheckResult.available);
  }

  @override
  Future<NextStep> saveProfile(ProfileDraft draft) {
    saved.add(draft);
    if (saveError case final error?) return Future.error(error);
    return save?.future ?? Future.value(NextStep.bandStart);
  }
}

Future<ProviderContainer> _container(_FakeProfileRepository repository) async {
  FlutterSecureStorage.setMockInitialValues({
    SecureStore.accessTokenKey: 'a',
    SecureStore.nextStepKey: NextStep.profile.name,
  });
  final container = ProviderContainer(
    overrides: [
      profileRepositoryProvider.overrideWithValue(repository),
      sessionExpiryProvider.overrideWithValue(SessionExpiry()),
      sessionRepositoryProvider.overrideWithValue(
        SessionRepository(SecureStore(const FlutterSecureStorage())),
      ),
    ],
  );
  addTearDown(container.dispose);
  // autoDispose라 테스트 동안 구독해 둔다.
  container.listen(profileViewModelProvider, (_, _) {});
  await container.read(sessionProvider.future);
  return container;
}

ProfileState _state(ProviderContainer container) =>
    container.read(profileViewModelProvider);

ProfileViewModel _viewModel(ProviderContainer container) =>
    container.read(profileViewModelProvider.notifier);

/// 닉네임 확인을 통과하고 장르·포지션을 하나씩 고른 상태.
Future<ProviderContainer> _filled(_FakeProfileRepository repository) async {
  final container = await _container(repository);
  _viewModel(container)
    ..changeNickname('두현')
    ..toggleGenre('ROCK')
    ..togglePosition('VOCAL');
  await _viewModel(container).checkNickname();
  return container;
}

void main() {
  group('닉네임', () {
    test('허용하지 않는 문자가 있으면 바로 표시하고 확인할 수 없다', () async {
      final container = await _container(_FakeProfileRepository());

      for (final nickname in ['두 현', 'rock!', '🎸']) {
        _viewModel(container).changeNickname(nickname);
        expect(_state(container).nicknameHasForbiddenCharacter, isTrue);
        expect(_state(container).canCheckNickname, isFalse);
      }
    });

    test('한글 조합 중인 자음·모음은 안내하지 않지만 확인하면 서버에 묻지 않고 막는다', () async {
      final repository = _FakeProfileRepository();
      final container = await _container(repository);

      _viewModel(container).changeNickname('두ㅎ');
      expect(_state(container).nicknameHasForbiddenCharacter, isFalse);

      await _viewModel(container).checkNickname();
      expect(
        _state(container).nicknameCheck,
        NicknameCheckResult.invalidCharacter,
      );
      expect(repository.checked, isEmpty);
    });

    test('2~10자가 아니면 서버에 묻지 않고 길이 오류로 둔다', () async {
      final repository = _FakeProfileRepository();
      final container = await _container(repository);

      for (final nickname in ['두', '가나다라마바사아자차카']) {
        _viewModel(container).changeNickname(nickname);
        await _viewModel(container).checkNickname();
        expect(
          _state(container).nicknameCheck,
          NicknameCheckResult.invalidLength,
        );
      }
      expect(repository.checked, isEmpty);
    });

    test('확인을 통과한 뒤 닉네임을 고치면 다시 확인해야 한다', () async {
      final container = await _container(_FakeProfileRepository());
      _viewModel(container).changeNickname('Rock');
      await _viewModel(container).checkNickname();
      expect(_state(container).nicknameAvailable, isTrue);
      expect(_state(container).canCheckNickname, isFalse);

      _viewModel(container).changeNickname('rock');

      expect(_state(container).nicknameCheck, isNull);
      expect(_state(container).canCheckNickname, isTrue);
    });

    test('확인하는 사이 닉네임을 고치면 늦게 온 결과는 버린다', () async {
      final check = Completer<NicknameCheckResult>();
      final container = await _container(_FakeProfileRepository(check: check));
      _viewModel(container).changeNickname('두현');

      final checking = _viewModel(container).checkNickname();
      expect(_state(container).checkingNickname, isTrue);
      _viewModel(container).changeNickname('두현이');
      check.complete(NicknameCheckResult.available);
      await checking;

      expect(_state(container).nicknameCheck, isNull);
      expect(_state(container).checkingNickname, isFalse);
    });
  });

  group('장르·포지션', () {
    test('칩을 누르면 고른 순서대로 담고 다시 누르면 뺀다', () async {
      final container = await _container(_FakeProfileRepository());

      _viewModel(container)
        ..toggleGenre('POP')
        ..toggleGenre('ROCK')
        ..toggleGenre('JAZZ')
        ..toggleGenre('ROCK');

      expect(_state(container).genreCodes, ['POP', 'JAZZ']);
    });

    test('닉네임 확인·장르·포지션을 모두 채워야 다음으로 갈 수 있다', () async {
      final container = await _container(_FakeProfileRepository());
      _viewModel(container).changeNickname('두현');
      await _viewModel(container).checkNickname();
      expect(_state(container).canProceed, isFalse);

      _viewModel(container).toggleGenre('ROCK');
      expect(_state(container).canProceed, isFalse);

      _viewModel(container).togglePosition('VOCAL');
      expect(_state(container).canProceed, isTrue);
    });

    test('직접입력을 골랐으면 그 값이 1~10자 한글·영문·숫자여야 한다', () async {
      final container = await _filled(_FakeProfileRepository());

      _viewModel(container).togglePosition(ProfileDraft.positionCustomCode);
      expect(_state(container).canProceed, isFalse);

      for (final (value, valid) in [
        ('   ', false),
        ('하모니카!', false),
        ('가나다라마바사아자차카', false),
        (' 하모니카 ', true),
      ]) {
        _viewModel(container).changePositionCustomName(value);
        expect(_state(container).canProceed, valid, reason: value);
      }
    });
  });

  group('저장', () {
    test('다 채우지 않았으면 저장하지 않는다', () async {
      final repository = _FakeProfileRepository();
      final container = await _container(repository);

      await _viewModel(container).save();

      expect(repository.saved, isEmpty);
    });

    test('입력과 사진 주소를 보내고, 성공하면 세션의 nextStep이 바뀐다', () async {
      final repository = _FakeProfileRepository();
      final container = await _filled(repository);

      await _viewModel(container).save(profileImageUrl: 'https://cdn.test/a');

      expect(repository.saved.single.nickname, '두현');
      expect(repository.saved.single.genreCodes, ['ROCK']);
      expect(repository.saved.single.positionCodes, ['VOCAL']);
      expect(repository.saved.single.profileImageUrl, 'https://cdn.test/a');
      expect(
        container.read(sessionProvider).value!.nextStep,
        NextStep.bandStart,
      );
    });

    test('저장 중에는 다시 눌러도 한 번만 보내고 입력도 바뀌지 않는다', () async {
      final save = Completer<NextStep>();
      final repository = _FakeProfileRepository(save: save);
      final container = await _filled(repository);

      final first = _viewModel(container).save();
      expect(_state(container).saving, isTrue);
      unawaited(_viewModel(container).save());
      _viewModel(container)
        ..changeNickname('다른이름')
        ..toggleGenre('POP');

      expect(repository.saved, hasLength(1));
      expect(_state(container).nickname, '두현');
      expect(_state(container).genreCodes, ['ROCK']);

      save.complete(NextStep.bandStart);
      await first;
    });

    test('그 사이 다른 사람이 닉네임을 가져갔으면 중복으로 되돌린다', () async {
      final container = await _filled(
        _FakeProfileRepository(
          saveError: const ProfileFailure(ProfileFailureReason.nicknameTaken),
        ),
      );

      await _viewModel(container).save();

      expect(_state(container).failure, ProfileFailureReason.nicknameTaken);
      expect(_state(container).nicknameCheck, NicknameCheckResult.duplicated);
      expect(_state(container).canProceed, isFalse);
      expect(_state(container).saving, isFalse);
    });

    test('약관 미동의면 세션을 약관 단계로 되돌린다', () async {
      final container = await _filled(
        _FakeProfileRepository(
          saveError: const ProfileFailure(ProfileFailureReason.termsRequired),
        ),
      );

      await _viewModel(container).save();

      expect(container.read(sessionProvider).value!.nextStep, NextStep.terms);
    });

    test('회원이 없으면 로그아웃한다', () async {
      final container = await _filled(
        _FakeProfileRepository(
          saveError: const ProfileFailure(ProfileFailureReason.userNotFound),
        ),
      );

      await _viewModel(container).save();

      expect(container.read(sessionProvider).value, isNull);
    });

    test('연결 실패면 이유를 담고 다시 누를 수 있다', () async {
      final container = await _filled(
        _FakeProfileRepository(
          saveError: const ProfileFailure(ProfileFailureReason.network),
        ),
      );

      await _viewModel(container).save();

      expect(_state(container).failure, ProfileFailureReason.network);
      expect(_state(container).saving, isFalse);
      expect(_state(container).canProceed, isTrue);
    });
  });
}
