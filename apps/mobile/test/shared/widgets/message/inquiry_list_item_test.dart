import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_selection_controls.dart';
import 'package:highfive/shared/widgets/message/inquiry_list_item.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('줄을 누르면 onTap을 부르고 버튼으로 읽힌다', (tester) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    await _pump(
      tester,
      InquiryListItem(
        name: '밴드',
        subtitle: '공고제목',
        message: '소음공장 팀에서 단체 채팅에 초대했어요.',
        time: '오후 3:31',
        onTap: () => taps++,
      ),
    );

    await tester.tap(find.text('밴드'));

    expect(taps, 1);
    expect(tester.getSemantics(find.text('밴드')), isSemantics(isButton: true));
    semantics.dispose();
  });

  testWidgets('편집 중에만 체크박스를 보이고, 누르면 onTap 대신 onCheckedChanged를 부른다', (
    tester,
  ) async {
    bool? changedTo;
    var taps = 0;
    Widget item({required bool showCheckbox}) => InquiryListItem(
      name: '밴드',
      message: '소음공장 팀에서 단체 채팅에 초대했어요.',
      time: '오후 3:31',
      showCheckbox: showCheckbox,
      onCheckedChanged: (value) => changedTo = value,
      onTap: () => taps++,
    );

    await _pump(tester, item(showCheckbox: false));
    expect(find.byType(AppCheckbox), findsNothing);

    await _pump(tester, item(showCheckbox: true));
    await tester.tap(find.byType(AppCheckbox));

    expect(changedTo, isTrue);
    expect(taps, 0);
  });

  testWidgets('공고가 삭제된 줄만 흐리게 그린다', (tester) async {
    for (final deleted in [false, true]) {
      await _pump(
        tester,
        InquiryListItem(
          name: '밴드',
          subtitle: '삭제된 공고',
          message: '공고가 삭제됐어요.',
          time: '오후 3:31',
          postDeleted: deleted,
        ),
      );
      expect(
        find.ancestor(of: find.text('밴드'), matching: find.byType(Opacity)),
        deleted ? findsOneWidget : findsNothing,
        reason: 'postDeleted=$deleted',
      );
    }
  });
}
