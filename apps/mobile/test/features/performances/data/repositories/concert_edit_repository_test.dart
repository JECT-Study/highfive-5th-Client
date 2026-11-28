import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/repositories/concert_edit_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/data/services/concert_edit_service.dart';
import 'package:highfive/features/performances/models/concert_edit_failure.dart';
import 'package:highfive/features/performances/models/concert_edit_form.dart';
import 'package:highfive/features/performances/models/concert_update.dart';

class _LocalServer {
  _LocalServer._(this._server) {
    _server.listen(_handle);
  }

  static Future<_LocalServer> start() async =>
      _LocalServer._(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));

  final HttpServer _server;
  final requests = <({String method, String path, Object? body})>[];
  int status = 200;
  Object? body = {
    'status': 200,
    'code': 'COMMON_000',
    'data': <String, Object?>{},
  };
  bool dropConnection = false;

  String get baseUrl => 'http://${_server.address.host}:${_server.port}';

  Future<void> _handle(HttpRequest request) async {
    final text = await utf8.decoder.bind(request).join();
    requests.add((
      method: request.method,
      path: request.uri.path,
      body: text.isEmpty ? null : jsonDecode(text),
    ));
    if (dropConnection) {
      final socket = await request.response.detachSocket(writeHeaders: false);
      socket.destroy();
      return;
    }
    request.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    await request.response.close();
  }

  Future<void> close() async {
    await _server.close(force: true);
  }
}

/// 실제 PUT 서비스·직렬화·실패 매핑을 루프백 서버로만 호출한다.
ConcertEditRepository _repository(_LocalServer server) {
  final dio = Dio(
    BaseOptions(baseUrl: server.baseUrl, contentType: Headers.jsonContentType),
  );
  addTearDown(() => dio.close(force: true));
  return RemoteConcertEditRepository(ConcertEditService(dio));
}

final _update = ConcertUpdate.fromDetail(FakeConcertRepository.sample)
    .copyWith(title: '바뀐 제목', startTime: '19:00:00', endTime: '21:00:00');

Map<String, Object?> _error(String code, [List<Object?> errors = const []]) => {
  'code': code,
  'errors': errors,
};

void main() {
  late _LocalServer server;
  setUp(() async => server = await _LocalServer.start());
  tearDown(() => server.close());

  test('PUT 서비스가 null을 포함한 전체 수정 값을 직렬화한다', () async {
    await _repository(server).update(12, _update);

    final request = server.requests.single;
    expect(request.method, 'PUT');
    expect(request.path, '/api/v1/concerts/12');
    expect(request.body, {
      'title': '바뀐 제목',
      'genres': ['ROCK', 'INDIE'],
      'recruitTeamCount': 3,
      'performDate': '2026-12-20',
      'startTime': '19:00:00',
      'endTime': '21:00:00',
      'place': '홍대 롤링홀',
      'address': '서울 마포구 어울마당로 35',
      'region': 'SEOUL',
      'rentalFee': 500000,
      'posterImageUrl': null,
      'version': 3,
    });
  });

  test('선택 항목을 비워도 직렬화에서 키를 빼지 않는다', () async {
    await _repository(server).update(
      12,
      _update.copyWith(
        performDate: null,
        startTime: null,
        endTime: null,
        place: null,
        address: null,
        region: null,
        rentalFee: null,
        posterImageUrl: null,
      ),
    );

    final body = server.requests.single.body! as Map<String, dynamic>;
    expect(body, hasLength(12));
    for (final field in [
      'performDate',
      'startTime',
      'endTime',
      'place',
      'address',
      'region',
      'rentalFee',
      'posterImageUrl',
    ]) {
      expect(body.containsKey(field), isTrue, reason: field);
      expect(body[field], isNull, reason: field);
    }
  });

  test('응답의 상태·코드를 기능 전용 실패 타입으로 바꾼다', () async {
    final cases =
        <
          (
            int,
            Map<String, Object?>,
            ConcertEditFailureReason,
            Map<ConcertEditField, ConcertEditIssue>,
          )
        >[
          (409, _error('CONCERT_012'), ConcertEditFailureReason.conflict, {}),
          (404, _error('CONCERT_001'), ConcertEditFailureReason.missing, {}),
          (403, _error('AUTH_005'), ConcertEditFailureReason.forbidden, {}),
          (400, _error('COMMON_001'), ConcertEditFailureReason.invalid, {}),
          (
            400,
            _error('CONCERT_002'),
            ConcertEditFailureReason.invalid,
            {ConcertEditField.performDate: ConcertEditIssue.pastDate},
          ),
          (
            400,
            _error('CONCERT_011'),
            ConcertEditFailureReason.invalid,
            {
              ConcertEditField.performDate:
                  ConcertEditIssue.beforeRecruitDeadline,
            },
          ),
          (
            400,
            _error('CONCERT_010'),
            ConcertEditFailureReason.invalid,
            {ConcertEditField.time: ConcertEditIssue.timePair},
          ),
          (
            409,
            _error('CONCERT_003'),
            ConcertEditFailureReason.invalid,
            {
              ConcertEditField.recruitTeamCount:
                  ConcertEditIssue.belowJoinedTeams,
            },
          ),
          (500, _error('COMMON_005'), ConcertEditFailureReason.unconfirmed, {}),
        ];
    for (final (status, body, reason, issues) in cases) {
      server
        ..status = status
        ..body = body;
      await expectLater(
        _repository(server).update(12, _update),
        throwsA(
          isA<ConcertEditFailure>()
              .having((e) => e.reason, 'reason', reason)
              .having((e) => e.issues, 'issues', issues),
        ),
      );
    }
  });

  test('입력 오류는 장소명과 주소의 사유를 각각 보존한다', () async {
    server
      ..status = 400
      ..body = _error('COMMON_004', [
        {'field': 'title', 'reason': '제목 사유'},
        {'field': 'genres[0]', 'reason': '장르 사유'},
        {'field': 'place', 'reason': '장소 사유'},
        {'field': 'address', 'reason': '주소 사유'},
        {'field': 'version', 'reason': '필수'},
      ]);

    await expectLater(
      _repository(server).update(12, _update),
      throwsA(
        isA<ConcertEditFailure>()
            .having((e) => e.issues, 'issues', {
              ConcertEditField.title: ConcertEditIssue.rejected,
              ConcertEditField.genres: ConcertEditIssue.rejected,
              ConcertEditField.place: ConcertEditIssue.rejected,
              ConcertEditField.address: ConcertEditIssue.rejected,
            })
            .having((e) => e.serverReasons, 'serverReasons', {
              ConcertEditField.title: '제목 사유',
              ConcertEditField.genres: '장르 사유',
              ConcertEditField.place: '장소 사유',
              ConcertEditField.address: '주소 사유',
            }),
      ),
    );
  });

  test('요청 수신 뒤 응답이 끊기면 결과 미확인으로 남긴다', () async {
    server.dropConnection = true;
    await expectLater(
      _repository(server).update(12, _update),
      throwsA(
        isA<ConcertEditFailure>().having(
          (e) => e.reason,
          'reason',
          ConcertEditFailureReason.unconfirmed,
        ),
      ),
    );
    expect(server.requests, hasLength(1));
  });
}
