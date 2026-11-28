import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/network/api_log_interceptor.dart';
import 'package:highfive/features/performances/data/repositories/concert_edit_repository.dart';
import 'package:highfive/features/performances/data/services/concert_edit_service.dart';
import 'package:highfive/features/performances/models/concert_edit_failure.dart';
import 'package:highfive/features/performances/models/concert_edit_values.dart';

import '../../edit_fixture.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.status, this.body, {this.disconnect = false});
  final int status;
  final Object? body;
  final bool disconnect;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    if (disconnect) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.receiveTimeout,
      );
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

LiveConcertEditRepository _repository(_Adapter adapter, {List<String>? logs}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
    ..httpClientAdapter = adapter;
  if (logs != null) dio.interceptors.add(ApiLogInterceptor(log: logs.add));
  return LiveConcertEditRepository(
    service: ConcertEditService(dio),
    concertId: 48,
    reload: () async => editSnapshot(),
  );
}

void main() {
  test('확인된 PUT에 원본의 전체 필드와 버전을 전송한다', () async {
    final adapter = _Adapter(200, {
      'code': 'COMMON_000',
      'data': <String, Object?>{},
    });
    final original = editSnapshot().values;
    final form = ConcertEditForm(original)..title = '다른 제목';

    await _repository(adapter).save(form.replace(original));

    expect(adapter.request!.method, 'PUT');
    expect(adapter.request!.path, '/api/v1/concerts/48');
    expect(adapter.request!.data, {...editJson(), 'title': '다른 제목'});
  });

  final cases =
      <({int status, String code, ConcertEditFailureKind kind, String? field})>[
        (
          status: 400,
          code: 'COMMON_004',
          kind: ConcertEditFailureKind.invalid,
          field: 'title',
        ),
        (
          status: 400,
          code: 'COMMON_001',
          kind: ConcertEditFailureKind.invalid,
          field: null,
        ),
        (
          status: 400,
          code: 'CONCERT_010',
          kind: ConcertEditFailureKind.invalid,
          field: 'startTime',
        ),
        (
          status: 400,
          code: 'CONCERT_002',
          kind: ConcertEditFailureKind.invalid,
          field: 'performDate',
        ),
        (
          status: 400,
          code: 'CONCERT_011',
          kind: ConcertEditFailureKind.invalid,
          field: 'performDate',
        ),
        (
          status: 409,
          code: 'CONCERT_003',
          kind: ConcertEditFailureKind.invalid,
          field: 'recruitTeamCount',
        ),
        (
          status: 409,
          code: 'CONCERT_012',
          kind: ConcertEditFailureKind.conflict,
          field: null,
        ),
        (
          status: 404,
          code: 'CONCERT_001',
          kind: ConcertEditFailureKind.missing,
          field: null,
        ),
        (
          status: 401,
          code: 'AUTH_002',
          kind: ConcertEditFailureKind.authentication,
          field: null,
        ),
        (
          status: 401,
          code: 'AUTH_004',
          kind: ConcertEditFailureKind.authentication,
          field: null,
        ),
        (
          status: 403,
          code: 'AUTH_005',
          kind: ConcertEditFailureKind.forbidden,
          field: null,
        ),
        (
          status: 500,
          code: 'COMMON_999',
          kind: ConcertEditFailureKind.uncertain,
          field: null,
        ),
      ];
  for (final row in cases) {
    test('${row.code} 응답은 ${row.kind.name}과 해당 필드 오류로 전달된다', () async {
      final adapter = _Adapter(row.status, {
        'code': row.code,
        if (row.code == 'COMMON_004')
          'errors': [
            {'field': 'title', 'reason': '서버 필드 검증 사유'},
          ],
      });
      await expectLater(
        _repository(adapter).save(editSnapshot().values),
        throwsA(
          isA<ConcertEditFailure>()
              .having((e) => e.kind, 'kind', row.kind)
              .having(
                (e) => e.fields.keys,
                'fields',
                row.field == null ? isEmpty : [row.field],
              ),
        ),
      );
    });
  }

  for (final adapter in [
    _Adapter(200, {'code': 'COMMON_000'}),
    _Adapter(200, {'code': 'WRONG', 'data': <String, Object?>{}}),
    _Adapter(200, null, disconnect: true),
  ]) {
    test('응답 유실·성공 형식 오류는 결과 불명으로 처리한다 (${adapter.body})', () async {
      await expectLater(
        _repository(adapter).save(editSnapshot().values),
        throwsA(
          isA<ConcertEditFailure>().having(
            (e) => e.kind,
            'kind',
            ConcertEditFailureKind.uncertain,
          ),
        ),
      );
    });
  }

  for (final status in [200, 400]) {
    test('공연 폼과 서버 오류의 주소·포스터를 로그에 남기지 않는다 ($status)', () async {
      final logs = <String>[];
      final adapter = _Adapter(status, {
        'code': status == 200 ? 'COMMON_000' : 'COMMON_004',
        'data': <String, Object?>{},
        'message': 'private-response-data',
      });
      try {
        await _repository(adapter, logs: logs).save(editSnapshot().values);
      } on ConcertEditFailure {
        // 실패 로그도 동일한 개인정보 제외 규칙을 따른다.
      }
      expect(logs.join(), isNot(contains('기존 상세 주소')));
      expect(logs.join(), isNot(contains('existing-poster.png')));
      expect(logs.join(), isNot(contains('private-response-data')));
      expect(logs.join(), contains('PUT'));
    });
  }
}
