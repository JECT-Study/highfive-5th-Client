// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'term_agreements_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$TermAgreementsRequestDtoToJson(
  TermAgreementsRequestDto instance,
) => <String, dynamic>{
  'agreements': instance.agreements.map((e) => e.toJson()).toList(),
};

Map<String, dynamic> _$TermAgreementDtoToJson(TermAgreementDto instance) =>
    <String, dynamic>{'termId': instance.termId, 'agreed': instance.agreed};

TermAgreementsResponseDto _$TermAgreementsResponseDtoFromJson(
  Map<String, dynamic> json,
) => TermAgreementsResponseDto(nextStep: json['nextStep'] as String);
