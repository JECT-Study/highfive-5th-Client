import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/auth/data/dto/profile_dto.dart';
import 'package:highfive/features/auth/data/services/profile_service.dart';
import 'package:highfive/features/auth/models/next_step.dart';
import 'package:highfive/features/auth/models/nickname_check_result.dart';

/// 네트워크 대신 정해진 응답을 돌려주고 받은 요청을 기록한다.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.statusCode, this.body);

  final int statusCode;
  final Map<String, Object?> body;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
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

(ProfileService, _FakeAdapter) _service(
  int statusCode,
  Map<String, Object?> body,
) {
  final adapter = _FakeAdapter(statusCode, body);
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
    ..httpClientAdapter = adapter;
  return (ProfileService(dio), adapter);
}

Map<String, Object?> _ok(Map<String, Object?> data) => {
  'status': 200,
  'code': 'COMMON_000',
  'message': '요청이 성공했습니다.',
  'data': data,
};

const _request = ProfileRequestDto(
  nickname: '두현',
  genreCodes: ['ROCK', 'ETC'],
  genreCustomName: '시티팝',
  positionCodes: ['VOCAL'],
  positionCustomName: null,
  profileImageUrl: null,
);

void main() {
  group('checkNickname', () {
    test('GET nickname-availability에 닉네임을 query로 보내고 결과를 읽는다', () async {
      final (service, adapter) = _service(
        200,
        _ok({'available': true, 'reason': null}),
      );

      final response = await service.checkNickname('두현');

      expect(adapter.request?.method, 'GET');
      expect(adapter.request?.path, '/api/v1/users/nickname-availability');
      expect(adapter.request?.queryParameters, {'nickname': '두현'});
      expect(response.toModel(), NicknameCheckResult.available);
    });

    test('available: false면 reason을 결과로 바꾼다', () async {
      for (final (reason, expected) in [
        ('INVALID_LENGTH', NicknameCheckResult.invalidLength),
        ('INVALID_CHARACTER', NicknameCheckResult.invalidCharacter),
        ('DUPLICATED', NicknameCheckResult.duplicated),
        ('SOMETHING_NEW', NicknameCheckResult.unavailable),
        (null, NicknameCheckResult.unavailable),
      ]) {
        final (service, _) = _service(
          200,
          _ok({'available': false, 'reason': reason}),
        );

        final response = await service.checkNickname('두현');

        expect(response.toModel(), expected, reason: '$reason');
      }
    });
  });

  group('saveProfile', () {
    test('PUT users/me/profile에 본문을 보내고 nextStep을 읽는다', () async {
      final (service, adapter) = _service(
        200,
        _ok({'status': 'ACTIVE', 'nextStep': 'BAND_START'}),
      );

      final response = await service.saveProfile(_request);

      expect(adapter.request?.method, 'PUT');
      expect(adapter.request?.path, '/api/v1/users/me/profile');
      expect(adapter.request?.data, {
        'nickname': '두현',
        'genreCodes': ['ROCK', 'ETC'],
        'genreCustomName': '시티팝',
        'positionCodes': ['VOCAL'],
        'positionCustomName': null,
        'profileImageUrl': null,
      });
      expect(response.toModel(), NextStep.bandStart);
    });

    test('409 USER_001이면 ApiException으로 던진다', () async {
      final (service, _) = _service(409, {
        'status': 409,
        'code': 'USER_001',
        'message': '이미 사용 중인 닉네임입니다.',
      });

      await expectLater(
        service.saveProfile(_request),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 409)
              .having((error) => error.code, 'code', 'USER_001'),
        ),
      );
    });
  });
}
