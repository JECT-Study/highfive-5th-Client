import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/auth/data/repositories/profile_repository.dart';
import 'package:highfive/features/auth/data/services/profile_service.dart';
import 'package:highfive/features/auth/models/nickname_check_result.dart';
import 'package:highfive/features/auth/models/profile_failure.dart';
import 'package:highfive/features/auth/models/profile_options.dart';
import 'package:highfive/features/auth/presentation/providers/profile_providers.dart';
import 'package:highfive/features/auth/presentation/view_models/profile_view_model.dart';
import 'package:highfive/features/auth/presentation/views/profile_info_view.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';

const ProfileOptions _options = (
  genres: [(code: 'ROCK', label: '록'), (code: 'ETC', label: '기타')],
  positions: [(code: 'VOCAL', label: '보컬'), (code: 'CUSTOM', label: '직접입력')],
);

/// 선택지와 닉네임 확인 결과를 돌려준다. [optionsError]·[checkError]가 있으면 실패한다.
class _FakeProfileRepository extends ProfileRepository {
  _FakeProfileRepository({
    this.result = NicknameCheckResult.available,
    this.checkError,
  }) : super(ProfileService(Dio()));

  final NicknameCheckResult result;
  final Object? checkError;
  Object? optionsError;
  final checked = <String>[];

  @override
  Future<ProfileOptions> fetchOptions() async {
    if (optionsError case final error?) throw error;
    return _options;
  }

  @override
  Future<NicknameCheckResult> checkNickname(String nickname) async {
    checked.add(nickname);
    if (checkError case final error?) throw error;
    return result;
  }
}

/// 화면을 띄우고 "다음"이 눌린 기록을 돌려받는다.
Future<List<String>> _pump(
  WidgetTester tester, [
  _FakeProfileRepository? repository,
]) async {
  final calls = <String>[];
  // 칩·입력칸이 모두 보이도록 화면을 길게 둔다.
  tester.view.physicalSize = const Size(375, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(
          repository ?? _FakeProfileRepository(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: ProfileInfoView(onNext: () => calls.add('next')),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return calls;
}

AppButton _next(WidgetTester tester) =>
    tester.widget<AppButton>(find.byKey(ProfileInfoView.nextButtonKey));

/// 닉네임을 쓰고 입력이 멈춘 만큼 시간을 보낸다 (그 뒤 형식 검사기가 안내한다).
Future<void> _typeNickname(WidgetTester tester, String nickname) async {
  await tester.enterText(
    find.byKey(ProfileInfoView.nicknameFieldKey),
    nickname,
  );
  await tester.pump(ProfileViewModel.nicknameValidationDelay);
}

/// 닉네임을 쓰고 "중복 확인"을 누른다.
Future<void> _checkNickname(WidgetTester tester, String nickname) async {
  await _typeNickname(tester, nickname);
  await tester.tap(find.byKey(ProfileInfoView.checkButtonKey));
  await tester.pumpAndSettle();
}

AppButton _checkButton(WidgetTester tester) =>
    tester.widget<AppButton>(find.byKey(ProfileInfoView.checkButtonKey));

void main() {
  testWidgets('서버가 준 장르·포지션을 칩으로 보이고, 처음에는 다음을 누를 수 없다', (tester) async {
    await _pump(tester);

    expect(find.text('록'), findsOneWidget);
    expect(find.text('보컬'), findsOneWidget);
    expect(_next(tester).onPressed, isNull);
  });

  testWidgets('형식이 맞는 닉네임을 써도 서버에 묻지 않고, 중복 확인을 눌러야 묻는다', (tester) async {
    final repository = _FakeProfileRepository();
    await _pump(tester, repository);

    await _typeNickname(tester, '두현');
    expect(repository.checked, isEmpty);
    expect(find.byKey(ProfileInfoView.nicknameMessageKey), findsNothing);
    expect(_checkButton(tester).onPressed, isNotNull);

    await tester.tap(find.byKey(ProfileInfoView.checkButtonKey));
    await tester.pumpAndSettle();

    expect(repository.checked, ['두현']);
    expect(find.byKey(ProfileInfoView.nicknameMessageKey), findsOneWidget);
  });

  testWidgets('허용하지 않는 문자는 입력이 멈추면 안내하고 중복 확인을 막는다', (tester) async {
    await _pump(tester);

    await tester.enterText(
      find.byKey(ProfileInfoView.nicknameFieldKey),
      'rock!',
    );
    await tester.pump();
    expect(find.byKey(ProfileInfoView.nicknameMessageKey), findsNothing);

    await tester.pump(ProfileViewModel.nicknameValidationDelay);
    expect(find.byKey(ProfileInfoView.nicknameMessageKey), findsOneWidget);
    expect(_checkButton(tester).onPressed, isNull);
  });

  testWidgets('확인을 통과하고 장르·포지션을 고르면 다음으로 간다', (tester) async {
    final calls = await _pump(tester);

    await _checkNickname(tester, '두현');
    await tester.tap(find.text('록'));
    await tester.pump();
    expect(_next(tester).onPressed, isNull);

    await tester.tap(find.text('보컬'));
    await tester.pump();
    await tester.tap(find.byKey(ProfileInfoView.nextButtonKey));

    expect(calls, ['next']);
  });

  testWidgets('중복이면 안내하고 다음을 막는다', (tester) async {
    await _pump(
      tester,
      _FakeProfileRepository(result: NicknameCheckResult.duplicated),
    );

    await _checkNickname(tester, '두현');
    await tester.tap(find.text('록'));
    await tester.tap(find.text('보컬'));
    await tester.pump();

    expect(find.byKey(ProfileInfoView.nicknameMessageKey), findsOneWidget);
    expect(_next(tester).onPressed, isNull);
  });

  testWidgets('직접입력을 고르면 입력칸이 나오고, 값을 채워야 다음으로 갈 수 있다', (tester) async {
    await _pump(tester);
    await _checkNickname(tester, '두현');
    await tester.tap(find.text('록'));
    await tester.tap(find.text('보컬'));
    await tester.pump();
    expect(find.byKey(ProfileInfoView.positionCustomFieldKey), findsNothing);

    await tester.tap(find.text('직접입력'));
    await tester.pump();
    expect(find.byKey(ProfileInfoView.positionCustomFieldKey), findsOneWidget);
    expect(_next(tester).onPressed, isNull);

    await tester.enterText(
      find.byKey(ProfileInfoView.positionCustomFieldKey),
      '하모니카',
    );
    await tester.pump();
    expect(_next(tester).onPressed, isNotNull);
  });

  testWidgets('중복 확인이 실패하면 아래에 알리고, 버튼을 다시 누를 수 있다', (tester) async {
    final repository = _FakeProfileRepository(
      checkError: const ProfileFailure(ProfileFailureReason.network),
    );
    await _pump(tester, repository);

    await _checkNickname(tester, '두현');
    expect(find.byKey(ProfileInfoView.nicknameMessageKey), findsOneWidget);

    await tester.tap(find.byKey(ProfileInfoView.checkButtonKey));
    await tester.pumpAndSettle();

    expect(repository.checked, ['두현', '두현']);
  });

  testWidgets('선택지를 못 받으면 다시 시도할 수 있다', (tester) async {
    final repository = _FakeProfileRepository()
      ..optionsError = const ProfileFailure(ProfileFailureReason.network);
    await _pump(tester, repository);
    expect(find.text('록'), findsNothing);

    repository.optionsError = null;
    await tester.tap(find.byKey(ProfileInfoView.optionsRetryKey));
    await tester.pumpAndSettle();

    expect(find.text('록'), findsOneWidget);
  });

  testWidgets('이전은 기획 확인 전이라 누를 수 없다', (tester) async {
    await _pump(tester);

    final back = tester.widget<AppButton>(find.widgetWithText(AppButton, '이전'));
    expect(back.onPressed, isNull);
  });
}
