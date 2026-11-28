import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/models/concert_draft.dart';
import 'package:highfive/features/performances/models/concert_failure.dart';
import 'package:highfive/features/performances/presentation/providers/concert_providers.dart';
import 'package:highfive/features/performances/presentation/view_models/concert_creation_view_model.dart';

import '../../concert_test_server.dart';

const _draft = ConcertDraft(
  title: '테스트 공연',
  genres: {'SERVER_GENRE'},
  recruitTeamCount: 2,
);

void main() {
  final band = HostBand(id: 41, name: '테스트 주최 밴드');

  Future<ProviderContainer> container(ConcertTestServer server) async {
    final result = ProviderContainer(
      overrides: [
        concertRepositoryProvider.overrideWithValue(server.repository()),
        concertTodayProvider.overrideWithValue(() => DateTime(2026, 11, 26)),
      ],
    );
    addTearDown(result.dispose);
    result.listen(concertGenresProvider, (_, _) {});
    result.listen(concertCreationProvider(band), (_, _) {});
    await result.read(concertGenresProvider.future);
    return result;
  }

  test('로딩 중 중복 탭을 무시하고 성공 ID를 한 번만 확정한다', () async {
    final server = ConcertTestServer()..release = Completer<void>();
    final c = await container(server);
    final provider = concertCreationProvider(band);
    final vm = c.read(provider.notifier);

    final first = vm.submit(_draft);
    await server.posted.future;
    expect(c.read(provider).submitting, isTrue);
    final sameBandProvider = concertCreationProvider(
      HostBand(id: 41, name: '바뀐 표시 이름'),
    );
    expect(c.read(sameBandProvider).submitting, isTrue);
    await c.read(sameBandProvider.notifier).submit(_draft);
    expect(server.posts, 1);
    server.release!.complete();
    await first;
    expect(c.read(provider).concertId, 72);
    expect(c.read(provider).locked, isTrue);
    await vm.submit(_draft);
    expect(server.posts, 1);
    expect(server.requests.last.data, containsPair('bandId', 41));
    expect(server.requests.last.data, containsPair('recruitTeamCount', 2));
  });

  test('잘못된 입력은 서버에 보내지 않고 필드 오류로 표시한다', () async {
    final server = ConcertTestServer();
    final c = await container(server);
    final provider = concertCreationProvider(band);

    await c
        .read(provider.notifier)
        .submit(const ConcertDraft(title: '', genres: {}, recruitTeamCount: 0));

    expect(server.posts, 0);
    expect(c.read(provider).fields.keys.toSet(), {
      'title',
      'genres',
      'recruitTeamCount',
    });
  });

  test('검증 거절은 수정 후 재제출할 수 있다', () async {
    final server = ConcertTestServer()
      ..status = 400
      ..body = {
        'code': 'COMMON_004',
        'errors': [
          {'field': 'title', 'reason': '다른 제목을 입력하세요'},
        ],
      };
    final c = await container(server);
    final provider = concertCreationProvider(band);
    await c.read(provider.notifier).submit(_draft);
    expect(c.read(provider).fields, {'title': '다른 제목을 입력하세요'});
    expect(c.read(provider).locked, isFalse);

    server
      ..status = 201
      ..body = {
        'code': 'COMMON_000',
        'data': {'concertId': 73},
      };
    await c.read(provider.notifier).submit(_draft);
    expect(c.read(provider).concertId, 73);
    expect(server.posts, 2);
  });

  test('응답 유실은 성공으로 표시하지 않고 화면 재생성 뒤에도 재전송을 막는다', () async {
    final server = ConcertTestServer()
      ..networkFailure = DioExceptionType.receiveTimeout;
    final c = await container(server);
    final provider = concertCreationProvider(band);
    await c.read(provider.notifier).submit(_draft);
    expect(c.read(provider).concertId, isNull);
    expect(c.read(provider).failure, ConcertFailureKind.uncertain);
    await c.read(provider.notifier).submit(_draft);
    c.invalidate(provider);
    await c.read(provider.notifier).submit(_draft);
    expect(server.posts, 1);
    expect(c.read(provider).locked, isTrue);
  });

  test('화면이 폐기된 뒤 도착한 응답은 상태를 갱신하지 않는다', () async {
    final server = ConcertTestServer()..release = Completer<void>();
    final c = await container(server);
    final provider = concertCreationProvider(band);
    final pending = c.read(provider.notifier).submit(_draft);
    await server.posted.future;
    c.invalidate(provider);
    server.release!.complete();
    await pending;
    expect(c.read(provider).concertId, isNull);
  });

  test('연결 전 타임아웃만 수동 재제출하고 소켓 단절은 불명확 상태를 유지한다', () async {
    for (final (type, kind, expectedPosts) in [
      (DioExceptionType.connectionTimeout, ConcertFailureKind.notSent, 2),
      (DioExceptionType.badCertificate, ConcertFailureKind.notSent, 2),
      (DioExceptionType.connectionError, ConcertFailureKind.uncertain, 1),
    ]) {
      final server = ConcertTestServer()..networkFailure = type;
      final c = await container(server);
      final provider = concertCreationProvider(band);
      await c.read(provider.notifier).submit(_draft);
      expect(c.read(provider).failure, kind);

      server.networkFailure = null;
      await c.read(provider.notifier).submit(_draft);

      expect(server.posts, expectedPosts);
      expect(c.read(provider).concertId, expectedPosts == 2 ? 72 : null);
    }
  });

  test('로그인 수명이 바뀌면 잠금이 격리되고 이전 수명의 늦은 응답을 버린다', () async {
    final server = ConcertTestServer()..release = Completer<void>();
    final owner = Provider<Object>((ref) => Object());
    final c = ProviderContainer(
      overrides: [
        concertSessionProvider.overrideWith((ref) => ref.watch(owner)),
        concertServiceProvider.overrideWithValue(
          // 실제 Repository의 세션 수명 연결까지 검증한다.
          server.repositoryService(),
        ),
        concertTodayProvider.overrideWithValue(() => DateTime(2026, 11, 26)),
      ],
    );
    addTearDown(c.dispose);
    final provider = concertCreationProvider(band);
    c.listen(provider, (_, _) {});
    c.listen(concertGenresProvider, (_, _) {});
    await c.read(concertGenresProvider.future);
    final old = c.read(concertRepositoryProvider);
    final pending = c.read(provider.notifier).submit(_draft);
    await server.posted.future;
    c.invalidate(owner);
    expect(identical(c.read(concertRepositoryProvider), old), isFalse);
    expect(c.read(provider).submitting, isFalse);
    server.release!.complete();
    await pending;
    expect(c.read(provider).concertId, isNull);
    expect(c.read(provider).failure, isNull);

    server
      ..release = null
      ..networkFailure = DioExceptionType.receiveTimeout;
    await c.read(concertGenresProvider.future);
    await c.read(provider.notifier).submit(_draft);
    expect(c.read(provider).failure, ConcertFailureKind.uncertain);
    c.invalidate(owner);
    expect(c.read(provider).locked, isFalse);
  });
}
