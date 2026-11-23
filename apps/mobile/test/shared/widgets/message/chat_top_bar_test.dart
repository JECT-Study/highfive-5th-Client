import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_tag.dart';
import 'package:highfive/shared/widgets/message/chat_top_bar.dart';

Future<void> _pump(WidgetTester tester, PreferredSizeWidget bar) =>
    tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(appBar: bar),
      ),
    );

void main() {
  testWidgets('뒤로·더보기 버튼이 각자의 콜백을 부른다', (tester) async {
    var backs = 0;
    var mores = 0;
    await _pump(
      tester,
      ChatTopBar(
        type: ChatTopBarType.chat,
        title: '오프비트',
        subtitles: const ['1시간 내 답변'],
        backTooltip: '뒤로',
        onBack: () => backs++,
        moreTooltip: '더보기',
        onMore: () => mores++,
      ),
    );

    await tester.tap(find.byTooltip('뒤로'));
    expect((backs, mores), (1, 0));

    await tester.tap(find.byTooltip('더보기'));
    expect((backs, mores), (1, 1));
  });

  testWidgets('채팅창은 프로필과 문의 태그를, 합동공연채팅은 참여자 버튼을 보인다', (tester) async {
    var members = 0;
    for (final type in ChatTopBarType.values) {
      await _pump(
        tester,
        ChatTopBar(
          type: type,
          title: '오프비트',
          subtitles: const ['대표자 채팅', '참여 13명'],
          tagLabel: '보낸 문의',
          backTooltip: '뒤로',
          onBack: () {},
          membersTooltip: '참여자',
          onMembers: () => members++,
          moreTooltip: '더보기',
          onMore: () {},
        ),
      );
      final isChat = type == ChatTopBarType.chat;
      expect(
        find.byType(CircleAvatar),
        isChat ? findsOneWidget : findsNothing,
        reason: '$type',
      );
      expect(
        find.byType(AppRoundTag),
        isChat ? findsOneWidget : findsNothing,
        reason: '$type',
      );
      expect(
        find.byTooltip('참여자'),
        isChat ? findsNothing : findsOneWidget,
        reason: '$type',
      );
    }

    await tester.tap(find.byTooltip('참여자'));
    expect(members, 1);
  });
}
