import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:highfive/features/performances/data/repositories/concert_repository.dart';
import 'package:highfive/features/performances/data/services/concert_service.dart';

/// 네트워크 경계의 테스트 서버. 운영 앱에는 포함되지 않는다.
class ConcertTestServer implements HttpClientAdapter {
  int status = 201;
  Object? body = {
    'code': 'COMMON_000',
    'data': {'concertId': 72},
  };
  List<Map<String, String>> genres = [
    {'code': 'SERVER_GENRE', 'name': '서버 제공 장르'},
  ];
  int genreFailures = 0;
  int posts = 0;
  final requests = <RequestOptions>[];
  final logs = <String>[];
  final posted = Completer<void>();
  Completer<void>? release;
  DioExceptionType? networkFailure;

  Dio dio() =>
      Dio(BaseOptions(baseUrl: 'https://concert.test'))
        ..httpClientAdapter = this;

  ConcertRepository repository() => ConcertRepository(ConcertService(dio()));
  ConcertService repositoryService() => ConcertService(dio());

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.method == 'GET') {
      if (genreFailures-- > 0) {
        throw DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        );
      }
      return json(200, {
        'code': 'COMMON_000',
        'data': {'GENRE': genres},
      });
    }
    posts++;
    if (!posted.isCompleted) posted.complete();
    await release?.future;
    if (networkFailure case final type?) {
      throw DioException(requestOptions: options, type: type);
    }
    return json(status, body);
  }

  static ResponseBody json(int status, Object? body) => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}
