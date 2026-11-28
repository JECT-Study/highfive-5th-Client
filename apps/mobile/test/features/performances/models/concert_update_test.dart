import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_update.dart';

void main() {
  final sent = ConcertUpdate.fromDetail(FakeConcertRepository.sample)
      .copyWith(startTime: '19:00:00', endTime: '21:00:00');

  test('version·장르 순서와 중복·생략된 초는 같은 내용으로 본다', () {
    final saved = sent.copyWith(
      version: sent.version + 1,
      genres: ['INDIE', 'ROCK', 'ROCK'],
      startTime: '19:00',
      endTime: '21:00',
    );

    expect(saved.sameContentAs(sent), isTrue);
  });

  test('값이 하나라도 다르면 다른 내용이다', () {
    for (final other in [
      sent.copyWith(title: '다른 제목'),
      sent.copyWith(genres: ['ROCK']),
      sent.copyWith(rentalFee: null),
      sent.copyWith(region: 'BUSAN'),
      sent.copyWith(startTime: '19:00:01'),
      sent.copyWith(address: null),
    ]) {
      expect(other.sameContentAs(sent), isFalse, reason: '$other');
    }
  });
}
