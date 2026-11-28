import '../../models/concert_edit_values.dart';

/// 명세의 전체 교체 요청. 모델의 모든 필드(null 포함)를 보낸다.
class ConcertEditRequestDto {
  const ConcertEditRequestDto(this.values);

  final ConcertEditValues values;

  Map<String, dynamic> toJson() => values.toJson();
}
