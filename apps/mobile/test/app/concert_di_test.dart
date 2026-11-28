import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/di.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/core/di/locator.dart';
import 'package:highfive/features/performances/data/repositories/concert_edit_repository.dart';
import 'package:highfive/features/performances/data/repositories/concert_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_edit_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/presentation/providers/concert_detail_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_edit_providers.dart';
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
    test('${flavor.name} 실제 DI에서 공용 조회와 안전한 권한을 제공한다', () async {
      setupDi(AppEnv.forFlavorName(flavor.name));
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(
        concertDetailProvider(12),
        (_, _) {},
      );
      addTearDown(subscription.close);

      final detail = await container.read(concertDetailProvider(12).future);

      expect(getIt<ConcertRepository>(), isA<FakeConcertRepository>());
      expect(
        container.read(concertRepositoryProvider),
        same(getIt<ConcertRepository>()),
      );
      expect(detail.concertId, 12);
      expect(detail.myPermissions.isHostLeader, isFalse);
      expect(detail.myPermissions.isTeamLeader, isFalse);
    });

    // 가짜 상세의 공연 ID·version으로 실서버 PUT을 보내면 다른 공연을 덮어쓸 수 있다.
    test('${flavor.name} GET이 가짜인 동안 수정 저장도 같은 메모리 객체가 처리한다', () {
      setupDi(AppEnv.forFlavorName(flavor.name));

      final container = ProviderContainer();
      addTearDown(container.dispose);
      final edits = container.read(concertEditRepositoryProvider);
      expect(edits, isA<FakeConcertEditRepository>());
      expect(edits, same(container.read(concertRepositoryProvider)));
      expect(edits, same(getIt<ConcertEditRepository>()));
    });
  }
}
