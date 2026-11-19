import 'package:flutter/material.dart';

import '../../../../../shared/theme/app_spacing.dart';
import '../../../../../shared/widgets/message/chat_list_row.dart';
import '../../../../../shared/widgets/message/chat_team_input_bar.dart';
import '../../../../../shared/widgets/message/chat_top_bar.dart';
import '../../../../../shared/widgets/message/inquiry_list_item.dart';
import '../../../../../shared/widgets/message/invitation_card.dart';
import '../../../../../shared/widgets/message/join_result_card.dart';
import '../../../../../shared/widgets/message/message_bubble.dart';
import '../../../../../shared/widgets/message/message_input_bar.dart';
import '../../../../../shared/widgets/message/message_swipe_row.dart';
import '../../../../../shared/widgets/message/message_tag.dart';
import '../../../../../shared/widgets/message/post_link_bar.dart';
import '../../../../../shared/widgets/message/profile_badge.dart';
import '../../../../../shared/widgets/message/report_item.dart';
import '../../../../../shared/widgets/message/system_message.dart';
import 'gallery_item.dart';

/// 메시지 영역 공통 위젯 모음 (`shared/widgets/message/`, Figma 메시지 섹션).
/// 입력창·라디오·밀기처럼 상태가 필요한 예시는 이 섹션 안에서만 상태를 가진다.
class MessageGallerySection extends StatefulWidget {
  const MessageGallerySection({super.key});

  @override
  State<MessageGallerySection> createState() => _MessageGallerySectionState();
}

class _MessageGallerySectionState extends State<MessageGallerySection> {
  final _emptyInput = TextEditingController();
  final _filledInput = TextEditingController(text: '팀 대표만 입력 가능해요');
  final _leaderInput = TextEditingController();
  final _memberInput = TextEditingController();
  final _reason = TextEditingController();
  int _reportIndex = 0;
  bool _swipeRevealed = false;
  bool _checked = false;

  @override
  void dispose() {
    for (final controller in [
      _emptyInput,
      _filledInput,
      _leaderInput,
      _memberInput,
      _reason,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Figma MessageItem_Inquiry Default 예시 한 줄.
  InquiryListItem _inquiry({bool showCheckbox = false}) => InquiryListItem(
    name: '밴드',
    subtitle: '공고제목',
    tag: const MessageTag(label: '보낸 문의', statusLabel: '거절됨'),
    message: '소음공장 팀에서 단체 채팅에 초대했어요.',
    time: '오후 3:31',
    showCheckbox: showCheckbox,
    checked: _checked,
    onCheckedChanged: (value) => setState(() => _checked = value),
    onTap: () {},
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GalleryItem(
          code: 'MessageTag',
          figma: 'MessageTag (Property 1 = 보낸문의 · 받은 문의)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.x2,
            children: [
              GalleryCaption('Property 1 = 보낸문의 (showTag = true)'),
              MessageTag(label: '보낸 문의', statusLabel: '거절됨'),
              GalleryCaption('Property 1 = 받은 문의 (showTag = true)'),
              MessageTag(label: '받은 문의', statusLabel: '거절됨'),
              GalleryCaption('showTag = false'),
              MessageTag(label: '보낸 문의'),
            ],
          ),
        ),
        const GalleryItem(
          code: 'ProfileBadge',
          figma: 'Badge (badge = false · true)',
          child: Wrap(
            spacing: AppSpacing.x8,
            runSpacing: AppSpacing.x3,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.x2,
                children: [GalleryCaption('badge = false'), ProfileBadge()],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.x2,
                children: [
                  GalleryCaption('badge = true'),
                  ProfileBadge(count: 1),
                ],
              ),
            ],
          ),
        ),
        const GalleryItem(
          code: 'MessageBubble',
          figma: 'MessageContainer (Property 1 = Sent · Received)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              GalleryCaption('Property 1 = Sent'),
              MessageBubble(
                direction: MessageBubbleDirection.sent,
                message: '안녕하세요! 공연 순서도 생각 하셨나요?',
                time: '오후3:31',
              ),
              GalleryCaption(
                'Property 1 = Received (Show Band Name · Show Band Tag)',
              ),
              MessageBubble(
                direction: MessageBubbleDirection.received,
                senderName: '만만수',
                bandLabel: '오프비트 대표',
                message: '관심 감사합니다! 순서는 미정입니다. 서로 셋리스트 정하고 나서 정할 예정입니다.',
                time: '오후3:31',
              ),
              GalleryCaption('Property 1 = Received (Show Band Tag = false)'),
              MessageBubble(
                direction: MessageBubbleDirection.received,
                senderName: '만만수',
                message: '관심 감사합니다!',
                time: '오후3:31',
              ),
            ],
          ),
        ),
        GalleryItem(
          code: 'ChatTeamInputBar',
          figma: 'MessageItem_Representative_Member (Property 1 = 대표자 · 팀원)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GalleryCaption('Property 1 = 대표자'),
              ChatTeamInputBar(
                role: ChatTeamRole.representative,
                controller: _leaderInput,
                hintText: '궁금한 점을 입력해 주세요.',
                sendLabel: '보내기',
                onSend: _leaderInput.clear,
              ),
              const GalleryCaption('Property 1 = 팀원'),
              ChatTeamInputBar(
                role: ChatTeamRole.member,
                controller: _memberInput,
                hintText: '팀 대표만 입력 가능해요',
                sendLabel: '보내기',
                onSend: _memberInput.clear,
              ),
            ],
          ),
        ),
        GalleryItem(
          code: 'ReportItem',
          figma: 'ReportItem (Content = True · False)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x2,
            children: [
              const GalleryCaption(
                'Content = True (고름) · False (안 고름). 눌러서 바꿔 보기',
              ),
              for (var i = 0; i < 2; i++)
                ReportItem(
                  label: 'Text',
                  selected: _reportIndex == i,
                  onTap: () => setState(() => _reportIndex = i),
                  reasonController: _reason,
                  reasonHintText: '(선택)구체적인 사유를 입력해 주세요.',
                  reasonMaxLength: 200,
                ),
            ],
          ),
        ),
        GalleryItem(
          code: 'InvitationCard',
          figma: 'Invitation',
          child: InvitationCard(
            title: '오프비트와 함께 공연할까요?',
            declineLabel: '거절하기',
            acceptLabel: '함께 공연하기',
            onDecline: () {},
            onAccept: () {},
          ),
        ),
        const GalleryItem(
          code: 'ChatListRow',
          figma: 'ChatListRow (showLeaderTag = true · false)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x2,
            children: [
              GalleryCaption('showLeaderTag = true'),
              ChatListRow(name: '조하은', leaderLabel: '대표자'),
              GalleryCaption('showLeaderTag = false'),
              ChatListRow(name: '조하은'),
            ],
          ),
        ),
        const GalleryItem(
          code: 'SystemMessage',
          figma: 'SystemMessage',
          child: SystemMessage(message: '소음공장 합동공연 공고에 문의를 시작했어요.'),
        ),
        GalleryItem(
          code: 'PostLinkBar',
          figma: 'Container_PostLink (Property 1 = 공고보기 · 내공고보기)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x2,
            children: [
              const GalleryCaption('Property 1 = 공고보기'),
              PostLinkBar(
                title: 'Loud Sunday 합동공연 공고',
                details: const ['11.07(토)', '서울 마포구', '장소 미정'],
                actionLabel: '공고 보기',
                onTap: () {},
              ),
              const GalleryCaption('Property 1 = 내공고보기'),
              PostLinkBar(
                title: 'Loud Sunday 합동공연 공고',
                details: const ['11.07(토)', '서울 마포구', '장소 미정'],
                actionLabel: '내 공고 보기',
                onTap: () {},
              ),
            ],
          ),
        ),
        GalleryItem(
          code: 'JoinResultCard',
          figma: 'ResultCard (Property 1 = 합류 · 합류실패)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x2,
            children: [
              const GalleryCaption('Property 1 = 합류'),
              JoinResultCard(
                title: '오프비트가 합류했어요!',
                message: '합동 공연 페이지에서 일정을 등록해보세요!',
                actionLabel: '합동 공연 페이지 가기',
                onAction: () {},
              ),
              const GalleryCaption('Property 1 = 합류실패'),
              JoinResultCard(
                title: '이번 공연은 함께하지 못하게 됐어요',
                message: '다른 공고에서 잘 맞는 팀을 찾아보세요.',
                actionLabel: '다른 공고 둘러보기',
                onAction: () {},
              ),
            ],
          ),
        ),
        GalleryItem(
          code: 'InquiryListItem',
          figma: 'MessageItem_Inquiry (Property 1 = Default · 공고삭제 · 목록에서 확인)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GalleryCaption('Property 1 = Default'),
              _inquiry(),
              const GalleryCaption('Property 1 = 공고삭제'),
              InquiryListItem(
                name: '밴드',
                subtitle: '삭제된 공고',
                tag: const MessageTag(label: '보낸 문의', statusLabel: '거절됨'),
                message: '공고가 삭제됐어요. 톡방 나가기로 정리할 수 있어요.',
                time: '오후 3:31',
                postDeleted: true,
                onTap: () {},
              ),
              const GalleryCaption('Property 1 = 목록에서 확인'),
              InquiryListItem(
                name: '밴드',
                message: '소음공장 팀에서 단체 채팅에 초대했어요.',
                time: '오후 3:31',
                onTap: () {},
              ),
              const GalleryCaption('showCheckBox = true (눌러서 고르기)'),
              _inquiry(showCheckbox: true),
            ],
          ),
        ),
        GalleryItem(
          code: 'MessageSwipeRow',
          figma: 'MessageSwipeRow (Property 1 = Default · Swipe)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GalleryCaption('Property 1 = Default (왼쪽으로 밀어 보기)'),
              MessageSwipeRow(
                revealed: _swipeRevealed,
                onRevealedChanged: (value) =>
                    setState(() => _swipeRevealed = value),
                actionLabel: '나가기',
                onAction: () => setState(() => _swipeRevealed = false),
                child: _inquiry(),
              ),
              const GalleryCaption('Property 1 = Swipe'),
              MessageSwipeRow(
                revealed: true,
                actionLabel: '나가기',
                onAction: () {},
                child: _inquiry(),
              ),
            ],
          ),
        ),
        GalleryItem(
          code: 'MessageInputBar',
          figma: 'MessageInput (Property 1 = 입력전 · 입력후)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x2,
            children: [
              const GalleryCaption('Property 1 = 입력전'),
              MessageInputBar(
                controller: _emptyInput,
                hintText: '팀 대표만 입력 가능해요',
                sendLabel: '보내기',
                onSend: _emptyInput.clear,
              ),
              const GalleryCaption('Property 1 = 입력후'),
              MessageInputBar(
                controller: _filledInput,
                hintText: '팀 대표만 입력 가능해요',
                sendLabel: '보내기',
                onSend: _filledInput.clear,
              ),
            ],
          ),
        ),
        GalleryItem(
          code: 'ChatTopBar',
          figma: 'Top (Property 1 = 채팅창 · 합동공연채팅)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x2,
            children: [
              const GalleryCaption('Property 1 = 채팅창'),
              ChatTopBar(
                type: ChatTopBarType.chat,
                title: '오프비트',
                subtitles: const ['1시간 내 답변'],
                tagLabel: '보낸 문의',
                backTooltip: '뒤로',
                onBack: () {},
                moreTooltip: '더보기',
                onMore: () {},
              ),
              const GalleryCaption('Property 1 = 합동공연채팅'),
              ChatTopBar(
                type: ChatTopBarType.jointPerformanceChat,
                title: '오프비트',
                subtitles: const ['대표자 채팅', '참여 13명'],
                backTooltip: '뒤로',
                onBack: () {},
                membersTooltip: '참여자',
                onMembers: () {},
                moreTooltip: '더보기',
                onMore: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
