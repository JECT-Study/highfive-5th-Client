import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/di.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/core/di/locator.dart';
import 'package:highfive/features/performances/data/repositories/concert_creation_repository.dart';
import 'package:highfive/features/performances/data/repositories/host_band_repository.dart';
import 'package:highfive/features/performances/data/repositories/local_concert_creation_repository.dart';
import 'package:highfive/features/performances/models/concert_creation_failure.dart';
import 'package:highfive/features/performances/models/concert_draft.dart';
import 'package:highfive/features/performances/models/concert_genre.dart';
import 'package:highfive/features/performances/models/host_band.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  setUp(() {
    final previous = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FlutterSecureStorage.setMockInitialValues({});
    addTearDown(() => SharedPreferencesAsyncPlatform.instance = previous);
    addTearDown(() => getIt.reset());
  });

  for (final flavor in Flavor.values) {
    test('${flavor.name} 기본 DI는 실제 밴드도 POST하지 않고 임시 밴드는 로컬에만 만든다', () async {
      await HttpOverrides.runWithHttpOverrides(() async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(() => server.close(force: true));
        var posts = 0;
        final subscription = server.listen((request) async {
          if (request.method == 'POST') posts++;
          await request.drain<void>();
          request.response
            ..statusCode = HttpStatus.created
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode({
                'status': 201,
                'code': 'COMMON_000',
                'message': '',
                'data': {'concertId': 12},
              }),
            );
          await request.response.close();
        });
        addTearDown(subscription.cancel);
        setupDi(
          AppEnv(
            flavor: flavor,
            apiBaseUrl: 'http://${server.address.address}:${server.port}',
            kakaoNativeAppKey: 'test',
            googleIosClientId: 'test',
            googleServerClientId: 'test',
          ),
        );
        final repository = getIt<ConcertCreationRepository>();
        const actual = HostBand.authenticated(
          id: 3,
          name: '확인된 밴드',
          genres: [ConcertGenre.rock],
          memberCount: 4,
        );
        final draft = ConcertDraft(
          title: '공연',
          genres: const {ConcertGenre.rock},
          recruitTeamCount: 1,
          performDate: DateTime(2026, 12, 20),
          rentalFeeUndecided: true,
          rentalFeeText: '',
        );

        await expectLater(
          repository.create(actual, draft),
          throwsA(
            isA<ConcertCreationFailure>().having(
              (failure) => failure.reason,
              'reason',
              ConcertCreationFailureReason.unavailable,
            ),
          ),
        );
        const fixture = HostBand(
          id: 3,
          name: '임시 밴드',
          genres: [ConcertGenre.rock],
          memberCount: 4,
        );
        final id = await repository.create(fixture, draft);

        expect(id, -1);
        expect(
          getIt<LocalConcertCreationRepository>().concerts[id]?.band,
          same(fixture),
        );
        expect(posts, 0);
        final bands = await getIt<HostBandRepository>().fetchHostBands();
        if (flavor == Flavor.prod) expect(bands, isEmpty);
        expect(bands.every((band) => band.isFixture), isTrue);
      }, _RealHttpOverrides());
    });
  }
}
