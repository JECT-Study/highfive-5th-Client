import 'package:json_annotation/json_annotation.dart';

part 'concert_edit_values.g.dart';

/// PUT은 부분 수정이 아니다. nullable 필드도 반드시 명시해서 넘긴다.
@JsonSerializable(checked: true, includeIfNull: true)
class ConcertEditValues {
  ConcertEditValues({
    required this.title,
    required List<String> genres,
    required this.recruitTeamCount,
    required this.performDate,
    required this.startTime,
    required this.endTime,
    required this.place,
    required this.address,
    required this.region,
    required this.rentalFee,
    required this.posterImageUrl,
    required this.version,
  }) : genres = List.unmodifiable(genres);

  factory ConcertEditValues.fromJson(Map<String, dynamic> json) =>
      _$ConcertEditValuesFromJson(json);

  @JsonKey(required: true)
  final String title;
  @JsonKey(required: true)
  final List<String> genres;
  @JsonKey(required: true, fromJson: _integer)
  final int recruitTeamCount;
  @JsonKey(required: true)
  final String? performDate;
  @JsonKey(required: true)
  final String? startTime;
  @JsonKey(required: true)
  final String? endTime;
  @JsonKey(required: true)
  final String? place;
  @JsonKey(required: true)
  final String? address;
  @JsonKey(required: true)
  final String? region;
  @JsonKey(required: true, fromJson: _nullableInteger)
  final int? rentalFee;
  @JsonKey(required: true)
  final String? posterImageUrl;
  @JsonKey(required: true, fromJson: _integer)
  final int version;

  static int _integer(Object? value) {
    if (value is int) return value;
    throw const FormatException('정수 필드의 누락 또는 잘못된 타입');
  }

  static int? _nullableInteger(Object? value) =>
      value == null ? null : _integer(value);

  Map<String, dynamic> toJson() => _$ConcertEditValuesToJson(this);
}

/// API 공통 명세: 서버 업무 시간대 Asia/Seoul (현재 UTC+09:00, DST 없음).
/// 기기의 로컬 시간대가 아니라 UTC 순간에서 날짜를 계산한다.
DateTime concertBusinessDate(DateTime instant) {
  final seoul = instant.toUtc().add(const Duration(hours: 9));
  return DateTime(seoul.year, seoul.month, seoul.day);
}

/// 호출자는 상세 응답에서 전체 값과 현재 세션의 참여 여부를 함께 전달한다.
/// 게시 상태로 수정 권한을 추정하지 않는다. 지난 공연도 날짜를 유지하면 수정 가능하다.
class ConcertEditSnapshot {
  ConcertEditSnapshot({
    required this.values,
    required this.isParticipant,
    required this.joinedTeamCount,
    required List<({String code, String name})> genres,
  }) : genres = List.unmodifiable(genres);

  final ConcertEditValues values;
  final bool isParticipant;
  final int joinedTeamCount;
  final List<({String code, String name})> genres;
}

/// 입력 문자열은 값으로 변환하기 전에 검증한다. 원본의 숨은 필드는 교체하지 않는다.
class ConcertEditForm {
  ConcertEditForm(ConcertEditValues initial)
    : title = initial.title,
      genres = [...initial.genres],
      recruitTeamCount = '${initial.recruitTeamCount}',
      performDate = initial.performDate,
      startTime = initial.startTime,
      endTime = initial.endTime,
      place = initial.place ?? '',
      address = initial.address ?? '',
      rentalFee = initial.rentalFee?.toString() ?? '';

  String title;
  List<String> genres;
  String recruitTeamCount;
  String? performDate;
  String? startTime;
  String? endTime;
  String place;
  String address;
  String rentalFee;

  Map<String, String> validate(
    ConcertEditSnapshot original, {
    required DateTime today,
  }) {
    final errors = <String, String>{};
    if (title.trim().isEmpty || title.trim().runes.length > 30) {
      errors['title'] = '제목을 1~30자로 입력해 주세요.';
    }
    // 이미 저장된 장르는 목록이 바뀌어도 보존한다. 새 선택만 현재 코드 목록을 따른다.
    final allowed = {
      ...original.values.genres,
      for (final genre in original.genres) genre.code,
    };
    if (genres.isEmpty || !genres.every(allowed.contains)) {
      errors['genres'] = '장르를 한 개 이상 선택해 주세요.';
    }
    final teams = int.tryParse(recruitTeamCount);
    if (!RegExp(r'^\d+$').hasMatch(recruitTeamCount) ||
        teams == null ||
        teams < 1 ||
        teams < original.joinedTeamCount ||
        teams > 2147483647) {
      errors['recruitTeamCount'] = '합류한 팀 수 이상, 한 팀 이상 입력해 주세요.';
    }
    final date = performDate;
    if (date != null && date != original.values.performDate) {
      final parsed = DateTime.tryParse(date);
      final day = DateTime(today.year, today.month, today.day);
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) ||
          parsed == null ||
          parsed.toIso8601String().substring(0, 10) != date ||
          parsed.isBefore(day)) {
        errors['performDate'] = '오늘 또는 이후 날짜를 선택해 주세요.';
      }
    }
    bool validTime(String time) {
      final match = RegExp(r'^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d(\.\d{1,9})?)?$')
          .hasMatch(time);
      return match;
    }

    if ((startTime == null) != (endTime == null) ||
        (startTime != null && !validTime(startTime!)) ||
        (endTime != null && !validTime(endTime!))) {
      errors['startTime'] = '시작 시간과 종료 시간을 함께 선택해 주세요.';
    }
    if (place.runes.length > 100) errors['place'] = '장소명은 100자까지 입력해 주세요.';
    if (address.runes.length > 200) errors['address'] = '주소는 200자까지 입력해 주세요.';
    final fee = rentalFee.trim();
    if (fee.isNotEmpty &&
        (!RegExp(r'^\d+$').hasMatch(fee) ||
            int.tryParse(fee) == null ||
            int.parse(fee) > 2147483647)) {
      errors['rentalFee'] = '대관비는 0~2,147,483,647원으로 입력해 주세요.';
    }
    return errors;
  }

  ConcertEditValues replace(ConcertEditValues original) {
    String? optional(String text, String? old) =>
        text == (old ?? '') ? old : (text.trim().isEmpty ? null : text.trim());
    return ConcertEditValues(
      title: title == original.title ? original.title : title.trim(),
      genres: genres,
      recruitTeamCount: int.parse(recruitTeamCount),
      performDate: performDate,
      startTime: startTime,
      endTime: endTime,
      place: optional(place, original.place),
      address: optional(address, original.address),
      region: original.region,
      rentalFee: rentalFee.trim().isEmpty ? null : int.parse(rentalFee.trim()),
      posterImageUrl: original.posterImageUrl,
      version: original.version,
    );
  }
}
