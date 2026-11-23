import 'package:flutter/material.dart';

import '../../../../../shared/theme/app_spacing.dart';
import '../../../../../shared/widgets/home/home_action_button.dart';
import '../../../../../shared/widgets/home/home_list_row.dart';
import '../../../../../shared/widgets/home/home_notice.dart';
import '../../../../../shared/widgets/home/home_show_card.dart';
import '../../../../../shared/widgets/home/home_show_card_small.dart';
import '../../../../../shared/widgets/home/home_team_profile.dart';
import 'gallery_item.dart';

/// 위젯 모음의 홈 영역. `shared/widgets/home/` 위젯을 Figma 홈 섹션의 문구로 보여 준다.
class HomeGallerySection extends StatelessWidget {
  const HomeGallerySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GalleryItem(
          code: 'HomeShowCard',
          figma: 'CardLarge (Property 1 = default · ticket · d-day)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              const GalleryCaption('Property 1 = default → type: summary'),
              HomeShowCard(
                statusLabel: '티켓 판매 중',
                roleLabel: '주최',
                title: '소음공장 합동공연',
                details: const ['10.12(월)', '서울 마포구', '3팀'],
                stats: const [
                  (label: '신청', value: '30'),
                  (label: '입금 대기', value: '10'),
                  (label: '다음 일정', value: '10.18 리허설'),
                ],
                onTap: () {},
              ),
              const GalleryCaption('Property 1 = ticket → type: ticket'),
              HomeShowCard(
                type: HomeShowCardType.ticket,
                statusLabel: '티켓 판매 중',
                roleLabel: '주최',
                title: '소음공장 합동공연',
                details: const ['10.12(월)', '서울 마포구', '3팀'],
                bandsTitle: '함께 공연하는 밴드',
                bands: const [
                  (name: '소음공장', image: null),
                  (name: '오프비트', image: null),
                  (name: '세벽세시', image: null),
                ],
                openSlotLabel: '모집 중',
                primaryLabel: '티켓 신청 페이지 만들기',
                onPrimaryPressed: () {},
                onTap: () {},
              ),
              const GalleryCaption('Property 1 = d-day → type: dDay'),
              HomeShowCard(
                type: HomeShowCardType.dDay,
                statusLabel: '공연 당일',
                title: '오늘 19:00 공연이에요!',
                details: const ['소음공장 합동공연'],
                stats: const [
                  (label: '입장 예정', value: '70명'),
                  (label: '입금 대기', value: '5명'),
                  (label: '입장 완료', value: '10명'),
                ],
                secondaryLabel: '티켓 신청 페이지 QR',
                onSecondaryPressed: () {},
                primaryLabel: '현장 입장 시작',
                onPrimaryPressed: () {},
                onTap: () {},
              ),
            ],
          ),
        ),
        GalleryItem(
          code: 'HomeShowAddCard',
          figma: 'CardLarge (Property 1 = add)',
          child: HomeShowAddCard(label: '공연 열고\n팀 모집하기', onTap: () {}),
        ),
        GalleryItem(
          code: 'HomeShowCardSmall',
          figma: 'CardSmall (Property 1 = default)',
          child: Align(
            alignment: Alignment.centerLeft,
            child: HomeShowCardSmall(
              title: '홍대 인디 나잇',
              details: const ['10.12(월)', '1팀 남음'],
              priceLabel: '팀당 약 20만원',
              onTap: () {},
            ),
          ),
        ),
        GalleryItem(
          code: 'HomeNotice',
          figma: 'Notice (Property 1 = Default)',
          child: HomeNotice(
            tagLabel: '문의',
            message: '오프비트가 0000공고에 문의했어요요요요요요용요요요',
            timeLabel: '방금',
            onTap: () {},
          ),
        ),
        GalleryItem(
          code: 'HomeListRow',
          figma: 'HomeList (Property 1 = Default)',
          child: HomeListRow(
            title: '롹롹',
            memberLabel: '팀원 1',
            description: '방 코드 ABCDE123을 팀원에게 공유하세요',
            onTap: () {},
          ),
        ),
        GalleryItem(
          code: 'HomeTeamProfile',
          figma: 'TeamProfile (Property 1 = Default)',
          child: HomeTeamProfile(
            name: '소음 공장',
            memberLabel: '팀원 1',
            codeLabel: '초대코드',
            code: 'ABCDE123',
            shareLabel: '공유',
            onSharePressed: () {},
          ),
        ),
        GalleryItem(
          code: 'HomeActionButton',
          figma: 'Btn (홈 섹션, Property 1 = addBtn · searchBtn)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              const GalleryCaption(
                'Property 1 = addBtn → type: add (왼쪽) · searchBtn → type: search (오른쪽)',
              ),
              Row(
                spacing: AppSpacing.x2_5,
                children: [
                  Expanded(
                    child: HomeActionButton(
                      label: '공연 열고\n팀 모집하기',
                      onPressed: () {},
                    ),
                  ),
                  Expanded(
                    child: HomeActionButton(
                      type: HomeActionButtonType.search,
                      label: '모집 중인\n공연 찾기',
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
