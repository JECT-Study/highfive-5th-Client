import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/utils/date_format.dart';

void main() {
  group('formatLocalDate', () {
    test('서버 날짜를 점과 요일이 있는 화면 날짜로 바꾼다', () {
      expect(formatLocalDate('2026-12-20'), '2026.12.20 (일)');
      expect(formatLocalDate('2026-10-12'), '2026.10.12 (월)');
    });

    test('없거나 형식이 다르거나 없는 날짜면 null이다', () {
      for (final value in [
        null,
        '',
        '2026/12/20',
        '2026-12-20T19:00:00',
        '2026-02-30',
        '2026-13-01',
      ]) {
        expect(formatLocalDate(value), isNull, reason: '$value');
      }
    });
  });

  group('formatLocalTime', () {
    test('초가 있든 없든 시와 분만 남긴다', () {
      expect(formatLocalTime('19:00:00'), '19:00');
      expect(formatLocalTime('09:05'), '09:05');
      expect(formatLocalTime('21:30:15.123'), '21:30');
      expect(formatLocalTime('23:59:59'), '23:59');
    });

    test('없거나 형식이 다르거나 범위를 넘으면 null이다', () {
      for (final value in [
        null,
        '',
        '7:00',
        '24:00',
        '12:60',
        '19:00:',
        '19:00:60',
        '19:00:99',
      ]) {
        expect(formatLocalTime(value), isNull, reason: '$value');
      }
    });
  });

  group('daysUntilLocalDate', () {
    test('오늘의 시각과 상관없이 남은 날 수를 센다', () {
      expect(
        daysUntilLocalDate('2026-12-20', DateTime(2026, 11, 28, 23, 59)),
        22,
      );
      expect(daysUntilLocalDate('2026-11-28', DateTime(2026, 11, 28, 0, 1)), 0);
      expect(daysUntilLocalDate('2026-11-27', DateTime(2026, 11, 28)), -1);
    });

    test('해·달이 바뀌고 윤년이어도 하루씩 센다', () {
      expect(daysUntilLocalDate('2027-01-01', DateTime(2026, 12, 31)), 1);
      expect(daysUntilLocalDate('2028-03-01', DateTime(2028, 2, 28)), 2);
    });

    test('날짜가 없거나 형식이 다르면 null이다', () {
      expect(daysUntilLocalDate(null, DateTime(2026, 11, 28)), isNull);
      expect(daysUntilLocalDate('12/20', DateTime(2026, 11, 28)), isNull);
    });
  });
}
