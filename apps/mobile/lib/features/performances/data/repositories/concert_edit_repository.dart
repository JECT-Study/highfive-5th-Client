import 'package:dio/dio.dart';

import '../../models/concert_edit_failure.dart';
import '../../models/concert_edit_values.dart';
import '../dto/concert_edit_request_dto.dart';
import '../services/concert_edit_service.dart';

/// 상세 호출자가 같은 공연의 최신 전체 정보와 현재 권한을 재조회해야 한다.
abstract interface class ConcertEditRepository {
  Future<void> save(ConcertEditValues values);
  Future<ConcertEditSnapshot> reload();
}

class LiveConcertEditRepository implements ConcertEditRepository {
  LiveConcertEditRepository({
    required this._service,
    required int concertId,
    required this._reload,
  }) : _concertId = concertId {
    if (concertId <= 0) throw ArgumentError.value(concertId, 'concertId');
  }

  final ConcertEditService _service;
  final int _concertId;
  final Future<ConcertEditSnapshot> Function() _reload;

  @override
  Future<ConcertEditSnapshot> reload() async {
    try {
      return await _reload();
    } on DioException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> save(ConcertEditValues values) async {
    try {
      await _service.replace(_concertId, ConcertEditRequestDto(values));
    } on DioException catch (error) {
      throw _failure(error);
    } on FormatException {
      throw const ConcertEditFailure(ConcertEditFailureKind.uncertain);
    }
  }

  static ConcertEditFailure _failure(DioException error) {
    final body = error.response?.data;
    final fields = <String, String>{};
    if (body case {'errors': final List<dynamic> entries}) {
      for (final entry in entries) {
        if (entry case {
          'field': final String field,
          'reason': final String reason,
        }) {
          fields[field] = reason;
        }
      }
    }
    final code = body is Map ? body['code'] : null;
    final kind = switch ((error.response?.statusCode, code)) {
      (401, _) => ConcertEditFailureKind.authentication,
      (403, _) => ConcertEditFailureKind.forbidden,
      (404, 'CONCERT_001') => ConcertEditFailureKind.missing,
      (409, 'CONCERT_012') => ConcertEditFailureKind.conflict,
      (
        400,
        'COMMON_004' ||
            'COMMON_001' ||
            'CONCERT_010' ||
            'CONCERT_002' ||
            'CONCERT_011',
      ) ||
      (409, 'CONCERT_003') => ConcertEditFailureKind.invalid,
      _ => ConcertEditFailureKind.uncertain,
    };
    final field = switch (code) {
      'CONCERT_010' => 'startTime',
      'CONCERT_002' || 'CONCERT_011' => 'performDate',
      'CONCERT_003' => 'recruitTeamCount',
      _ => null,
    };
    if (field != null) {
      fields[field] = switch (code) {
        'CONCERT_010' => '시작 시간과 종료 시간을 함께 선택해 주세요.',
        'CONCERT_002' => '오늘 또는 이후 날짜를 선택해 주세요.',
        'CONCERT_011' => '모집 공고 마감일보다 이른 날짜는 선택할 수 없어요.',
        _ => '이미 합류한 팀 수보다 줄일 수 없어요.',
      };
    }
    return ConcertEditFailure(kind, fields: fields);
  }
}
