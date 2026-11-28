// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concert_edit_values.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConcertEditValues _$ConcertEditValuesFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ConcertEditValues', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'title',
          'genres',
          'recruitTeamCount',
          'performDate',
          'startTime',
          'endTime',
          'place',
          'address',
          'region',
          'rentalFee',
          'posterImageUrl',
          'version',
        ],
      );
      final val = ConcertEditValues(
        title: $checkedConvert('title', (v) => v as String),
        genres: $checkedConvert(
          'genres',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        recruitTeamCount: $checkedConvert(
          'recruitTeamCount',
          (v) => ConcertEditValues._integer(v),
        ),
        performDate: $checkedConvert('performDate', (v) => v as String?),
        startTime: $checkedConvert('startTime', (v) => v as String?),
        endTime: $checkedConvert('endTime', (v) => v as String?),
        place: $checkedConvert('place', (v) => v as String?),
        address: $checkedConvert('address', (v) => v as String?),
        region: $checkedConvert('region', (v) => v as String?),
        rentalFee: $checkedConvert(
          'rentalFee',
          (v) => ConcertEditValues._nullableInteger(v),
        ),
        posterImageUrl: $checkedConvert('posterImageUrl', (v) => v as String?),
        version: $checkedConvert(
          'version',
          (v) => ConcertEditValues._integer(v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ConcertEditValuesToJson(ConcertEditValues instance) =>
    <String, dynamic>{
      'title': instance.title,
      'genres': instance.genres,
      'recruitTeamCount': instance.recruitTeamCount,
      'performDate': instance.performDate,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'place': instance.place,
      'address': instance.address,
      'region': instance.region,
      'rentalFee': instance.rentalFee,
      'posterImageUrl': instance.posterImageUrl,
      'version': instance.version,
    };
