import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/chat_composition.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/app/providers.dart';
import 'package:highfive/core/network/session_expiry.dart';
import 'package:highfive/features/auth/models/session.dart';
import 'package:highfive/features/auth/models/next_step.dart';
import 'package:highfive/features/auth/presentation/providers/session_providers.dart';
import 'package:highfive/features/auth/presentation/view_models/session_view_model.dart';
import 'package:highfive/features/chat/data/repositories/chat_demo_fixture.dart';
import 'package:highfive/features/chat/models/chat_room.dart';

class _Session extends SessionViewModel {
  @override
  Future<Session?> build() async =>
      const Session(accessToken: 'fake-session-a');
  void replace(Session? value) => state = AsyncData(value);
}

AppEnv _env(Flavor flavor, bool fake) => AppEnv(
  flavor: flavor,
  chatFakeEnabled: fake,
  apiBaseUrl: '',
  kakaoNativeAppKey: '',
  googleIosClientId: '',
  googleServerClientId: '',
);

void main() {
  test('서버 만료 신호를 받으면 세션 삭제 완료 전 채팅을 차단한다', () async {
    final expiry = SessionExpiry();
    final container = ProviderContainer(
      overrides: [
        appEnvProvider.overrideWithValue(_env(Flavor.dev, true)),
        sessionProvider.overrideWith(_Session.new),
        sessionExpiryProvider.overrideWithValue(expiry),
      ],
    );
    addTearDown(container.dispose);
    await container.read(sessionProvider.future);
    final old = container.read(appChatRepositoryProvider)!;
    final room = await old.openInquiry(ChatDemoFixture.target);
    final delivered = expiry.stream.first;
    expiry.notify('AUTH_003');
    await delivered;
    expect(container.read(sessionProvider).value, isNotNull);
    await expectLater(old.send(room.id, 'late'), throwsA(isA<ChatException>()));
    expect(container.read(appChatRepositoryProvider), isNull);
  });
  for (final step in [NextStep.home, NextStep.profile, NextStep.bandStart]) {
    test('$step 인증된 앱 진입 단계에서만 독립 fake 신원을 제공한다', () async {
      final container = ProviderContainer(
        overrides: [
          appEnvProvider.overrideWithValue(_env(Flavor.dev, true)),
          sessionProvider.overrideWith(_Session.new),
          sessionExpiryProvider.overrideWithValue(SessionExpiry()),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sessionProvider.future);
      (container.read(sessionProvider.notifier) as _Session).replace(
        Session(accessToken: 'fake', nextStep: step),
      );
      expect(
        container.read(appChatRepositoryProvider)!.actor.id,
        'fake-applicant-leader',
      );
    });
  }

  test('로그아웃 시작 경계에서 서버 완료 전 이전 핸들을 차단한다', () async {
    final container = ProviderContainer(
      overrides: [
        appEnvProvider.overrideWithValue(_env(Flavor.dev, true)),
        sessionProvider.overrideWith(_Session.new),
        sessionExpiryProvider.overrideWithValue(SessionExpiry()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(sessionProvider.future);
    final old = container.read(appChatRepositoryProvider)!;
    final room = await old.openInquiry(ChatDemoFixture.target);
    container.read(chatSessionGateProvider.notifier).close();
    expect(container.read(sessionProvider).value, isNotNull);
    await expectLater(old.send(room.id, 'late'), throwsA(isA<ChatException>()));
    expect(container.read(appChatRepositoryProvider), isNull);
  });
  for (final (flavor, enabled) in [
    (Flavor.dev, false),
    (Flavor.prod, false),
    (Flavor.prod, true),
  ]) {
    test('$flavor/$enabled 기본 운영 연결은 fake를 노출하지 않는다', () async {
      final container = ProviderContainer(
        overrides: [
          appEnvProvider.overrideWithValue(_env(flavor, enabled)),
          sessionProvider.overrideWith(_Session.new),
          sessionExpiryProvider.overrideWithValue(SessionExpiry()),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sessionProvider.future);
      expect(container.read(appChatRepositoryProvider), isNull);
    });
  }

  test('로그아웃 시 읽기 전용 소비자가 없어도 보관된 핸들은 즉시 거부한다', () async {
    final container = ProviderContainer(
      overrides: [
        appEnvProvider.overrideWithValue(_env(Flavor.dev, true)),
        sessionProvider.overrideWith(_Session.new),
        sessionExpiryProvider.overrideWithValue(SessionExpiry()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(sessionProvider.future);
    final old = container.read(appChatRepositoryProvider)!;
    final room = await old.openInquiry(ChatDemoFixture.target);
    (container.read(sessionProvider.notifier) as _Session).replace(null);
    await expectLater(old.send(room.id, 'late'), throwsA(isA<ChatException>()));
    expect(container.read(appChatRepositoryProvider), isNull);
  });

  test('계정 전환은 이전 저장소를 폐기하고 새 세션에 방을 남기지 않는다', () async {
    final container = ProviderContainer(
      overrides: [
        appEnvProvider.overrideWithValue(_env(Flavor.dev, true)),
        sessionProvider.overrideWith(_Session.new),
        sessionExpiryProvider.overrideWithValue(SessionExpiry()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(sessionProvider.future);
    final old = container.read(appChatRepositoryProvider)!;
    final room = await old.openInquiry(ChatDemoFixture.target);
    (container.read(sessionProvider.notifier) as _Session).replace(
      const Session(accessToken: 'fake-session-b'),
    );
    await expectLater(old.send(room.id, 'late'), throwsA(isA<ChatException>()));
    expect(
      await container.read(appChatRepositoryProvider)!.rooms().first,
      isEmpty,
    );
  });

  test('fake 역할 전환은 같은 방을 유지하며 이전 actor 핸들은 거부한다', () async {
    final container = ProviderContainer(
      overrides: [
        appEnvProvider.overrideWithValue(_env(Flavor.dev, true)),
        sessionProvider.overrideWith(_Session.new),
        sessionExpiryProvider.overrideWithValue(SessionExpiry()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(sessionProvider.future);
    final applicant = container.read(appChatRepositoryProvider)!;
    final room = await applicant.openInquiry(ChatDemoFixture.target);
    await applicant.send(room.id, 'applicant');
    container
        .read(chatDemoActorProvider.notifier)
        .select(ChatDemoFixture.host.id);
    await expectLater(
      applicant.send(room.id, 'late'),
      throwsA(isA<ChatException>()),
    );
    final host = container.read(appChatRepositoryProvider)!;
    expect(
      (await host.watchRoom(room.id).first).messages.single.text,
      'applicant',
    );
    expect(host.actor.id, 'fake-host-leader');
  });
}
