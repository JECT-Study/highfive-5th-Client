import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/ticket_page_repository.dart';

// 미리보기 재진입에도 같은 공연을 다시 생성하지 않도록 앱 메모리에 유지한다.
final ticketPageRepositoryProvider = Provider<TicketPageRepository>((ref) {
  final repository = PreviewTicketPageRepository();
  ref.onDispose(repository.dispose);
  return repository;
});
