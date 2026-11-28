import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/message/chat_top_bar.dart';
import '../../../../shared/widgets/message/message_bubble.dart';
import '../../../../shared/widgets/message/message_input_bar.dart';
import '../../../../shared/widgets/message/post_link_bar.dart';
import '../../../../shared/widgets/message/system_message.dart';
import '../../models/chat_room.dart';
import '../providers/chat_providers.dart';
import '../view_models/chat_command_view_model.dart';
import '../widgets/chat_status.dart';

/// Layout: 상단 바/공고 띠, 메시지 ListView 하나, SafeArea 안의 입력창.
/// JECT-156 は host の canDecide に従う decisionBuilder を composition で渡す。
class ChatRoomView extends ConsumerStatefulWidget {
  const ChatRoomView({
    super.key,
    required this.roomId,
    required this.onBack,
    this.onViewPost,
    this.onMore,
    this.demoControls,
    this.decisionBuilder,
  });
  final String roomId;
  final VoidCallback onBack;
  final ValueChanged<InquiryTarget>? onViewPost;
  final VoidCallback? onMore;
  final Widget? demoControls;
  final Widget Function(BuildContext, ChatRoom)? decisionBuilder;

  @override
  ConsumerState<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends ConsumerState<ChatRoomView> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(ChatRoomView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roomId != widget.roomId) _input.clear();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(chatRepositoryProvider, (_, _) => _input.clear());
    final repository = ref.watch(chatRepositoryProvider);
    final roomState = ref.watch(chatRoomProvider(widget.roomId));
    final command = ref.watch(chatCommandProvider);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return roomState.when(
      loading: () => Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: widget.onBack)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: widget.onBack)),
        body: Center(
          child: ChatStatus(
            error: error,
            onRetry: repository == null
                ? null
                : () => ref.invalidate(chatRoomProvider(widget.roomId)),
          ),
        ),
      ),
      data: (room) {
        final actor = repository!.actor;
        final host = actor.teamId == room.target.host.id;
        return Scaffold(
          appBar: ChatTopBar(
            type: ChatTopBarType.chat,
            title: host ? room.target.applicant.name : room.target.host.name,
            subtitles: widget.demoControls == null ? const [] : const ['FAKE'],
            tagLabel: host ? '받은 문의' : '보낸 문의',
            backTooltip: '뒤로',
            onBack: widget.onBack,
            moreTooltip: '더보기',
            onMore: widget.onMore,
          ),
          body: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!keyboardOpen)
                  Semantics(
                    enabled: widget.onViewPost != null,
                    child: PostLinkBar(
                      title: room.target.title,
                      details: room.target.details,
                      actionLabel: '공고 보기',
                      onTap: widget.onViewPost == null
                          ? null
                          : () => widget.onViewPost!(room.target),
                    ),
                  ),
                if (!keyboardOpen && widget.demoControls != null)
                  widget.demoControls!,
                if (room.access.canDecide && widget.decisionBuilder != null)
                  widget.decisionBuilder!(context, room),
                Expanded(
                  child: ListView(
                    key: const ValueKey('chat_messages'),
                    controller: _scroll,
                    reverse: true,
                    padding: const EdgeInsets.all(AppSpacing.x5),
                    children: [
                      for (final message in room.messages.reversed)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.x5),
                          child: Align(
                            alignment: message.authorId == actor.id
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Semantics(
                              key: ValueKey('chat_author_${message.id}'),
                              label:
                                  '${message.authorName}, '
                                  '${message.authorId == actor.id ? '내가 보냄' : '받은 메시지'}',
                              child: MessageBubble(
                                key: ValueKey(message.id),
                                direction: message.authorId == actor.id
                                    ? MessageBubbleDirection.sent
                                    : MessageBubbleDirection.received,
                                message: message.text,
                                senderName: actor.role == ChatRole.member
                                    ? message.authorName
                                    : null,
                                time: TimeOfDay.fromDateTime(
                                  message.sentAt.toLocal(),
                                ).format(context),
                              ),
                            ),
                          ),
                        ),
                      SystemMessage(
                        message: '${room.target.title}에 문의를 시작했어요.',
                      ),
                    ],
                  ),
                ),
                if (command.hasError) ChatStatus(error: command.error!),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.x5),
                  child: Semantics(
                    label: '메시지 입력',
                    child: MessageInputBar(
                      key: const ValueKey('chat_input'),
                      controller: _input,
                      hintText: room.access.canSend
                          ? '궁금한 점을 입력해 주세요.'
                          : '대표자만 메시지를 보낼 수 있어요.',
                      sendLabel: '보내기',
                      enabled: room.access.canSend && !command.isLoading,
                      onSend: command.isLoading
                          ? null
                          : () async {
                              final text = _input.text;
                              final sent = await ref
                                  .read(chatCommandProvider.notifier)
                                  .send(room.id, text);
                              if (sent && mounted && _input.text == text) {
                                _input.clear();
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted && _scroll.hasClients) {
                                    _scroll.jumpTo(0);
                                  }
                                });
                              }
                            },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
