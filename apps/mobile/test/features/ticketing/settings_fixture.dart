import 'package:highfive/features/ticketing/models/ticket_settings.dart';

final settingsNow = DateTime(2026, 11, 28, 12);

TicketSettingsDraft validTicketSettings() => TicketSettingsDraft(
  price: '15000',
  capacity: '120',
  account: TicketDemoAccount.sample,
  contact: TicketDemoContact.sample,
  performanceStartsAt: DateTime(2027, 1, 12, 19),
  performanceEndsAt: DateTime(2027, 1, 12, 21),
  registrationClosesAt: DateTime(2027, 1, 12, 18),
  refundClosesAt: DateTime(2027, 1, 11, 23, 59),
  refundPolicy: '데모 환불 규정',
);
