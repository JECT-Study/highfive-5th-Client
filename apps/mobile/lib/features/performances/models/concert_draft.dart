/// 밴드 선택 기능이 현재 세션에서 대표자임을 확인한 뒤 넘기는 문맥.
/// 사용자에게 ID 입력을 요구하거나 이 화면에서 대표자 여부를 추측하지 않는다.
class HostBand {
  HostBand({required this.id, required this.name}) {
    if (id <= 0 || name.trim().isEmpty) {
      throw ArgumentError('주최 밴드 ID와 표시 이름이 필요합니다.');
    }
  }

  final int id;
  final String name;

  @override
  bool operator ==(Object other) => other is HostBand && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// 서버가 제공하는 선택지. 화면은 name, 요청은 code를 사용한다.
class ConcertGenre {
  const ConcertGenre({required this.code, required this.name});

  final String code;
  final String name;
}

class ConcertTime {
  const ConcertTime(this.hour, this.minute);

  final int hour;
  final int minute;

  bool get valid => hour >= 0 && hour < 24 && minute >= 0 && minute < 60;

  String toJson() =>
      '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}:00';
}

/// 입력 중인 값. 미정은 null, 대관비 빈 칸은 null로 직렬화한다.
/// region/customGenre/포스터 업로드는 합의·연결 전이므로 입력받지 않는다.
class ConcertDraft {
  const ConcertDraft({
    required this.title,
    required this.genres,
    required this.recruitTeamCount,
    this.performDate,
    this.startTime,
    this.endTime,
    this.place = '',
    this.address = '',
    this.rentalFeeText = '',
  });

  final String title;
  final Set<String> genres;
  final int recruitTeamCount;
  final DateTime? performDate;
  final ConcertTime? startTime;
  final ConcertTime? endTime;
  final String place;
  final String address;
  final String rentalFeeText;

  Map<String, String> validate({
    required DateTime today,
    required List<ConcertGenre> availableGenres,
  }) {
    final errors = <String, String>{};
    if (title.trim().isEmpty || title.trim().length > 30) {
      errors['title'] = '공연 제목을 1~30자로 입력해 주세요.';
    }
    if (genres.isEmpty ||
        !genres.every(
          (code) => availableGenres.any((genre) => genre.code == code),
        )) {
      errors['genres'] = '제공된 장르를 한 개 이상 선택해 주세요.';
    }
    if (recruitTeamCount < 1) {
      errors['recruitTeamCount'] = '주최 팀을 제외하고 한 팀 이상 모집해 주세요.';
    }
    final date = performDate;
    if (date != null &&
        DateTime(
          date.year,
          date.month,
          date.day,
        ).isBefore(DateTime(today.year, today.month, today.day))) {
      errors['performDate'] = '오늘 또는 이후 날짜를 선택해 주세요.';
    }
    if ((startTime == null) != (endTime == null) ||
        (startTime != null && !startTime!.valid) ||
        (endTime != null && !endTime!.valid)) {
      errors['startTime'] = '시작 시간과 종료 시간을 함께 선택해 주세요.';
    }
    if (place.trim().length > 100) {
      errors['place'] = '장소명은 100자까지 입력할 수 있어요.';
    }
    if (address.trim().length > 200) {
      errors['address'] = '주소는 200자까지 입력할 수 있어요.';
    }
    final fee = rentalFeeText.trim();
    if (fee.isNotEmpty &&
        (!RegExp(r'^\d+$').hasMatch(fee) ||
            int.tryParse(fee) == null ||
            int.parse(fee) > 2147483647)) {
      errors['rentalFee'] = '대관비는 0~2,147,483,647원으로 입력해 주세요.';
    }
    return errors;
  }

  Map<String, Object?> toJson(HostBand hostBand) => {
    'bandId': hostBand.id,
    'title': title.trim(),
    'genres': genres.toList(),
    'recruitTeamCount': recruitTeamCount,
    'performDate': performDate == null
        ? null
        : '${performDate!.year.toString().padLeft(4, '0')}-'
              '${performDate!.month.toString().padLeft(2, '0')}-'
              '${performDate!.day.toString().padLeft(2, '0')}',
    'startTime': startTime?.toJson(),
    'endTime': endTime?.toJson(),
    'place': place.trim().isEmpty ? null : place.trim(),
    'address': address.trim().isEmpty ? null : address.trim(),
    'rentalFee': rentalFeeText.trim().isEmpty
        ? null
        : int.parse(rentalFeeText.trim()),
    'posterImageUrl': null,
  };
}
