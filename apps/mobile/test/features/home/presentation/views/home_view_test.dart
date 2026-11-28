import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/home/presentation/views/home_view.dart';
import 'package:highfive/shared/theme/app_theme.dart';

import '../../../../support/capture.dart';

void main() {
  setUpAll(loadCaptureFonts);

  testWidgets('바로가기 버튼이 공연 만들기·팀 모집 콜백을 부른다', (tester) async {
    usePhoneSize(tester);
    var createConcert = 0;
    var findRecruitments = 0;
    await tester.pumpWidget(
      capturable(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: HomeView(
            onCreateConcert: () => createConcert++,
            onFindRecruitments: () => findRecruitments++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await capture(tester, 'home-empty');

    await tester.tap(find.byKey(HomeView.createConcertKey));
    expect(createConcert, 1);
    expect(findRecruitments, 0);
    await tester.tap(find.byKey(HomeView.findRecruitmentsKey));

    expect(createConcert, 1);
    expect(findRecruitments, 1);
  });

  testWidgets('좁은 폭(320)에서도 넘치지 않는다', (tester) async {
    usePhoneSize(tester, width: 320, height: 640);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HomeView(onCreateConcert: () {}, onFindRecruitments: () {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(HomeView.createConcertKey), findsOneWidget);
  });
}
