import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/auth/data/dto/terms_response_dto.dart';
import 'package:highfive/features/auth/models/term.dart';

void main() {
  test('dev 서버처럼 contentUrl이 null이어도 읽고, 보기 없는 약관으로 바꾼다', () {
    final dto = TermsResponseDto.fromJson({
      'terms': [
        {
          'id': 1,
          'code': 'SERVICE',
          'title': '서비스 이용약관',
          'version': '1.0',
          'required': true,
          'contentUrl': null,
        },
        {
          'id': 3,
          'code': 'AGE_OVER_14',
          'title': '만 14세 이상입니다',
          'version': '1.0',
          'required': true,
          'contentUrl': null,
        },
      ],
    });

    expect(dto.toModel(), const [
      Term(id: 1, title: '서비스 이용약관', required: true),
      Term(id: 3, title: '만 14세 이상입니다', required: true),
    ]);
  });

  test('contentUrl이 있으면 그대로, 빈 문자열이면 보기 없음(null)으로 둔다', () {
    final dto = TermsResponseDto.fromJson({
      'terms': [
        {
          'id': 1,
          'code': 'SERVICE',
          'title': 'a',
          'version': '1.0',
          'required': true,
          'contentUrl': 'https://t/1',
        },
        {
          'id': 2,
          'code': 'PRIVACY',
          'title': 'b',
          'version': '1.0',
          'required': true,
          'contentUrl': '',
        },
      ],
    });

    expect(dto.toModel().map((term) => term.contentUrl), ['https://t/1', null]);
  });
}
