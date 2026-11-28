import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/app.dart';
import 'package:highfive/app/chat_composition.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/app/providers.dart';
import 'package:highfive/app/router.dart';
import 'package:highfive/app/routes.dart';
import 'package:highfive/features/auth/models/session.dart';
import 'package:highfive/features/auth/presentation/view_models/session_view_model.dart';
import 'package:highfive/features/chat/presentation/views/chat_list_view.dart';
import 'package:highfive/features/chat/presentation/views/chat_room_view.dart';
import 'package:highfive/features/chat/models/chat_room.dart';
import 'package:highfive/features/chat/presentation/widgets/chat_status.dart';
import 'package:highfive/features/chat/presentation/providers/chat_providers.dart';
import 'package:highfive/features/auth/presentation/providers/session_providers.dart';
import 'package:highfive/core/network/session_expiry.dart';
import 'package:highfive/shared/widgets/app_bottom_nav_bar.dart';

class _Session extends SessionViewModel {
  final logoutGate = Completer<void>();
  @override
  Future<Session?> build() async => const Session(accessToken: 'fake-test');
  @override
  Future<void> logout() => logoutGate.future;
}

void main() {
  testWidgets('채팅 첫 진입 전 만료도 앱 수명에서 기록하여 새 fake 생성을 차단한다', (tester) async {
    final expiry = SessionExpiry();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: Flavor.dev,
              chatFakeEnabled: true,
              apiBaseUrl: '',
              kakaoNativeAppKey: '',
              googleIosClientId: '',
              googleServerClientId: '',
            ),
          ),
          sessionProvider.overrideWith(_Session.new),
          sessionExpiryProvider.overrideWithValue(expiry),
        ],
        child: const HighfiveApp(),
      ),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HighfiveApp)),
    );
    final delivered = expiry.stream.first;
    expiry.notify('AUTH_003');
    await tester.pump();
    await delivered;
    container.read(routerProvider).go(AppRoutes.chat);
    await tester.pumpAndSettle();
    expect(container.read(sessionProvider).value, isNotNull);
    expect(container.read(appChatRepositoryProvider), isNull);
    expect(find.byKey(const ValueKey('chat_open_inquiry')), findsNothing);
    expect(find.byType(ChatStatus), findsOneWidget);
  });
  testWidgets('인증된 메시지 탭에서 fake 문의를 열고 방에서 목록으로 돌아온다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: Flavor.dev,
              chatFakeEnabled: true,
              apiBaseUrl: '',
              kakaoNativeAppKey: '',
              googleIosClientId: '',
              googleServerClientId: '',
            ),
          ),
          sessionProvider.overrideWith(_Session.new),
          sessionExpiryProvider.overrideWithValue(SessionExpiry()),
        ],
        child: const HighfiveApp(),
      ),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HighfiveApp)),
    );
    container.read(routerProvider).go(AppRoutes.chat);
    await tester.pumpAndSettle();
    expect(find.byType(ChatListView), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('chat_open_inquiry')));
    await tester.pumpAndSettle();
    expect(find.byType(ChatRoomView), findsOneWidget);
    expect(find.byType(AppBottomNavBar), findsNothing);
    await tester.tap(find.byTooltip('뒤로'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatListView), findsOneWidget);
    expect(find.byType(AppBottomNavBar), findsOneWidget);
    final old = container.read(appChatRepositoryProvider)!;
    final chatContainer = ProviderScope.containerOf(
      tester.element(find.byType(ChatListView)),
    );
    final roomId = chatContainer.read(chatRoomsProvider).requireValue.single.id;
    container.read(routerProvider).go(AppRoutes.my);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OutlinedButton));
    expect(container.read(sessionProvider).value, isNotNull);
    await expectLater(old.send(roomId, 'late'), throwsA(isA<ChatException>()));
    (container.read(sessionProvider.notifier) as _Session).logoutGate
        .complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
