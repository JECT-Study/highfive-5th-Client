import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/network/api_log_interceptor.dart';
import 'package:highfive/core/network/auth_interceptor.dart';
import 'package:highfive/core/network/session_expiry.dart';
import 'package:highfive/core/storage/secure_store.dart';
import 'package:highfive/features/performances/data/dto/concert_api_failure_dto.dart';
import 'package:highfive/features/performances/data/services/concert_service.dart';
import 'package:highfive/features/performances/models/concert_draft.dart';
import 'package:highfive/features/performances/models/concert_failure.dart';

import '../../concert_test_server.dart';

Future<int> _create(ConcertTestServer server) => server.repository().create(
  HostBand(id: 41, name: '테스트 주최 팀'),
  const ConcertDraft(
    title: '공연',
    genres: {'SERVER_GENRE'},
    recruitTeamCount: 1,
  ),
);

void main() {
  test('GENRE만 요청하고 서버의 코드와 표시명을 그대로 해석한다', () async {
    final server = ConcertTestServer();
    final service = ConcertService(server.dio());

    final genres = await service.fetchGenres();

    expect(genres, [(code: 'SERVER_GENRE', name: '서버 제공 장르')]);
    expect(server.requests.single.path, '/api/v1/codes');
    expect(server.requests.single.queryParameters, {'types': 'GENRE'});
    expect(server.posts, 0);
  });

  test('201과 유효한 생성 ID가 함께 있어야 성공한다', () async {
    for (final (status, body) in <(int, Object?)>[
      (
        200,
        {
          'code': 'COMMON_000',
          'data': {'concertId': 72},
        },
      ),
      (
        201,
        {
          'code': 'COMMON_000',
          'data': {'concertId': '72'},
        },
      ),
      (
        201,
        {
          'code': 'COMMON_000',
          'data': {'concertId': 0},
        },
      ),
      (201, {'code': 'COMMON_000', 'data': null}),
      (201, ['unexpected']),
      (201, 'unexpected'),
      (503, {'code': 'COMMON_005'}),
    ]) {
      final server = ConcertTestServer()
        ..status = status
        ..body = body;
      await expectLater(
        _create(server),
        throwsA(
          isA<ConcertFailure>().having(
            (e) => e.kind,
            'kind',
            ConcertFailureKind.uncertain,
          ),
        ),
      );
      expect(server.posts, 1);
    }
    expect(await _create(ConcertTestServer()), 72);
  });

  test('서버 필드 오류와 날짜·시간 및 권한 오류를 보존한다', () async {
    for (final (status, code, expectedKind, expectedFields) in [
      (400, 'COMMON_004', ConcertFailureKind.rejected, {'title'}),
      (400, 'CONCERT_010', ConcertFailureKind.rejected, {'startTime'}),
      (400, 'CONCERT_002', ConcertFailureKind.rejected, {'performDate'}),
      (400, 'COMMON_001', ConcertFailureKind.rejected, <String>{}),
      (403, 'AUTH_005', ConcertFailureKind.forbidden, <String>{}),
    ]) {
      final server = ConcertTestServer()
        ..status = status
        ..body = {
          'code': code,
          'errors': [
            {'field': 'title', 'reason': '제목 검증 실패'},
          ],
        };
      await expectLater(
        _create(server),
        throwsA(
          isA<ConcertFailure>()
              .having((e) => e.kind, 'kind', expectedKind)
              .having((e) => e.fields.keys.toSet(), 'fields', expectedFields),
        ),
      );
    }
  });

  test('생성 POST가 실제 인증과 로그 인터셉터의 안전 옵션을 사용한다', () async {
    FlutterSecureStorage.setMockInitialValues({
      SecureStore.accessTokenKey: 'old-access',
      SecureStore.refreshTokenKey: 'refresh-secret',
    });
    final server = ConcertTestServer()
      ..status = 401
      ..body = {'code': 'AUTH_002', 'message': 'private-response'};
    final dio = server.dio()
      ..interceptors.add(
        AuthInterceptor(
          store: SecureStore(const FlutterSecureStorage()),
          plainDio: server.dio(),
          expiry: SessionExpiry(),
        ),
      )
      ..interceptors.add(ApiLogInterceptor(log: server.logs.add));

    await expectLater(
      ConcertService(dio).create({'address': 'private-address'}),
      throwsA(
        isA<ConcertApiFailureDto>().having((e) => e.code, 'code', 'AUTH_002'),
      ),
    );

    expect(server.requests.length, 2);
    expect(server.posts, 2);
    expect(server.requests.first.path, '/api/v1/concerts');
    expect(server.requests.last.path, AuthInterceptor.refreshPath);
    expect(server.requests.first.headers['Authorization'], 'Bearer old-access');
    expect(server.logs.join(), isNot(contains('private-address')));
    expect(server.logs.join(), isNot(contains('private-response')));
  });

  test('타임아웃을 실패 확정으로 해석하지 않는다', () async {
    final server = ConcertTestServer()
      ..networkFailure = DioExceptionType.receiveTimeout;
    await expectLater(
      _create(server),
      throwsA(
        isA<ConcertFailure>().having(
          (e) => e.kind,
          'kind',
          ConcertFailureKind.uncertain,
        ),
      ),
    );
  });
}
