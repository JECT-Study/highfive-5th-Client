import 'dart:math' as math;

import 'concert_detail.dart';
import 'concert_update.dart';
import 'recruitment_status.dart';

/// 수정 화면의 입력칸. 오류를 어느 칸 아래에 보일지 정한다.
/// 순서는 화면(Figma `공연정보수정`)과 확인 팝업의 줄 순서와 같다.
enum ConcertEditField {
  title,
  genres,
  performDate,
  time,
  place,
  address,
  rentalFee,
  recruitTeamCount,
}

/// 입력칸의 문제. 문구는 화면이 고른다.
enum ConcertEditIssue {
  /// 비었다.
  empty,

  /// 길이를 넘었다 (제목 30자, 장소 100자, 주소 200자).
  tooLong,

  /// 오늘보다 이전 날짜로 바꿨다 (`CONCERT_002`).
  pastDate,

  /// 진행 중인 모집 공고 마감일보다 이르다 (`CONCERT_011`).
  beforeRecruitDeadline,

  /// `HH:mm` 형식이 아니다.
  timeFormat,

  /// 시작·종료 시간 중 하나만 있다 (`CONCERT_010`).
  timePair,

  /// 이미 합류한 팀 수보다 적다 (`CONCERT_003`).
  belowJoinedTeams,

  /// 0 이상의 정수 원이 아니다.
  rentalFeeFormat,

  /// 서버가 받지 않았다 (`COMMON_004`·`COMMON_001`). 서버 문구가 있으면 그 문구를 보인다.
  rejected,
}

/// 서버 업무 시간대 Asia/Seoul(UTC+9, 일광 절약 시간 없음)의 날짜.
/// 기기 시간대가 아니라 UTC 순간에서 계산한다. 시각은 버린다.
DateTime concertBusinessDate(DateTime instant) {
  final seoul = instant.toUtc().add(const Duration(hours: 9));
  return DateTime(seoul.year, seoul.month, seoul.day);
}

/// 수정 화면에 입력 중인 값. 상세 하나로 만들고 화면이 값을 바꾼다.
///
/// 손대지 않은 항목과 화면에 없는 값(지역·포스터)은 상세의 문자열을 그대로 보낸다.
/// 검증은 서버 규칙(명세 1.3)을 미리 알리는 용도이고 최종 판단은 서버가 한다.
class ConcertEditForm {
  ConcertEditForm(this.source)
    : title = source.title,
      genres = {...source.genres},
      recruitTeamCount = source.recruitTeamCount,
      performDate = source.performDate,
      timeUndecided = source.startTime == null && source.endTime == null,
      startTime = _hourMinute(source.startTime),
      endTime = _hourMinute(source.endTime),
      placeUndecided = source.place == null && source.address == null,
      place = source.place ?? '',
      address = source.address ?? '',
      rentalFeeUndecided = source.rentalFee == null,
      rentalFee = source.rentalFee?.toString() ?? '';

  static const titleMaxLength = 30;
  static const placeMaxLength = 100;
  static const addressMaxLength = 200;

  /// 서버 Integer 최대값. 대관비·모집 팀 수의 상한이다.
  static const maxInteger = 2147483647;

  /// 수정 화면을 연 상세. [ConcertUpdate.version]도 여기서 온다.
  final ConcertDetail source;

  String title;

  /// 고른 장르 코드. 기존 장르가 앞, 새로 고른 장르가 뒤에 고른 순서로 온다.
  final Set<String> genres;
  int recruitTeamCount;

  /// `yyyy-MM-dd`. 상세가 미정(null)이면 날짜를 고르기 전까지 null이다.
  String? performDate;

  bool timeUndecided;

  /// `HH:mm` 입력 글자.
  String startTime;
  String endTime;

  bool placeUndecided;
  String place;
  String address;

  bool rentalFeeUndecided;

  /// 숫자만 (쉼표 없이).
  String rentalFee;

  /// 이미 합류한 팀(주최 팀 제외)보다 적게, 1팀보다 적게 줄일 수 없다.
  int get minRecruitTeamCount =>
      math.max(1, source.recruitment?.joinedTeamCount ?? 0);

  bool get _titleChanged => title != source.title;
  bool get _genresChanged => !sameGenres(genres.toList(), source.genres);
  bool get _dateChanged => performDate != source.performDate;
  bool get _timeChanged =>
      timeUndecided != (source.startTime == null && source.endTime == null) ||
      startTime != _hourMinute(source.startTime) ||
      endTime != _hourMinute(source.endTime);
  bool get _placeChanged =>
      placeUndecided != (source.place == null && source.address == null) ||
      place != (source.place ?? '');
  bool get _addressChanged =>
      placeUndecided != (source.place == null && source.address == null) ||
      address != (source.address ?? '');
  bool get _rentalFeeChanged =>
      rentalFeeUndecided != (source.rentalFee == null) ||
      rentalFee != (source.rentalFee?.toString() ?? '');
  bool get _recruitTeamCountChanged =>
      recruitTeamCount != source.recruitTeamCount;

  /// 입력을 하나라도 바꿨는지. 닫을 때 확인 팝업을 띄울지 정한다.
  bool get isDirty =>
      _titleChanged ||
      _genresChanged ||
      _dateChanged ||
      _timeChanged ||
      _placeChanged ||
      _addressChanged ||
      _rentalFeeChanged ||
      _recruitTeamCountChanged;

  /// 입력칸별 문제. 비어 있으면 [toUpdate]를 부를 수 있다.
  ///
  /// 바꾼 항목만 형식을 검사한다. 공고 마감일·합류 팀 수는 서버가 바꾸지 않은 값도 검사하므로
  /// 늘 같이 본다. 지난 날짜는 날짜를 바꿨을 때만 막는다 (기존 날짜는 지났어도 그대로 둘 수 있다).
  Map<ConcertEditField, ConcertEditIssue> validate({required DateTime today}) {
    final issues = <ConcertEditField, ConcertEditIssue>{};
    if (_titleChanged) {
      final trimmed = title.trim();
      if (trimmed.isEmpty) {
        issues[ConcertEditField.title] = ConcertEditIssue.empty;
      } else if (trimmed.length > titleMaxLength) {
        issues[ConcertEditField.title] = ConcertEditIssue.tooLong;
      }
    }
    if (genres.isEmpty) {
      issues[ConcertEditField.genres] = ConcertEditIssue.empty;
    }
    final date = performDate;
    final recruitment = source.recruitment;
    if (date != null) {
      if (_dateChanged && DateTime.parse(date).isBefore(today)) {
        issues[ConcertEditField.performDate] = ConcertEditIssue.pastDate;
      } else if (recruitment != null &&
          recruitment.status == RecruitmentStatus.recruiting &&
          date.compareTo(recruitment.deadline) < 0) {
        // 같은 `yyyy-MM-dd` 형식이라 문자열 순서가 날짜 순서다.
        issues[ConcertEditField.performDate] =
            ConcertEditIssue.beforeRecruitDeadline;
      }
    }
    if (_timeChanged && !timeUndecided) {
      if (startTime.isEmpty && endTime.isEmpty) {
        issues[ConcertEditField.time] = ConcertEditIssue.empty;
      } else if (startTime.isEmpty || endTime.isEmpty) {
        issues[ConcertEditField.time] = ConcertEditIssue.timePair;
      } else if (!_isHourMinute(startTime) || !_isHourMinute(endTime)) {
        issues[ConcertEditField.time] = ConcertEditIssue.timeFormat;
      }
    }
    if (_placeChanged &&
        !placeUndecided &&
        place.trim().length > placeMaxLength) {
      issues[ConcertEditField.place] = ConcertEditIssue.tooLong;
    }
    if (_addressChanged &&
        !placeUndecided &&
        address.trim().length > addressMaxLength) {
      issues[ConcertEditField.address] = ConcertEditIssue.tooLong;
    }
    if (_rentalFeeChanged && !rentalFeeUndecided) {
      if (rentalFee.isEmpty) {
        issues[ConcertEditField.rentalFee] = ConcertEditIssue.empty;
      } else if (!RegExp(r'^\d+$').hasMatch(rentalFee) ||
          (int.tryParse(rentalFee) ?? maxInteger + 1) > maxInteger) {
        issues[ConcertEditField.rentalFee] = ConcertEditIssue.rentalFeeFormat;
      }
    }
    if (recruitTeamCount < minRecruitTeamCount) {
      issues[ConcertEditField.recruitTeamCount] =
          ConcertEditIssue.belowJoinedTeams;
    }
    return issues;
  }

  /// 보낼 전체 교체 값. [validate]가 빈 결과일 때만 부른다.
  ConcertUpdate toUpdate() {
    final original = ConcertUpdate.fromDetail(source);
    return original.copyWith(
      title: _titleChanged ? title.trim() : original.title,
      genres: _genresChanged ? genres.toList() : original.genres,
      recruitTeamCount: recruitTeamCount,
      performDate: performDate,
      startTime: _timeChanged
          ? (timeUndecided ? null : _time(startTime, original.startTime))
          : original.startTime,
      endTime: _timeChanged
          ? (timeUndecided ? null : _time(endTime, original.endTime))
          : original.endTime,
      place: _placeChanged
          ? (placeUndecided || place.trim().isEmpty ? null : place.trim())
          : original.place,
      address: _addressChanged
          ? (placeUndecided || address.trim().isEmpty ? null : address.trim())
          : original.address,
      rentalFee: _rentalFeeChanged
          ? (rentalFeeUndecided ? null : int.parse(rentalFee))
          : original.rentalFee,
    );
  }

  /// 저장하면 실제로 바뀌는 항목. 확인 팝업에 줄로 보이고, 비어 있으면 보낼 것이 없다.
  /// [validate]가 빈 결과일 때만 부른다.
  List<ConcertEditField> changedFields() {
    final before = ConcertUpdate.fromDetail(source);
    final after = toUpdate();
    return [
      if (after.title != before.title) ConcertEditField.title,
      if (!sameGenres(after.genres, before.genres)) ConcertEditField.genres,
      if (after.performDate != before.performDate) ConcertEditField.performDate,
      if (!sameConcertTime(after.startTime, before.startTime) ||
          !sameConcertTime(after.endTime, before.endTime))
        ConcertEditField.time,
      if (after.place != before.place) ConcertEditField.place,
      if (after.address != before.address) ConcertEditField.address,
      if (after.rentalFee != before.rentalFee) ConcertEditField.rentalFee,
      if (after.recruitTeamCount != before.recruitTeamCount)
        ConcertEditField.recruitTeamCount,
    ];
  }

  /// 원래 시각과 같은 `HH:mm`이면 원래 문자열(초 포함)을 그대로 보낸다.
  static String _time(String input, String? original) =>
      original != null && _hourMinute(original) == input
      ? original
      : '$input:00';

  static String _hourMinute(String? time) =>
      time == null || time.length < 5 ? (time ?? '') : time.substring(0, 5);

  static bool _isHourMinute(String time) =>
      RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(time);
}
