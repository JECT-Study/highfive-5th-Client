import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/network/session_expiry.dart';
import 'package:highfive/core/sdk/photo_picker.dart';
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
import 'package:highfive/features/auth/presentation/views/profile_photo_view.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/app_dialog.dart';
import 'package:image_picker/image_picker.dart';

/// 닉네임 확인은 통과시키고, 저장은 [saveError]가 있으면 실패한다.
class _FakeProfileRepository extends ProfileRepository {
  _FakeProfileRepository({this.saveError}) : super(ProfileService(Dio()));

  final Object? saveError;
  final saved = <ProfileDraft>[];

  @override
  Future<NicknameCheckResult> checkNickname(String nickname) async =>
      NicknameCheckResult.available;

  @override
  Future<NextStep> saveProfile(ProfileDraft draft) async {
    saved.add(draft);
    if (saveError case final error?) throw error;
    return NextStep.bandStart;
  }
}

/// 사진 선택기 대신 [result]를 돌려준다.
class _FakePhotoPicker extends PhotoPicker {
  _FakePhotoPicker([this.result]) : super(ImagePicker());

  final PickedPhoto? result;

  @override
  Future<PickedPhoto?> pick(PhotoSource source) async => result;
}

/// 정보 화면을 다 채운 상태로 사진 화면을 띄운다. "이전"이 눌린 횟수를 돌려받는다.
Future<(ProviderContainer, List<String>)> _pump(
  WidgetTester tester, {
  _FakeProfileRepository? repository,
  PickedPhoto? photo,
}) async {
  FlutterSecureStorage.setMockInitialValues({
    SecureStore.accessTokenKey: 'a',
    SecureStore.nextStepKey: NextStep.profile.name,
  });
  final container = ProviderContainer(
    overrides: [
      profileRepositoryProvider.overrideWithValue(
        repository ?? _FakeProfileRepository(),
      ),
      photoPickerProvider.overrideWithValue(_FakePhotoPicker(photo)),
      sessionExpiryProvider.overrideWithValue(SessionExpiry()),
      sessionRepositoryProvider.overrideWithValue(
        SessionRepository(SecureStore(const FlutterSecureStorage())),
      ),
    ],
  );
  addTearDown(container.dispose);
  container.listen(profileViewModelProvider, (_, _) {});
  await container.read(sessionProvider.future);
  container.read(profileViewModelProvider.notifier)
    ..changeNickname('두현')
    ..toggleGenre('ROCK')
    ..togglePosition('VOCAL');
  await container.read(profileViewModelProvider.notifier).checkNickname();

  final calls = <String>[];
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        home: ProfilePhotoView(onBack: () => calls.add('back')),
      ),
    ),
  );
  return (container, calls);
}

AppButton _submit(WidgetTester tester) =>
    tester.widget<AppButton>(find.byKey(ProfilePhotoView.submitButtonKey));

Future<void> _pickFromAlbum(WidgetTester tester) async {
  await tester.tap(find.byKey(ProfilePhotoView.pickButtonKey));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ProfilePhotoView.albumKey));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('정보 화면에서 정한 닉네임을 보인다', (tester) async {
    await _pump(tester);

    expect(find.text('두현'), findsOneWidget);
  });

  testWidgets('사진 없이 건너뛰면 사진 없이 저장하고 세션이 밴드 시작으로 바뀐다', (tester) async {
    final repository = _FakeProfileRepository();
    final (container, _) = await _pump(tester, repository: repository);
    expect(_submit(tester).label, '건너뛰기');

    await tester.tap(find.byKey(ProfilePhotoView.submitButtonKey));
    await tester.pumpAndSettle();

    expect(repository.saved.single.profileImageUrl, isNull);
    expect(container.read(sessionProvider).value!.nextStep, NextStep.bandStart);
  });

  testWidgets('앨범에서 사진을 고르면 버튼이 다음으로 바뀐다', (tester) async {
    await _pump(
      tester,
      photo: const PickedPhoto(
        path: '/tmp/a.jpg',
        sizeBytes: 1024,
        contentType: 'image/jpeg',
      ),
    );

    await _pickFromAlbum(tester);

    expect(_submit(tester).label, '다음');
  });

  testWidgets('10MB를 넘는 사진이면 안내하고 다시 고르게 한다', (tester) async {
    await _pump(
      tester,
      photo: const PickedPhoto(
        path: '/tmp/a.jpg',
        sizeBytes: 10 * 1024 * 1024 + 1,
        contentType: 'image/jpeg',
      ),
    );

    await _pickFromAlbum(tester);

    expect(find.byType(AppDialog), findsOneWidget);
    expect(find.text('다시 고르기'), findsOneWidget);
    expect(_submit(tester).label, '건너뛰기');
  });

  testWidgets('저장 때 닉네임이 겹치면 안내한 뒤 정보 화면으로 돌려보낸다', (tester) async {
    final (_, calls) = await _pump(
      tester,
      repository: _FakeProfileRepository(
        saveError: const ProfileFailure(ProfileFailureReason.nicknameTaken),
      ),
    );

    await tester.tap(find.byKey(ProfilePhotoView.submitButtonKey));
    await tester.pumpAndSettle();
    expect(find.byType(AppDialog), findsOneWidget);

    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    expect(calls, ['back']);
  });
}
