import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_tag.dart';
import 'package:highfive/shared/widgets/show/show_date_card.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('누르면 onTap을 부른다', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      ShowDateCard(
        day: '28',
        weekday: '월',
        title: '합동 리허설',
        onTap: () => taps++,
      ),
    );

    await tester.tap(find.byType(ShowDateCard));

    expect(taps, 1);
  });

  testWidgets('밴드 태그와 상태 태그는 값이 있을 때만 그린다', (tester) async {
    await _pump(
      tester,
      const ShowDateCard(day: '28', weekday: '월', title: '합동 리허설'),
    );
    expect(find.byType(AppTag), findsNothing);

    await _pump(
      tester,
      const ShowDateCard(
        day: '28',
        weekday: '월',
        title: '합동 리허설',
        bandLabel: '밴드명',
      ),
    );
    expect(find.byType(AppTag), findsOneWidget);

    await _pump(
      tester,
      const ShowDateCard(
        type: ShowDateCardType.detail,
        day: '12',
        weekday: '월',
        title: '소음공장 합동공연',
        tags: ['준비 중', '준비 중'],
      ),
    );
    expect(find.byType(AppTag), findsNWidgets(2));
  });
}
