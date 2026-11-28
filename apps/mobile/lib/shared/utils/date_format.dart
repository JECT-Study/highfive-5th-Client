// 서버의 시간대 없는 날짜·시간 문자열을 화면 글자로 바꾼다.
// 서버 값은 `2026-12-20`(LocalDate)·`19:00:00`(LocalTime), 화면은 Figma `2026.10.12 (월)`·`19:00` 형식이다.
// 형식이 다르면 null을 돌려준다. 화면은 null을 값이 없는 것(예: 미정)으로 다룬다.

const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

final _localDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
final _localTime = RegExp(r'^(\d{2}):(\d{2})(?::(\d{2})(?:\.\d+)?)?$');

/// `2026-12-20` → `2026.12.20 (일)`.
String? formatLocalDate(String? value) {
  final date = _parseLocalDate(value);
  if (date == null) return null;
  return '${date.year}.${_twoDigits(date.month)}.${_twoDigits(date.day)} '
      '(${_weekdays[date.weekday - 1]})';
}

/// `2026-12-20` → `12.20(일)` (Figma BandCard).
String? formatLocalMonthDay(String? value) {
  final date = _parseLocalDate(value);
  if (date == null) return null;
  return '${_twoDigits(date.month)}.${_twoDigits(date.day)}'
      '(${_weekdays[date.weekday - 1]})';
}

/// `2026-10-02` → `2026.10.02` (Figma 공연 이력).
String? formatLocalDateDotted(String? value) {
  final date = _parseLocalDate(value);
  if (date == null) return null;
  return '${date.year}.${_twoDigits(date.month)}.${_twoDigits(date.day)}';
}

/// `19:00:00`·`19:00` → `19:00`.
String? formatLocalTime(String? value) {
  final match = value == null ? null : _localTime.firstMatch(value);
  if (match == null) return null;
  final hour = int.parse(match[1]!);
  final minute = int.parse(match[2]!);
  final second = int.parse(match[3] ?? '0');
  if (hour > 23 || minute > 59 || second > 59) return null;
  return '${match[1]}:${match[2]}';
}

/// [today]에서 [date](`2026-12-20`)까지 남은 날 수. 오늘이면 0, 지난 날짜면 음수다.
/// [today]의 시각은 보지 않는다.
int? daysUntilLocalDate(String? date, DateTime today) {
  final target = _parseLocalDate(date);
  if (target == null) return null;
  final start = DateTime.utc(today.year, today.month, today.day);
  return target.difference(start).inDays;
}

/// 날짜만 `DateTime.utc`로 만든다. 지역 시간으로 빼면 일광 절약 시간이 바뀌는 날 하루가 23·25시간이 되어
/// 날 수가 틀린다.
DateTime? _parseLocalDate(String? value) {
  final match = value == null ? null : _localDate.firstMatch(value);
  if (match == null) return null;
  final year = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final day = int.parse(match[3]!);
  final date = DateTime.utc(year, month, day);
  // 2026-02-30처럼 없는 날짜는 DateTime이 다음 달로 넘기므로 받지 않는다.
  if (date.year != year || date.month != month || date.day != day) return null;
  return date;
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
