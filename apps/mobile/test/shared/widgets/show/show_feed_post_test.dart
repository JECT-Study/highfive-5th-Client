import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/show/show_feed_post.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

ShowFeedPost _post({
  ShowFeedPostType type = ShowFeedPostType.text,
  VoidCallback? onTap,
  VoidCallback? onMoreTap,
}) => ShowFeedPost(
  type: type,
  authorName: '박기타',
  body: '저희 셋리스트 올립니다.',
  reactionCount: '2',
  commentLabel: '댓글',
  commentCount: '2',
  moreTooltip: '더보기',
  onTap: onTap,
  onMoreTap: onMoreTap,
);

void main() {
  testWidgets('글을 누르면 onTap을, 더보기를 누르면 onMoreTap만 부른다', (tester) async {
    var taps = 0;
    var moreTaps = 0;
    await _pump(
      tester,
      _post(onTap: () => taps++, onMoreTap: () => moreTaps++),
    );

    await tester.tap(find.byTooltip('더보기'));
    expect((taps, moreTaps), (0, 1));

    await tester.tap(find.byType(ShowFeedPost));
    expect((taps, moreTaps), (1, 1));
  });

  testWidgets('Image 변형만 첨부 이미지 자리를 그린다', (tester) async {
    const imageKey = ValueKey('showFeedPost_image');

    await _pump(tester, _post());
    expect(find.byKey(imageKey), findsNothing);

    await _pump(tester, _post(type: ShowFeedPostType.image));
    expect(find.byKey(imageKey), findsOneWidget);
  });
}
