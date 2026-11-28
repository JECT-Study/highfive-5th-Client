import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/di.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/core/di/locator.dart';
import 'package:highfive/features/performances/data/repositories/concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/presentation/providers/concert_participants_providers.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    final previous = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    addTearDown(() => SharedPreferencesAsyncPlatform.instance = previous);
  });
  tearDown(() => getIt.reset());

  for (final flavor in Flavor.values) {
    test('${flavor.name} 실제 DI가 참여 밴드 조회를 공연 상세와 같은 공연으로 연결한다', () async {
      setupDi(AppEnv.forFlavorName(flavor.name));
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(
        concertParticipantsProvider(12),
        (_, _) {},
      );
      addTearDown(subscription.close);

      final participants = await container.read(
        concertParticipantsProvider(12).future,
      );

      expect(
        getIt<ConcertParticipantsRepository>(),
        isA<FakeConcertParticipantsRepository>(),
      );
      expect(
        container.read(concertParticipantsRepositoryProvider),
        same(getIt<ConcertParticipantsRepository>()),
      );
      expect(
        participants.singleWhere((p) => p.isHost).bandId,
        FakeConcertRepository.sample.hostBandId,
      );
    });
  }
}
