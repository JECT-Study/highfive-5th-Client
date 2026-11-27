import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:highfive/core/network/session_expiry.dart';
import 'package:highfive/core/sdk/photo_picker.dart';
import 'package:highfive/core/storage/secure_store.dart';
import 'package:highfive/features/auth/data/repositories/profile_repository.dart';
import 'package:highfive/features/auth/data/repositories/session_repository.dart';
import 'package:highfive/features/auth/data/services/profile_service.dart';
import 'package:highfive/features/auth/models/next_step.dart';
import 'package:highfive/features/auth/models/nickname_check_result.dart';
import 'package:highfive/features/auth/models/photo_pick_problem.dart';
import 'package:highfive/features/auth/models/profile_draft.dart';
import 'package:highfive/features/auth/models/profile_failure.dart';
import 'package:highfive/features/auth/presentation/providers/profile_providers.dart';
import 'package:highfive/features/auth/presentation/providers/session_providers.dart';
import 'package:highfive/features/auth/presentation/view_models/profile_view_model.dart';
import 'package:highfive/features/auth/presentation/view_models/session_view_model.dart';
import 'package:highfive/features/uploads/data/repositories/upload_repository.dart';
import 'package:highfive/features/uploads/data/services/upload_service.dart';
import 'package:highfive/features/uploads/models/upload_failure.dart';
import 'package:highfive/features/uploads/models/upload_purpose.dart';

/// 서버 대신 확인·저장 결과를 돌려주고 받은 요청을 기록한다.
/// [check]·[save]가 있으면 응답 시점을 테스트가 정하고, [saveError]가 있으면 저장이 실패한다.
class _FakeProfileRepository extends ProfileRepository {
  _FakeProfileRepository({this.check, this.save, this.saveError})
    : super(ProfileService(Dio()));

  final Completer<NicknameCheckResult>? check;
  final Completer<NextStep>? save;
  final Object? saveError;

  /// 있으면 닉네임 확인이 이것으로 실패한다.
  Object? checkError;
  final checked = <String>[];
  final saved = <ProfileDraft>[];

  @override
  Future<NicknameCheckResult> checkNickname(String nickname) {
    checked.add(nickname);
    if (checkError case final error?) return Future.error(error);
    return check?.future ?? Future.value(NicknameCheckResult.available);
  }

  @override
  Future<NextStep> saveProfile(ProfileDraft draft) {
    saved.add(draft);
    if (saveError case final error?) return Future.error(error);
    return save?.future ?? Future.value(NextStep.bandStart);
  }
}

/// 사진 선택기 대신 [result]를 돌려준다. [error]가 있으면 그것을 던진다.
class _FakePhotoPicker extends PhotoPicker {
  _FakePhotoPicker() : super(ImagePicker());

  PickedPhoto? result;
  Object? error;
  final sources = <PhotoSource>[];

  @override
  Future<PickedPhoto?> pick(PhotoSource source) async {
    sources.add(source);
    if (error case final error?) throw error;
    return result;
  }
}

PickedPhoto _photo({
  int sizeBytes = 1024,
  String? contentType = 'image/jpeg',
}) => PickedPhoto(
  path: '/tmp/a.jpg',
  sizeBytes: sizeBytes,
  contentType: contentType,
);

/// 저장소 대신 [fileUrl]을 돌려주고 올린 파일 경로를 기록한다. [error]가 있으면 실패한다.
class _FakeUploadRepository extends UploadRepository {
  _FakeUploadRepository() : super(UploadService(Dio(), Dio()));

  Object? error;
  final uploaded = <String>[];

  static const fileUrl = 'https://cdn.test/users/12/profile/a.jpg';

  @override
  Future<String> uploadImage({
    required UploadPurpose purpose,
    required String path,
    required int sizeBytes,
    required String contentType,
  }) async {
    uploaded.add(path);
    if (error case final error?) throw error;
    return fileUrl;
  }
}

Future<ProviderContainer> _container(
  _FakeProfileRepository repository, [
  _FakePhotoPicker? picker,
  _FakeUploadRepository? upload,
]) async {
  FlutterSecureStorage.setMockInitialValues({
    SecureStore.accessTokenKey: 'a',
    SecureStore.nextStepKey: NextStep.profile.name,
  });
  final container = ProviderContainer(
    overrides: [
      profileRepositoryProvider.overrideWithValue(repository),
      photoPickerProvider.overrideWithValue(picker ?? _FakePhotoPicker()),
      uploadRepositoryProvider.overrideWithValue(
        upload ?? _FakeUploadRepository(),
      ),
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
Future<ProviderContainer> _filled(
  _FakeProfileRepository repository, [
  _FakePhotoPicker? picker,
  _FakeUploadRepository? upload,
]) async {
  final container = await _container(repository, picker, upload);
  _viewModel(container)
    ..changeNickname('두현')
    ..toggleGenre('ROCK')
    ..togglePosition('VOCAL');
  await _viewModel(container).checkNickname();
  return container;
}

void main() {
  group('닉네임 형식 검사 (입력이 멈추면)', () {
    const delay = ProfileViewModel.nicknameValidationDelay;
    const tick = Duration(milliseconds: 1);

    test('입력이 멈춘 뒤에만 안내하고, 서버에는 묻지 않는다', () async {
      final repository = _FakeProfileRepository();
      final container = await _container(repository);

      fakeAsync((async) {
        _viewModel(container).changeNickname('rock!');
        async.elapse(delay - tick);
        expect(_state(container).nicknameCheck, isNull);

        async.elapse(tick);
        expect(
          _state(container).nicknameCheck,
          NicknameCheckResult.invalidCharacter,
        );
        expect(repository.checked, isEmpty);
      });
    });

    test('입력 중에 다시 쓰면 기다리는 시간이 처음부터 다시 시작된다', () async {
      final container = await _container(_FakeProfileRepository());

      fakeAsync((async) {
        _viewModel(container).changeNickname('두');
        async.elapse(delay - tick);
        _viewModel(container).changeNickname('두 ');
        async.elapse(delay - tick);
        expect(_state(container).nicknameCheck, isNull);

        async.elapse(tick);
        expect(
          _state(container).nicknameCheck,
          NicknameCheckResult.invalidCharacter,
        );
      });
    });

    test('공백·특수문자·이모지·조합이 끝나지 않은 자음·모음은 글자 오류다', () async {
      final container = await _container(_FakeProfileRepository());

      fakeAsync((async) {
        for (final nickname in ['두 현', 'rock!', '🎸', '두ㅎ']) {
          _viewModel(container).changeNickname(nickname);
          async.elapse(delay);
          expect(
            _state(container).nicknameCheck,
            NicknameCheckResult.invalidCharacter,
            reason: nickname,
          );
          expect(_state(container).canCheckNickname, isFalse);
        }
      });
    });

    test('2~10자가 아니면 길이 오류다', () async {
      final container = await _container(_FakeProfileRepository());

      fakeAsync((async) {
        for (final nickname in ['두', '가나다라마바사아자차카']) {
          _viewModel(container).changeNickname(nickname);
          async.elapse(delay);
          expect(
            _state(container).nicknameCheck,
            NicknameCheckResult.invalidLength,
            reason: nickname,
          );
        }
      });
    });

    test('형식이 맞으면 안내 없이 중복 확인을 누를 수 있게 된다', () async {
      final repository = _FakeProfileRepository();
      final container = await _container(repository);

      fakeAsync((async) {
        _viewModel(container).changeNickname('Rock2');
        async.elapse(delay);

        expect(_state(container).nicknameCheck, isNull);
        expect(_state(container).canCheckNickname, isTrue);
        expect(repository.checked, isEmpty);
      });
    });
  });

  group('중복 확인 (버튼)', () {
    test('형식이 틀리면 누를 수 없고 서버에 묻지 않는다', () async {
      final repository = _FakeProfileRepository();
      final container = await _container(repository);
      _viewModel(container).changeNickname('두');

      await _viewModel(container).checkNickname();

      expect(_state(container).canCheckNickname, isFalse);
      expect(repository.checked, isEmpty);
    });

    test('누르면 서버에 묻고 결과를 담는다', () async {
      final repository = _FakeProfileRepository();
      final container = await _container(repository);
      _viewModel(container).changeNickname('두현');

      await _viewModel(container).checkNickname();

      expect(repository.checked, ['두현']);
      expect(_state(container).nicknameAvailable, isTrue);
      expect(_state(container).canCheckNickname, isFalse);
    });

    test('확인하지 못하면 이유를 따로 담고, 다시 누를 수 있다', () async {
      final repository = _FakeProfileRepository()
        ..checkError = const ProfileFailure(ProfileFailureReason.network);
      final container = await _container(repository);
      _viewModel(container).changeNickname('두현');

      await _viewModel(container).checkNickname();
      expect(
        _state(container).nicknameCheckFailure,
        ProfileFailureReason.network,
      );
      expect(_state(container).failure, isNull);
      expect(_state(container).canCheckNickname, isTrue);

      repository.checkError = null;
      await _viewModel(container).checkNickname();
      expect(_state(container).nicknameCheckFailure, isNull);
      expect(_state(container).nicknameAvailable, isTrue);
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

  group('사진', () {
    test('고른 사진을 담는다', () async {
      final picker = _FakePhotoPicker()..result = _photo();
      final container = await _container(_FakeProfileRepository(), picker);

      await _viewModel(container).pickPhoto(PhotoSource.camera);

      expect(picker.sources, [PhotoSource.camera]);
      expect(_state(container).photo?.path, '/tmp/a.jpg');
      expect(_state(container).photoProblem, isNull);
      expect(_state(container).pickingPhoto, isFalse);
    });

    test('취소하면 이전 사진을 그대로 둔다', () async {
      final picker = _FakePhotoPicker()..result = _photo();
      final container = await _container(_FakeProfileRepository(), picker);
      await _viewModel(container).pickPhoto(PhotoSource.album);

      picker.result = null;
      await _viewModel(container).pickPhoto(PhotoSource.album);

      expect(_state(container).photo, isNotNull);
      expect(_state(container).photoProblem, isNull);
    });

    test('10MB를 넘거나 받지 않는 형식이면 고르지 않고 이유를 담는다', () async {
      final picker = _FakePhotoPicker();
      final container = await _container(_FakeProfileRepository(), picker);

      for (final (photo, problem) in [
        (_photo(sizeBytes: 10 * 1024 * 1024 + 1), PhotoPickProblem.tooLarge),
        (_photo(contentType: null), PhotoPickProblem.unsupportedType),
      ]) {
        picker.result = photo;
        await _viewModel(container).pickPhoto(PhotoSource.album);

        expect(_state(container).photo, isNull);
        expect(_state(container).photoProblem, problem);
      }
    });

    test('딱 10MB는 올릴 수 있다', () async {
      final picker = _FakePhotoPicker()
        ..result = _photo(sizeBytes: 10 * 1024 * 1024);
      final container = await _container(_FakeProfileRepository(), picker);

      await _viewModel(container).pickPhoto(PhotoSource.album);

      expect(_state(container).photo, isNotNull);
    });

    test('접근을 거부하면 카메라·앨범을 구분해 담는다', () async {
      final picker = _FakePhotoPicker();
      final container = await _container(_FakeProfileRepository(), picker);

      for (final (source, problem) in [
        (PhotoSource.camera, PhotoPickProblem.cameraDenied),
        (PhotoSource.album, PhotoPickProblem.albumDenied),
      ]) {
        picker.error = PhotoAccessDenied(source);
        await _viewModel(container).pickPhoto(source);

        expect(_state(container).photoProblem, problem);
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

    test('사진이 없으면 올리지 않고 null로 저장한다', () async {
      final repository = _FakeProfileRepository();
      final upload = _FakeUploadRepository();
      final container = await _filled(repository, null, upload);

      await _viewModel(container).save();

      expect(upload.uploaded, isEmpty);
      expect(repository.saved.single.profileImageUrl, isNull);
    });

    test('사진을 먼저 올리고 받은 주소로 저장하면 세션의 nextStep이 바뀐다', () async {
      final repository = _FakeProfileRepository();
      final upload = _FakeUploadRepository();
      final container = await _filled(
        repository,
        _FakePhotoPicker()..result = _photo(),
        upload,
      );
      await _viewModel(container).pickPhoto(PhotoSource.album);

      await _viewModel(container).save();

      expect(upload.uploaded, ['/tmp/a.jpg']);
      expect(repository.saved.single.nickname, '두현');
      expect(repository.saved.single.genreCodes, ['ROCK']);
      expect(repository.saved.single.positionCodes, ['VOCAL']);
      expect(
        repository.saved.single.profileImageUrl,
        _FakeUploadRepository.fileUrl,
      );
      expect(
        container.read(sessionProvider).value!.nextStep,
        NextStep.bandStart,
      );
    });

    test('사진을 못 올리면 저장하지 않고 이유를 담는다', () async {
      for (final (reason, expected) in [
        (UploadFailureReason.rejected, ProfileFailureReason.photoUploadFailed),
        (UploadFailureReason.unknown, ProfileFailureReason.photoUploadFailed),
        (UploadFailureReason.network, ProfileFailureReason.network),
      ]) {
        final repository = _FakeProfileRepository();
        final container = await _filled(
          repository,
          _FakePhotoPicker()..result = _photo(),
          _FakeUploadRepository()..error = UploadFailure(reason),
        );
        await _viewModel(container).pickPhoto(PhotoSource.album);

        await _viewModel(container).save();

        expect(repository.saved, isEmpty);
        expect(_state(container).failure, expected, reason: '$reason');
        expect(_state(container).saving, isFalse);
      }
    });

    test('사진은 올렸는데 저장이 실패해 다시 누르면 같은 사진을 또 올리지 않는다', () async {
      final upload = _FakeUploadRepository();
      final failing = _FakeProfileRepository(
        saveError: const ProfileFailure(ProfileFailureReason.network),
      );
      final container = await _filled(
        failing,
        _FakePhotoPicker()..result = _photo(),
        upload,
      );
      await _viewModel(container).pickPhoto(PhotoSource.album);

      await _viewModel(container).save();
      await _viewModel(container).save();

      expect(failing.saved, hasLength(2));
      expect(upload.uploaded, hasLength(1));
      expect(failing.saved.last.profileImageUrl, _FakeUploadRepository.fileUrl);
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
