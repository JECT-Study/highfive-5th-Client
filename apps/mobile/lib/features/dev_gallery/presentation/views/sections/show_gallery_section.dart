import 'package:flutter/material.dart';

import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/show/entry_attendee_row.dart';
import '../../../../../shared/widgets/show/show_action_row.dart';
import '../../../../../shared/widgets/show/show_confirm_popup.dart';
import '../../../../../shared/widgets/show/show_date_card.dart';
import '../../../../../shared/widgets/show/show_feed_post.dart';
import '../../../../../shared/widgets/show/show_lineup_item.dart';
import '../../../../../shared/widgets/show/show_meta_text.dart';
import '../../../../../shared/widgets/show/show_pinned_post.dart';
import '../../../../../shared/widgets/show/show_progress_card.dart';
import '../../../../../shared/widgets/show/show_stat_summary.dart';
import '../../../../../shared/widgets/show/show_team_avatar.dart';
import '../../../../../shared/widgets/show/show_top_bar.dart';
import 'gallery_item.dart';

/// 컴포넌트 모음의 `shared/widgets/show/` 묶음 (Figma 공연페이지 섹션). 예시 글자는 Figma 그림의 문구다.
class ShowGallerySection extends StatelessWidget {
  const ShowGallerySection({super.key});

  static const _entryStats = [
    (label: '입장 예정', value: '70명'),
    (label: '입금 대기', value: '5명'),
    (label: '입장 완료', value: '10명'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GalleryItem(
          code: 'ShowLineupItem',
          figma: 'LineUp (Property 1 = card)',
          child: ShowLineupItem(
            name: '소음공장',
            roleLabel: '주최',
            details: const ['록', '4명', '40분'],
            setList: const ['첫눈', '늦은 귀가', '정류장'],
            setListMoreLabel: '+1',
            onTap: () {},
          ),
        ),
        const GalleryItem(
          code: 'ShowLineupPlaceholder',
          figma: 'LineUp (Property 1 = 모집중 · 합류 준비)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              GalleryCaption('Property 1 = 모집중'),
              ShowLineupPlaceholder(message: '1팀 더 모집 중이에요'),
              GalleryCaption('Property 1 = 합류 준비'),
              ShowLineupPlaceholder(message: '합류한 팀이 순서대로 여기에 쌓여요'),
            ],
          ),
        ),
        GalleryItem(
          code: 'ShowLineupAddButton',
          figma: 'LineUp (Property 1 = 팀추가)',
          child: ShowLineupAddButton(label: '팀 추가하기', onTap: () {}),
        ),
        const GalleryItem(
          code: 'ShowTeamAvatar',
          figma: 'Badge (주최 · 모집중) · Profile (Default · 모집중)',
          child: Wrap(
            spacing: AppSpacing.x6,
            runSpacing: AppSpacing.x3,
            children: [
              ShowTeamAvatar(hostLabel: '주최'),
              ShowTeamAvatar(recruiting: true),
              ShowTeamAvatar(name: '소음공장', hostLabel: '주최'),
              ShowTeamAvatar(name: '모집 중', recruiting: true),
            ],
          ),
        ),
        GalleryItem(
          code: 'EntryAttendeeRow',
          figma: '이름으로 찾기',
          child: EntryAttendeeRow(
            name: '정우성',
            phone: '010-8888-1234',
            details: const ['2매', '소음공장'],
            enterLabel: '2명',
            onEnter: () {},
            detailTooltip: '신청 자세히 보기',
            onDetail: () {},
          ),
        ),
        GalleryItem(
          code: 'ShowConfirmPopup · showShowConfirmPopup',
          figma: 'popup (수정 · 수정스탑 · 삭제 · 삭제불가)',
          child: Wrap(
            spacing: AppSpacing.x2,
            runSpacing: AppSpacing.x2,
            children: [
              AppButton(
                label: '수정',
                size: AppButtonSize.small,
                variant: AppButtonVariant.weak,
                onPressed: () => showShowConfirmPopup(
                  context,
                  title: '공연 정보를 수정할까요?',
                  message: '참여 팀 모두에게 변경 알림이 가요.',
                  details: const [
                    (label: '공연 날짜', value: '10.12(월) → 10.19(월)'),
                    (label: '공연 시간', value: '미정 → 19:00 ~21:00'),
                    (label: '공연 장소', value: '미정 → 홍대 놀이터'),
                  ],
                  warning: '티켓 신청 페이지에는 반영되지 않아요.',
                  cancelLabel: '취소',
                  confirmLabel: '수정하기',
                ),
              ),
              AppButton(
                label: '수정스탑',
                size: AppButtonSize.small,
                variant: AppButtonVariant.weak,
                onPressed: () => showShowConfirmPopup(
                  context,
                  title: '수정을 그만할까요?',
                  message: '지금까지 수정한 내용은 저장되지 않아요.',
                  cancelLabel: '계속 수정',
                  confirmLabel: '그만하기',
                ),
              ),
              AppButton(
                label: '삭제',
                size: AppButtonSize.small,
                variant: AppButtonVariant.weak,
                onPressed: () => showShowConfirmPopup(
                  context,
                  title: '공연을 삭제할까요?',
                  message: '삭제하면 되돌릴 수 없어요.',
                  cancelLabel: '취소',
                  confirmLabel: '삭제하기',
                  destructive: true,
                ),
              ),
              AppButton(
                label: '삭제불가',
                size: AppButtonSize.small,
                variant: AppButtonVariant.weak,
                onPressed: () => showShowConfirmPopup(
                  context,
                  alert: true,
                  title: '공연을 삭제할 수 없어요',
                  message: '티켓 판매가 시작된 공연은 삭제할 수 없어요.',
                  notice: '이미 신청한 관객이 있어 공연을 삭제할 수 없어요.\n판매를 멈추려면 티켓관리에서 신청을 마감해 주세요.',
                  confirmLabel: '확인',
                ),
              ),
            ],
          ),
        ),
        GalleryItem(
          code: 'ShowActionRow',
          figma: 'Component (Property 1 = Inquiry · Link · copy)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              const GalleryCaption('Property 1 = Inquiry'),
              ShowActionRow(
                type: ShowActionRowType.inquiry,
                title: '새 문의 2건',
                actionLabel: '확인하기',
                onAction: () {},
              ),
              const GalleryCaption('Property 1 = Link'),
              ShowActionRow(
                type: ShowActionRowType.link,
                title: 'highfive.link/asdfa',
                actionLabel: '복사',
                onAction: () {},
              ),
              const GalleryCaption('Property 1 = copy'),
              ShowActionRow(
                type: ShowActionRowType.copy,
                title: '관객 신청 링크',
                caption: '19:00 마감',
                actionLabel: '복사',
                onAction: () {},
              ),
            ],
          ),
        ),
        GalleryItem(
          code: 'ShowDateCard',
          figma: 'Date (Property 1 = default · today · Detail)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              const GalleryCaption('Property 1 = default'),
              ShowDateCard(
                day: '28',
                weekday: '월',
                title: '합동 리허설',
                details: const ['14:00', '장소'],
                bandLabel: '밴드명',
                onTap: () {},
              ),
              const GalleryCaption('Property 1 = today'),
              ShowDateCard(
                type: ShowDateCardType.today,
                day: '12',
                weekday: '월',
                title: '소음공장 합동공연',
                details: const ['공연 날짜', '장소'],
                bandLabel: '밴드명',
                onTap: () {},
              ),
              const GalleryCaption('Property 1 = Detail'),
              const ShowDateCard(
                type: ShowDateCardType.detail,
                day: '12',
                weekday: '월',
                title: '소음공장 합동공연',
                tags: ['준비 중', '준비 중'],
              ),
            ],
          ),
        ),
        const GalleryItem(
          code: 'ShowStatSummary',
          figma: 'Notice (Property 1 = Default)',
          child: ShowStatSummary(items: _entryStats),
        ),
        GalleryItem(
          code: 'ShowProgressCard',
          figma: 'ProgressCard (Property 1 = 모집전 · 모집중 · 티켓판매 · 공연당일)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              const GalleryCaption('Property 1 = 모집전'),
              ShowProgressCard(
                stage: ShowProgressStage.beforeRecruit,
                title: '함께할 팀을 모집해보세요',
                description: '공고를 올리면 팀 모집 탭에 노출되고, 관심 있는 팀이 문의할 수 있어요.',
                actions: [(label: '모집 공고 올리기', onPressed: () {}, icon: null)],
              ),
              const GalleryCaption('Property 1 = 모집중'),
              ShowProgressCard(
                stage: ShowProgressStage.recruiting,
                stepLabel: '팀 모집',
                stepTrailingLabel: '1/3단계',
                title: '3팀 확정, 1팀 더 모집 중',
                description: '공고 마감까지 7일 남았어요',
                info: ShowActionRow(
                  type: ShowActionRowType.inquiry,
                  title: '새 문의 2건',
                  actionLabel: '확인하기',
                  onAction: () {},
                ),
                actions: [
                  (label: '공고 관리', onPressed: () {}, icon: null),
                  (label: '공고 공유', onPressed: () {}, icon: null),
                ],
              ),
              const GalleryCaption('Property 1 = 티켓판매'),
              ShowProgressCard(
                stage: ShowProgressStage.ticketSales,
                stepLabel: '티켓 판매',
                stepTrailingLabel: '2/3단계',
                title: '관객 신청 링크를 공유해요',
                details: const ['신청 34명', '입금 확인 28명', '남은 자리 30석'],
                info: ShowActionRow(
                  type: ShowActionRowType.link,
                  title: 'highfive.link/asdfa',
                  actionLabel: '복사',
                  onAction: () {},
                ),
                actions: [
                  (
                    label: '카카오톡 공유',
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble),
                  ),
                  (
                    label: 'QR 저장',
                    onPressed: () {},
                    icon: const Icon(Icons.qr_code),
                  ),
                ],
              ),
              const GalleryCaption('Property 1 = 공연당일 (카드 아래 줄은 footer)'),
              ShowProgressCard(
                stage: ShowProgressStage.showDay,
                stepLabel: '공연 당일',
                stepTrailingLabel: '3/3단계',
                title: '오늘 19:00 공연이에요',
                description: '18:30부터 현장 입장을 받을 수 있어요',
                info: const ShowStatSummary(items: _entryStats),
                actions: [
                  (
                    label: '현장 입장 시작',
                    onPressed: () {},
                    icon: const Icon(Icons.qr_code_scanner),
                  ),
                ],
                footer: ShowActionRow(
                  type: ShowActionRowType.copy,
                  title: '관객 신청 링크',
                  caption: '19:00 마감',
                  actionLabel: '복사',
                  onAction: () {},
                ),
              ),
            ],
          ),
        ),
        GalleryItem(
          code: 'ShowFeedPost',
          figma: 'FeedTab (Property 1 = Text · Image)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              const GalleryCaption('Property 1 = Text'),
              ShowFeedPost(
                authorName: '박기타',
                details: const ['1일 전', '전체'],
                body: '저희 셋리스트 올립니다. 마지막 곡 순서는 리허설 때 조정 가능합니다다다다ㅏ다다다다다',
                reactionCount: '2',
                commentLabel: '댓글',
                commentCount: '2',
                moreTooltip: '더보기',
                onTap: () {},
                onMoreTap: () {},
              ),
              const GalleryCaption('Property 1 = Image'),
              ShowFeedPost(
                type: ShowFeedPostType.image,
                authorName: '박기타',
                details: const ['1일 전', '우리 팀'],
                body: '저희 셋리스트 올립니다. 마지막 곡 순서는 리허설 때 조정 가능합니다다다다ㅏ다다다다다',
                reactionCount: '2',
                commentLabel: '댓글',
                commentCount: '2',
                moreTooltip: '더보기',
                onTap: () {},
                onMoreTap: () {},
              ),
            ],
          ),
        ),
        GalleryItem(
          code: 'ShowPinnedPost',
          figma: 'Container',
          child: ShowPinnedPost(
            title: '텍스트',
            details: const ['이름', '5시간 전'],
            onTap: () {},
          ),
        ),
        GalleryItem(
          code: 'ShowTopBar',
          figma: 'Top (Property 1 = 합동공연)',
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.lineNeutral),
            ),
            child: ShowTopBar(
              title: '소음공장 합동공연',
              details: const ['10/12(월)', '팀 모집 중'],
              backTooltip: '뒤로',
              onBack: () {},
              chatTooltip: '채팅',
              onChatTap: () {},
            ),
          ),
        ),
        GalleryItem(
          code: 'EntryTopBar',
          figma: 'Top (Property 1 = 현장입장)',
          child: EntryTopBar(
            title: '현장 입장',
            details: const ['소음공장 합동공연', '오늘 19:00'],
            closeTooltip: '닫기',
            onClose: () {},
          ),
        ),
        const GalleryItem(
          code: 'ShowMetaText',
          figma: 'Ellipse 점 구분 줄 (Date · FeedTab · Container · Top 등 공통)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              GalleryCaption('size = caption (12)'),
              ShowMetaText(['14:00', '장소']),
              GalleryCaption('size = body (14)'),
              ShowMetaText([
                '신청 34명',
                '입금 확인 28명',
                '남은 자리 30석',
              ], size: ShowMetaTextSize.body),
            ],
          ),
        ),
      ],
    );
  }
}
