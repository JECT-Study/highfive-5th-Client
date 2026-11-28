import 'package:json_annotation/json_annotation.dart';

/// 공연 상세 안의 모집 공고 상태.
enum RecruitmentStatus {
  @JsonValue('RECRUITING')
  recruiting,
  @JsonValue('CLOSED')
  closed,
  unknown,
}
