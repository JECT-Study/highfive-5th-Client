import 'package:highfive/features/performances/models/concert_edit_values.dart';

Map<String, dynamic> editJson({bool optional = true}) => {
  'title': '기존 공연',
  'genres': ['ROCK', 'LEGACY'],
  'recruitTeamCount': 3,
  'performDate': optional ? '2020-01-01' : null,
  'startTime': optional ? '19:00:35.123' : null,
  'endTime': optional ? '21:30:15' : null,
  'place': optional ? ' 기존 장소 ' : null,
  'address': optional ? '기존 상세 주소' : null,
  'region': optional ? 'SEOUL' : null,
  'rentalFee': optional ? 123456 : null,
  'posterImageUrl': optional ? 'https://files.test/existing-poster.png' : null,
  'version': 7,
};

ConcertEditSnapshot editSnapshot({
  bool participant = true,
  Map<String, dynamic>? values,
}) => ConcertEditSnapshot(
  values: ConcertEditValues.fromJson(values ?? editJson()),
  isParticipant: participant,
  joinedTeamCount: 2,
  genres: [(code: 'ROCK', name: '록'), (code: 'INDIE', name: '인디')],
);
