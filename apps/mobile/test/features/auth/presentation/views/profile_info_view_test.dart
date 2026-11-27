import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/auth/data/repositories/profile_repository.dart';
import 'package:highfive/features/auth/data/services/profile_service.dart';
import 'package:highfive/features/auth/models/nickname_check_result.dart';
import 'package:highfive/features/auth/models/profile_failure.dart';
import 'package:highfive/features/auth/presentation/providers/profile_providers.dart';
import 'package:highfive/features/auth/presentation/views/profile_info_view.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/app_dialog.dart';

/// 닉네임 확인 결과를 [result]로 돌려준다. [error]가 있으면 실패한다.
class _FakeProfileRepository extends ProfileRepository {
  _FakeProfileRepository({
    this.result = NicknameCheckResult.available,
    this.error,
  }) : super(ProfileService(Dio()));

  final NicknameCheckResult result;
  final Object? error;

  @override
  Future<NicknameCheckResult> checkNickname(String nickname) async {
    if (error case final error?) throw error;
    return result;
  }
}

/// 화면을 띄우고 "다음"이 눌린 횟수를 돌려받을 수 있게 한다.
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
  return calls;
}

AppButton _button(WidgetTester tester, Key key) =>
    tester.widget<AppButton>(find.byKey(key));

Future<void> _checkNickname(WidgetTester tester, String nickname) async {
  await tester.enterText(
    find.byKey(ProfileInfoView.nicknameFieldKey),
    nickname,
  );
  await tester.pump();
  await tester.tap(find.byKey(ProfileInfoView.checkButtonKey));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('처음에는 중복 확인·다음을 누를 수 없다', (tester) async {
    await _pump(tester);

    expect(_button(tester, ProfileInfoView.checkButtonKey).onPressed, isNull);
    expect(_button(tester, ProfileInfoView.nextButtonKey).onPressed, isNull);
  });

  testWidgets('허용하지 않는 문자를 쓰면 바로 안내하고 중복 확인을 막는다', (tester) async {
    await _pump(tester);

    await tester.enterText(
      find.byKey(ProfileInfoView.nicknameFieldKey),
      'rock!',
    );
    await tester.pump();

    expect(find.byKey(ProfileInfoView.nicknameMessageKey), findsOneWidget);
    expect(_button(tester, ProfileInfoView.checkButtonKey).onPressed, isNull);
  });

  testWidgets('중복 확인을 통과하고 장르·포지션을 고르면 다음으로 간다', (tester) async {
    final calls = await _pump(tester);

    await _checkNickname(tester, '두현');
    expect(find.byKey(ProfileInfoView.nicknameMessageKey), findsOneWidget);

    await tester.tap(find.text('록'));
    await tester.pump();
    expect(_button(tester, ProfileInfoView.nextButtonKey).onPressed, isNull);

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
    expect(_button(tester, ProfileInfoView.nextButtonKey).onPressed, isNull);
  });

  testWidgets('직접입력을 고르면 입력칸이 나오고, 값을 채워야 다음으로 갈 수 있다', (tester) async {
    await _pump(tester);
    await _checkNickname(tester, '두현');
    await tester.tap(find.text('록'));
    await tester.tap(find.text('보컬'));
    await tester.pump();
    expect(find.byKey(ProfileInfoView.genreCustomFieldKey), findsNothing);

    // 장르·포지션 둘 다 "직접입력"이 있다. 첫 번째가 장르다.
    await tester.tap(find.text('직접입력').first);
    await tester.pump();
    expect(find.byKey(ProfileInfoView.genreCustomFieldKey), findsOneWidget);
    expect(_button(tester, ProfileInfoView.nextButtonKey).onPressed, isNull);

    await tester.enterText(
      find.byKey(ProfileInfoView.genreCustomFieldKey),
      '시티팝',
    );
    await tester.pump();
    expect(_button(tester, ProfileInfoView.nextButtonKey).onPressed, isNotNull);
  });

  testWidgets('중복 확인이 연결 실패면 Dialog로 알린다', (tester) async {
    await _pump(
      tester,
      _FakeProfileRepository(
        error: const ProfileFailure(ProfileFailureReason.network),
      ),
    );

    await _checkNickname(tester, '두현');

    expect(find.byType(AppDialog), findsOneWidget);
  });

  testWidgets('이전은 기획 확인 전이라 누를 수 없다', (tester) async {
    await _pump(tester);

    final back = tester.widget<AppButton>(find.widgetWithText(AppButton, '이전'));
    expect(back.onPressed, isNull);
  });
}
