import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/performances/data/dto/concert_create_dto.dart';
import 'package:highfive/features/performances/data/services/concert_creation_service.dart';

/// Flutter의 위젯 테스트용 가짜 HTTP 대신 loopback 서버를 사용한다.
class _RealHttpOverrides extends HttpOverrides {}

/// 네트워크 대신 쓰는 어댑터. 받은 요청을 기록하고, 정해진 응답을 돌려주거나 연결 오류를 낸다.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter.respond(this.statusCode, this.body, {this.sendBodyFirst = false})
    : failure = null;

  /// [sendBodyFirst]면 본문을 다 보낸 뒤(서버가 받았을 수 있음) 실패하고, 아니면 연결 단계에서 실패한다.
  _FakeAdapter.fail(DioExceptionType this.failure, {this.sendBodyFirst = false})
    : statusCode = 0,
      body = null;

  final int statusCode;
  final Map<String, Object?>? body;
  final DioExceptionType? failure;
  final bool sendBodyFirst;

  /// 응답을 붙잡아 둘 때 쓴다. 테스트가 끝나면 풀어 준다.
  Completer<void>? hold;
  final started = Completer<void>();
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    if (sendBodyFirst) await requestStream?.drain<void>();
    started.complete();
    if (failure case final type?) {
      throw DioException(requestOptions: options, type: type);
    }
    await hold?.future;
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ConcertCreationService _service(_FakeAdapter adapter) => ConcertCreationService(
  Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = adapter,
);

Map<String, Object?> _created(
  Object? concertId, {
  String code = 'COMMON_000',
}) => {
  'status': 201,
  'code': code,
  'message': '요청이 성공했습니다.',
  'data': {'concertId': concertId},
};

const _request = ConcertCreateRequestDto(
  bandId: 3,
  title: '겨울 합동공연',
  genres: ['ROCK', 'INDIE'],
  recruitTeamCount: 3,
  performDate: '2026-12-20',
  rentalFee: null,
);

void main() {
  test('로컬 HTTP 서버에서 실제 POST 경로·JSON 본문·201 겉봉투를 검증한다', () async {
    await HttpOverrides.runWithHttpOverrides(() async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final incoming = server.first.timeout(const Duration(seconds: 5));
      final dio = Dio(
        BaseOptions(
          baseUrl: 'http://${server.address.address}:${server.port}',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      addTearDown(() => dio.close(force: true));
      final completed = expectLater(
        ConcertCreationService(dio).create(_request),
        completion(
          isA<ConcertCreateResponseDto>().having(
            (response) => response.concertId,
            'concertId',
            12,
          ),
        ),
      );

      final request = await incoming;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/v1/concerts');
      expect(jsonDecode(await utf8.decoder.bind(request).join()), {
        'bandId': 3,
        'title': '겨울 합동공연',
        'genres': ['ROCK', 'INDIE'],
        'recruitTeamCount': 3,
        'performDate': '2026-12-20',
        'rentalFee': null,
      });
      request.response
        ..statusCode = HttpStatus.created
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(_created(12)));
      await request.response.close();

      await completed;
    }, _RealHttpOverrides());
  });

  test('POST /api/v1/concerts에 Swagger 필드로 보내고 data.concertId를 읽는다', () async {
    final adapter = _FakeAdapter.respond(201, _created(12));

    final response = await _service(adapter).create(_request);

    expect(response.concertId, 12);
    expect(adapter.request?.method, 'POST');
    expect(adapter.request?.path, '/api/v1/concerts');
    expect(adapter.request?.followRedirects, isFalse);
    expect(adapter.request?.data, {
      'bandId': 3,
      'title': '겨울 합동공연',
      'genres': ['ROCK', 'INDIE'],
      'recruitTeamCount': 3,
      'performDate': '2026-12-20',
      'rentalFee': null,
    });
  });

  test('성공 응답이 201·COMMON_000·양의 정수 ID가 아니면 해석 실패로 던진다', () async {
    final cases = {
      '200 응답': _FakeAdapter.respond(200, _created(12)),
      '본문 상태 불일치': _FakeAdapter.respond(201, {..._created(12), 'status': 200}),
      '소수 본문 상태': _FakeAdapter.respond(201, {..._created(12), 'status': 201.5}),
      '성공 코드 아님': _FakeAdapter.respond(201, _created(12, code: 'COMMON_999')),
      '소수 ID': _FakeAdapter.respond(201, _created(12.5)),
      '0 ID': _FakeAdapter.respond(201, _created(0)),
    };

    for (final MapEntry(key: name, value: adapter) in cases.entries) {
      await expectLater(
        _service(adapter).create(_request),
        throwsA(isA<FormatException>()),
        reason: name,
      );
    }
  });

  test('오류 응답이면 서버 오류 코드를 담은 ApiException을 던진다', () async {
    final adapter = _FakeAdapter.respond(400, {
      'status': 400,
      'code': 'CONCERT_002',
      'message': '공연 날짜는 오늘 이후여야 합니다.',
    });

    await expectLater(
      _service(adapter).create(_request),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 400)
            .having((e) => e.code, 'code', 'CONCERT_002'),
      ),
    );
  });

  test('본문을 보내기 전 연결 단계에서 실패하면 다시 보내도 되는 NetworkException이다', () async {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.connectionError,
    ]) {
      await expectLater(
        _service(_FakeAdapter.fail(type)).create(_request),
        throwsA(isA<NetworkException>()),
        reason: '$type',
      );
    }
  });

  test('본문을 보낸 뒤 응답 없이 끊기면 결과를 모르는 UnknownApiException이다', () async {
    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      await expectLater(
        _service(_FakeAdapter.fail(type, sendBodyFirst: true)).create(_request),
        throwsA(isA<UnknownApiException>()),
        reason: '$type',
      );
    }
  });

  test('취소는 본문 전송 전이면 재시도를 막지 않고, 전송 후면 결과 불명이다', () async {
    for (final sent in [false, true]) {
      final hold = Completer<void>();
      addTearDown(hold.complete);
      final adapter = _FakeAdapter.respond(
        201,
        _created(12),
        sendBodyFirst: sent,
      )..hold = hold;
      final abandoned = Completer<void>();

      final pending = _service(adapter)
          .create(_request, abandoned: abandoned.future);
      final completed = expectLater(
        pending,
        throwsA(sent ? isA<UnknownApiException>() : isA<NetworkException>()),
      );
      await adapter.started.future.timeout(const Duration(seconds: 5));
      abandoned.complete();
      await completed;
    }
  });
}
