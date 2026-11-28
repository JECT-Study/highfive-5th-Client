import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/message/inquiry_list_item.dart';
import '../../models/chat_room.dart';
import '../providers/chat_providers.dart';
import '../view_models/chat_command_view_model.dart';
import '../widgets/chat_status.dart';

/// JECT-155 진입점. 전체 메시지함 필터/미확인 처리는 JECT-157에서 확장한다.
class ChatListView extends ConsumerWidget {
  const ChatListView({
    super.key,
    required this.onOpenRoom,
    this.demoControls,
    this.inquiryTarget,
  });
  final ValueChanged<String> onOpenRoom;
  final Widget? demoControls;
  final InquiryTarget? inquiryTarget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(chatRoomsProvider);
    final command = ref.watch(chatCommandProvider);
    final repository = ref.watch(chatRepositoryProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.x5),
              child: Text('메시지', style: context.textStyles.head),
            ),
            ?demoControls,
            if (inquiryTarget case final target?)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.x5),
                child: AppButton(
                  key: const ValueKey('chat_open_inquiry'),
                  label: 'FAKE · 공연 문의 시작하기',
                  loading: command.isLoading,
                  onPressed: command.isLoading
                      ? null
                      : () async {
                          final room = await ref
                              .read(chatCommandProvider.notifier)
                              .openInquiry(target);
                          if (room != null && context.mounted) {
                            onOpenRoom(room.id);
                          }
                        },
                ),
              ),
            if (command.hasError) ChatStatus(error: command.error!),
            Expanded(
              child: rooms.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: ChatStatus(
                    error: error,
                    onRetry: repository == null
                        ? null
                        : () => ref.invalidate(chatRoomsProvider),
                  ),
                ),
                data: (items) => items.isEmpty
                    ? const Center(child: Text('아직 문의가 없어요.'))
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x5,
                        ),
                        children: [
                          for (final room in items)
                            InquiryListItem(
                              key: ValueKey(room.id),
                              name:
                                  repository!.actor.teamId ==
                                      room.target.host.id
                                  ? room.target.applicant.name
                                  : room.target.host.name,
                              subtitle: room.target.title,
                              message:
                                  room.messages.lastOrNull?.text ??
                                  '문의를 시작했어요.',
                              time: '',
                              onTap: () => onOpenRoom(room.id),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
