import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/dto/concert_detail_dto.dart';
import 'package:highfive/features/performances/models/concert_detail.dart';
import 'package:highfive/features/performances/models/concert_status.dart';
import 'package:highfive/features/performances/models/recruitment_status.dart';

Map<String, dynamic> _data() {
  final response = jsonDecode(
    File('../../docs/api/examples/concert-detail.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  return response['data'] as Map<String, dynamic>;
}

void main() {
  test('GET 초안의 버전과 지역 시각 및 중첩 데이터를 보존한다', () {
    final model = ConcertDetailDto.fromJson(_data()).toModel();

    expect(
      model,
      const ConcertDetail(
        concertId: 12,
        title: '겨울 합동공연',
        genres: ['ROCK', 'INDIE'],
        recruitTeamCount: 3,
        performDate: '2026-12-20',
        startTime: null,
        endTime: null,
        place: '홍대 롤링홀',
        address: '서울 마포구 어울마당로 35',
        region: 'SEOUL',
        rentalFee: 500000,
        posterImageUrl: null,
        status: ConcertStatus.recruiting,
        hostBandId: 3,
        myBandIds: [3],
        myPermissions: ConcertPermissions(
          isHostLeader: true,
          isTeamLeader: true,
        ),
        recruitment: ConcertRecruitment(
          recruitPostId: 5,
          status: RecruitmentStatus.recruiting,
          deadline: '2026-12-01',
          joinedTeamCount: 1,
          recruitTeamCount: 3,
          newInquiryCount: 2,
        ),
        version: 3,
        updatedAt: '2026-11-11T14:02:00',
      ),
    );
  });

  test('미정 값과 없는 모집 공고는 null로 남긴다', () {
    final data = _data()
      ..['performDate'] = null
      ..['place'] = null
      ..['address'] = null
      ..['region'] = null
      ..['rentalFee'] = null
      ..['recruitment'] = null;

    final model = ConcertDetailDto.fromJson(data).toModel();

    expect([
      model.performDate,
      model.place,
      model.address,
      model.region,
      model.rentalFee,
      model.recruitment,
    ], everyElement(isNull));
  });

  test('자정을 넘는 시각과 무료 대관 및 여러 내 밴드를 보존한다', () {
    final data = _data()
      ..['startTime'] = '23:30:00'
      ..['endTime'] = '01:00:00'
      ..['rentalFee'] = 0
      ..['myBandIds'] = [3, 9]
      ..['myPermissions'] = {'isHostLeader': false, 'isTeamLeader': true};

    final model = ConcertDetailDto.fromJson(data).toModel();

    expect(model.startTime, '23:30:00');
    expect(model.endTime, '01:00:00');
    expect(model.rentalFee, 0);
    expect(model.myBandIds, [3, 9]);
    expect(model.myPermissions.isHostLeader, isFalse);
    expect(model.myPermissions.isTeamLeader, isTrue);
  });

  for (final entry in {
    'BEFORE_RECRUIT': ConcertStatus.beforeRecruit,
    'RECRUITING': ConcertStatus.recruiting,
    'SELLING': ConcertStatus.selling,
    'SALE_PAUSED': ConcertStatus.salePaused,
    'SALE_CLOSED': ConcertStatus.saleClosed,
    'FUTURE_CODE': ConcertStatus.unknown,
  }.entries) {
    test('공연 상태 ${entry.key}를 변환하며 권한을 바꾸지 않는다', () {
      final data = _data()
        ..['status'] = entry.key
        ..['myPermissions'] = {'isHostLeader': false, 'isTeamLeader': false};

      final model = ConcertDetailDto.fromJson(data).toModel();

      expect(model.status, entry.value);
      expect(
        model.myPermissions,
        const ConcertPermissions(isHostLeader: false, isTeamLeader: false),
      );
    });
  }

  for (final entry in {
    'RECRUITING': RecruitmentStatus.recruiting,
    'CLOSED': RecruitmentStatus.closed,
    'FUTURE_CODE': RecruitmentStatus.unknown,
  }.entries) {
    test('모집 상태 ${entry.key}를 공연 상태와 구분해 변환한다', () {
      final data = _data();
      (data['recruitment'] as Map<String, dynamic>)['status'] = entry.key;

      expect(
        ConcertDetailDto.fromJson(data).toModel().recruitment!.status,
        entry.value,
      );
    });
  }

  for (final key in ['concertId', 'version', 'updatedAt', 'myPermissions']) {
    test('필수 $key 누락은 임의 기본값 없이 실패한다', () {
      final data = _data()..remove(key);

      expect(() => ConcertDetailDto.fromJson(data), throwsA(isA<TypeError>()));
    });
  }

  for (final entry in {
    'concertId': 12.5,
    'version': 3.9,
    'rentalFee': 500000.5,
    'hostBandId': 3.9,
  }.entries) {
    test('정수 ${entry.key} 필드는 소수 응답을 절삭하지 않고 거부한다', () {
      final data = _data()..[entry.key] = entry.value;

      expect(() => ConcertDetailDto.fromJson(data), throwsA(isA<TypeError>()));
    });
  }

  test('내 밴드 ID 목록의 소수를 거부한다', () {
    final data = _data()..['myBandIds'] = [3, 9.1];

    expect(() => ConcertDetailDto.fromJson(data), throwsA(isA<TypeError>()));
  });

  test('모집 정보의 정수도 소수 응답을 거부한다', () {
    final data = _data();
    (data['recruitment'] as Map<String, dynamic>)['joinedTeamCount'] = 1.9;

    expect(() => ConcertDetailDto.fromJson(data), throwsA(isA<TypeError>()));
  });

  for (final invalid in [
    <String, dynamic>{},
    <String, dynamic>{'isHostLeader': true},
    <String, dynamic>{'isHostLeader': null, 'isTeamLeader': false},
    <String, dynamic>{'isHostLeader': 'true', 'isTeamLeader': false},
  ]) {
    test('잘못된 권한 $invalid 응답은 파싱을 거부한다', () {
      final data = _data()..['myPermissions'] = invalid;

      expect(() => ConcertDetailDto.fromJson(data), throwsA(isA<TypeError>()));
    });
  }

  test('DTO 목록을 바꿔도 이미 변환한 모델의 불변 목록은 유지된다', () {
    final dto = ConcertDetailDto.fromJson(_data());
    final model = dto.toModel();

    dto.genres.add('ETC');
    dto.myBandIds.add(99);

    expect(model.genres, ['ROCK', 'INDIE']);
    expect(model.myBandIds, [3]);
    expect(() => model.genres.add('ETC'), throwsUnsupportedError);
    expect(() => model.myBandIds.add(99), throwsUnsupportedError);
  });
}
