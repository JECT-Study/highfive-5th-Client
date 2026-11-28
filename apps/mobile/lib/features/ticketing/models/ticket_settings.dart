import 'package:characters/characters.dart';

import 'ticket_role.dart';
import 'ticket_schedule.dart';

// 명세 없음: 외부 공연/개인정보를 받지 않는 고정 합성 공연 입력.
enum TicketSettingsConcert {
  demo;

  String get id => ticketPreviewConcertId;
  String get title => '데모 합동공연';
  String get venue => '데모 공연장';
  String get genre => '록, 인디';
  String get performers => '데모 밴드 A, 데모 밴드 B';
  DateTime get startsAt => DateTime(2027, 1, 12, 19);
  DateTime get endsAt => DateTime(2027, 1, 12, 21);
}

// 명세 없음: 은행·계좌번호·예금주는 실제 값을 입력할 수 없는 합성 선택지.
enum TicketDemoAccount {
  sample;

  String get bank => '데모 은행';
  String get number => 'DEMO-ACCOUNT-000';
  String get holder => '데모 예금주';
}

// 명세 없음: 연락처도 합성 선택지만 허용하며 링크를 열거나 전화를 걸지 않는다.
enum TicketDemoContact {
  sample;

  String get phone => 'DEMO-PHONE-000';
  String get link => 'https://ticket-demo.invalid/inquiry';
}

// 명세 없음: 로컬 입력 초안. 가격·한도는 정수, 날짜는 현지 시각으로 검증한다.
class TicketSettingsDraft {
  const TicketSettingsDraft({
    this.price = '',
    this.capacity = '',
    this.account,
    this.contact,
    this.registrationClosesAt,
    this.performanceStartsAt,
    this.performanceEndsAt,
    this.refundClosesAt,
    this.refundPolicy = '',
    this.introduction = '',
    this.precautions = '',
  });

  final String price;
  final String capacity;
  final TicketDemoAccount? account;
  final TicketDemoContact? contact;
  final DateTime? registrationClosesAt;
  final DateTime? performanceStartsAt;
  final DateTime? performanceEndsAt;
  final DateTime? refundClosesAt;
  final String refundPolicy;
  // 명세 없음: Figma 2216:135970의 선택 입력. 각각 표시 글자 수 기준 최대 200자.
  final String introduction;
  final String precautions;

  TicketSettingsDraft copyWith({
    String? price,
    String? capacity,
    TicketDemoAccount? account,
    TicketDemoContact? contact,
    DateTime? registrationClosesAt,
    DateTime? performanceStartsAt,
    DateTime? performanceEndsAt,
    DateTime? refundClosesAt,
    String? refundPolicy,
    String? introduction,
    String? precautions,
  }) => TicketSettingsDraft(
    price: price ?? this.price,
    capacity: capacity ?? this.capacity,
    account: account ?? this.account,
    contact: contact ?? this.contact,
    registrationClosesAt: registrationClosesAt ?? this.registrationClosesAt,
    performanceStartsAt: performanceStartsAt ?? this.performanceStartsAt,
    performanceEndsAt: performanceEndsAt ?? this.performanceEndsAt,
    refundClosesAt: refundClosesAt ?? this.refundClosesAt,
    refundPolicy: refundPolicy ?? this.refundPolicy,
    introduction: introduction ?? this.introduction,
    precautions: precautions ?? this.precautions,
  );
}

enum TicketSettingsField {
  price,
  capacity,
  account,
  contact,
  registrationClosesAt,
  performanceStartsAt,
  performanceEndsAt,
  refundClosesAt,
  refundPolicy,
  introduction,
  precautions,
}

// 명세 없음: 범위·금액·마감 검증 정책은 서버 계약 확정 전 로컬 미리보기 정책이다.
Map<TicketSettingsField, String> validateTicketSettings(
  TicketSettingsDraft draft,
  DateTime now,
) {
  final errors = <TicketSettingsField, String>{};
  final price = int.tryParse(draft.price);
  final capacity = int.tryParse(draft.capacity);
  if (!RegExp(r'^\d+$').hasMatch(draft.price) ||
      price == null ||
      price < 0 ||
      price > 1000000) {
    errors[TicketSettingsField.price] = '가격은 0~1,000,000원의 정수로 입력해 주세요.';
  }
  if (!RegExp(r'^\d+$').hasMatch(draft.capacity) ||
      capacity == null ||
      capacity < 1 ||
      capacity > 10000) {
    errors[TicketSettingsField.capacity] = '판매 수량은 1~10,000장으로 입력해 주세요.';
  }
  if (draft.account == null) {
    errors[TicketSettingsField.account] = '데모 입금 계좌를 선택해 주세요.';
  }
  if (draft.contact == null) {
    errors[TicketSettingsField.contact] = '데모 문의 채널을 선택해 주세요.';
  }
  final start = draft.performanceStartsAt;
  final end = draft.performanceEndsAt;
  final close = draft.registrationClosesAt;
  final refund = draft.refundClosesAt;
  if (start == null || !start.isAfter(now)) {
    errors[TicketSettingsField.performanceStartsAt] =
        '현재 이후의 공연 시작 시간을 선택해 주세요.';
  }
  if (end == null || start == null || !end.isAfter(start)) {
    errors[TicketSettingsField.performanceEndsAt] = '공연 종료는 시작 이후로 선택해 주세요.';
  }
  if (close == null ||
      !close.isAfter(now) ||
      start == null ||
      close.isAfter(start)) {
    errors[TicketSettingsField.registrationClosesAt] =
        '신청 마감은 현재 이후, 공연 시작까지로 선택해 주세요.';
  }
  if (refund == null ||
      !refund.isAfter(now) ||
      start == null ||
      refund.isAfter(start)) {
    errors[TicketSettingsField.refundClosesAt] =
        '환불 마감은 현재 이후, 공연 시작까지로 선택해 주세요.';
  }
  if (draft.refundPolicy.trim().isEmpty ||
      draft.refundPolicy.characters.length > 1000) {
    errors[TicketSettingsField.refundPolicy] = '환불 규정을 1~1,000자로 입력해 주세요.';
  }
  for (final (field, text) in [
    (TicketSettingsField.introduction, draft.introduction),
    (TicketSettingsField.precautions, draft.precautions),
  ]) {
    if (text.characters.length > 200) {
      errors[field] = '200자 이내로 입력해 주세요.';
    }
  }
  // 명세 없음: 합성 미리보기 자유 문구에는 연락처·계좌 형태의 숫자와 외부 주소를 받지 않는다.
  for (final (field, text) in [
    (TicketSettingsField.refundPolicy, draft.refundPolicy),
    (TicketSettingsField.introduction, draft.introduction),
    (TicketSettingsField.precautions, draft.precautions),
  ]) {
    if (RegExp(
      r'(?:\d[\s()./+\-]*){7,}|https?://|www\.|@',
      caseSensitive: false,
    ).hasMatch(text)) {
      errors[field] = '연락처·계좌·외부 주소 없이 데모 문구를 입력해 주세요.';
    }
  }
  return errors;
}

class TicketSettingsFailure implements Exception {
  const TicketSettingsFailure(this.errors, {this.denied = false});

  final Map<TicketSettingsField, String> errors;
  final bool denied;
}

// 명세 없음: 검증을 통과해 메모리에 저장된 값만 제공한다.
class TicketSettings {
  const TicketSettings({required this.draft, required this.schedule});

  final TicketSettingsDraft draft;
  final TicketSchedule schedule;
}
