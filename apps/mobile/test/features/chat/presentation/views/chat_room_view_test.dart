import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/chat/data/repositories/chat_demo_fixture.dart';
import 'package:highfive/features/chat/data/repositories/fake_chat_store.dart';
import 'package:highfive/features/chat/models/chat_room.dart';
import 'package:highfive/features/chat/presentation/providers/chat_providers.dart';
import 'package:highfive/features/chat/presentation/views/chat_room_view.dart';
import 'package:highfive/features/chat/presentation/views/chat_list_view.dart';
import 'package:highfive/features/chat/presentation/widgets/chat_status.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/message/message_bubble.dart';
import 'package:highfive/shared/widgets/message/message_input_bar.dart';

void main() {
  testWidgets('미연결 환경은 자동 재시도 로딩 없이 즉시 준비 안내를 표시한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: ChatListView(onOpenRoom: (_) {}),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(ChatStatus), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
  testWidgets('입력과 실제 보내기 버튼으로 상대 스트림에 메시지를 전달한다', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      final store = FakeChatStore(actors: ChatDemoFixture.actors);
      addTearDown(store.dispose);
      final applicant = store.bind(ChatDemoFixture.applicant.id);
      final host = store.bind(ChatDemoFixture.host.id);
      final room = await applicant.openInquiry(ChatDemoFixture.target);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [chatRepositoryProvider.overrideWithValue(applicant)],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ChatRoomView(roomId: room.id, onBack: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final received = <ChatRoom>[];
      final subscription = host.watchRoom(room.id).listen(received.add);
      addTearDown(subscription.cancel);
      await tester.enterText(find.byType(TextField), '공연 순서가 궁금해요');
      await tester.pump();
      await tester.tap(find.byTooltip('보내기'));
      await tester.pumpAndSettle();
      expect(received.last.messages.map((message) => message.text), [
        '공연 순서가 궁금해요',
      ]);
      expect(
        tester
            .widget<MessageInputBar>(find.byType(MessageInputBar))
            .controller
            .text,
        isEmpty,
      );
      await host.send(room.id, '아직 미정이에요');
      await tester.pumpAndSettle();
      expect(
        tester
            .getSemantics(
              find.byKey(const ValueKey('chat_author_fake-message-1')),
            )
            .label,
        contains(ChatDemoFixture.applicant.name),
      );
      expect(
        tester
            .getSemantics(
              find.byKey(const ValueKey('chat_author_fake-message-2')),
            )
            .label,
        contains(ChatDemoFixture.host.name),
      );
      expect(
        tester
            .widgetList<MessageBubble>(find.byType(MessageBubble))
            .map((bubble) => bubble.direction),
        [MessageBubbleDirection.received, MessageBubbleDirection.sent],
      );
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('팀원 입력은 비활성이고 주최자 결정 슬롯을 그리지 않는다', (tester) async {
    final store = FakeChatStore(actors: ChatDemoFixture.actors);
    addTearDown(store.dispose);
    final room = await store
        .bind(ChatDemoFixture.applicant.id)
        .openInquiry(ChatDemoFixture.target);
    await store.bind(ChatDemoFixture.applicant.id).send(room.id, '문의');
    await store.bind(ChatDemoFixture.host.id).send(room.id, '답변');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatRepositoryProvider.overrideWithValue(
            store.bind(ChatDemoFixture.member.id),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: ChatRoomView(
            roomId: room.id,
            onBack: () {},
            decisionBuilder: (_, _) =>
                const SizedBox(key: ValueKey('host_decision')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(find.byKey(const ValueKey('host_decision')), findsNothing);
    expect(
      tester
          .widgetList<MessageBubble>(find.byType(MessageBubble))
          .map((bubble) => (bubble.message, bubble.senderName))
          .toSet(),
      {('문의', '소음공장 대표'), ('답변', '오프비트 대표')},
    );
  });

  testWidgets('초기 읽기 대기는 빈 대화로 표시하지 않는다', (tester) async {
    final events = StreamController<ChatRoom>();
    addTearDown(events.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatRoomProvider('held').overrideWith((ref) => events.stream),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: ChatRoomView(roomId: 'held', onBack: () {}),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(MessageInputBar), findsNothing);
    await tester.pumpWidget(const SizedBox());
    final closed = events.close();
    await tester.pump();
    await closed;
  });

  testWidgets('알 수 없는 방은 오류와 뒤로가기만 표시한다', (tester) async {
    final store = FakeChatStore(actors: ChatDemoFixture.actors);
    addTearDown(store.dispose);
    var backs = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatRepositoryProvider.overrideWithValue(
            store.bind(ChatDemoFixture.applicant.id),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: ChatRoomView(roomId: 'missing', onBack: () => backs++),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ChatStatus), findsOneWidget);
    expect(find.byType(MessageInputBar), findsNothing);
    await tester.tap(find.byType(BackButton));
    expect(backs, 1);
  });

  for (final width in [320.0, 375.0]) {
    testWidgets('폭 $width 긴 메시지와 키보드 영역에서도 넘치지 않는다', (tester) async {
      tester.view.physicalSize = Size(width, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = FakeChatStore(actors: ChatDemoFixture.actors);
      addTearDown(store.dispose);
      final applicant = store.bind(ChatDemoFixture.applicant.id);
      final room = await applicant.openInquiry(ChatDemoFixture.target);
      await applicant.send(room.id, '공연 순서와 셋리스트를 함께 정하고 싶어요. ' * 5);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [chatRepositoryProvider.overrideWithValue(applicant)],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ChatRoomView(
              roomId: room.id,
              onBack: () {},
              demoControls: const SizedBox(height: 48, child: Text('FAKE')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(MessageInputBar), findsOneWidget);
    });
  }
}
