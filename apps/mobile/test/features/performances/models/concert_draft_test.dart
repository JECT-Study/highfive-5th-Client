import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/models/concert_draft.dart';
import 'package:highfive/features/performances/models/concert_genre.dart';

/// 기기 시각이 오후여도 날짜만 본다.
final _today = DateTime(2026, 11, 28, 15, 30);

ConcertDraft _draft({
  String title = '겨울 합동공연',
  Set<ConcertGenre> genres = const {ConcertGenre.rock},
  int recruitTeamCount = 1,
  DateTime? performDate,
  bool withoutDate = false,
  bool rentalFeeUndecided = true,
  String rentalFee = '',
}) => ConcertDraft(
  title: title,
  genres: genres,
  recruitTeamCount: recruitTeamCount,
  performDate: withoutDate ? null : performDate ?? DateTime(2026, 12, 20),
  rentalFeeUndecided: rentalFeeUndecided,
  rentalFeeText: rentalFee,
);

Map<ConcertDraftField, ConcertDraftError> _errors(ConcertDraft draft) =>
    draft.validate(today: _today);

void main() {
  test('필수값을 채우고 대관비가 미정이면 고칠 항목이 없고 대관비는 보내지 않는다', () {
    final draft = _draft();

    expect(_errors(draft), isEmpty);
    expect(draft.rentalFee, isNull);
  });

  test('제목은 앞뒤 공백을 빼고 1~30자여야 한다', () {
    expect(_errors(_draft(title: '   ')), {
      ConcertDraftField.title: ConcertDraftError.missing,
    });
    expect(_errors(_draft(title: '가' * ConcertDraft.titleMaxLength)), isEmpty);
    expect(_errors(_draft(title: ' ${'가' * 30} ')), isEmpty);
    expect(_errors(_draft(title: '가' * 31)), {
      ConcertDraftField.title: ConcertDraftError.tooLong,
    });
  });

  test('장르를 하나도 고르지 않으면 장르를 고치라고 한다', () {
    expect(_errors(_draft(genres: const {})), {
      ConcertDraftField.genres: ConcertDraftError.missing,
    });
  });

  test('공연 날짜는 꼭 고르고 오늘보다 이전이면 안 된다 (오늘은 된다)', () {
    expect(_errors(_draft(withoutDate: true)), {
      ConcertDraftField.performDate: ConcertDraftError.missing,
    });
    expect(_errors(_draft(performDate: DateTime(2026, 11, 27, 23, 59))), {
      ConcertDraftField.performDate: ConcertDraftError.pastDate,
    });
    expect(_errors(_draft(performDate: DateTime(2026, 11, 28))), isEmpty);
  });

  test('대관비가 미정이 아니면 0 이상 2,147,483,647 이하 숫자여야 한다', () {
    Map<ConcertDraftField, ConcertDraftError> fee(String text) =>
        _errors(_draft(rentalFeeUndecided: false, rentalFee: text));
    const invalid = {
      ConcertDraftField.rentalFee: ConcertDraftError.invalidAmount,
    };

    expect(fee(''), {ConcertDraftField.rentalFee: ConcertDraftError.missing});
    expect(fee('0'), isEmpty);
    expect(fee('${ConcertDraft.rentalFeeMax}'), isEmpty);
    expect(fee('2147483648'), invalid);
    expect(fee('99999999999999999999'), invalid);
    expect(fee('-1'), invalid);
    expect(fee('1,000'), invalid);
    expect(
      _draft(rentalFeeUndecided: false, rentalFee: ' 500000 ').rentalFee,
      500000,
    );
  });

  test('모집 팀 수는 주최 팀을 빼고 1팀 이상이어야 한다', () {
    for (final count in [-1, 0]) {
      expect(_errors(_draft(recruitTeamCount: count)), {
        ConcertDraftField.recruitTeamCount: ConcertDraftError.belowMinimum,
      });
    }
    expect(_errors(_draft(recruitTeamCount: 1)), isEmpty);
  });

  test('대관비가 미정이면 적어 둔 값은 보지 않는다', () {
    final draft = _draft(rentalFeeUndecided: true, rentalFee: 'abc');

    expect(_errors(draft), isEmpty);
    expect(draft.rentalFee, isNull);
  });

  test('여러 항목이 틀리면 모두 한 번에 알려 준다', () {
    expect(
      _errors(
        _draft(
          title: '',
          genres: const {},
          recruitTeamCount: 0,
          withoutDate: true,
          rentalFeeUndecided: false,
        ),
      ).keys,
      unorderedEquals(ConcertDraftField.values),
    );
  });
}
