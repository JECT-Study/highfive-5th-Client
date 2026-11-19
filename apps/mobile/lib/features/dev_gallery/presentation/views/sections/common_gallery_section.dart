import 'package:flutter/material.dart';

import '../../../../../shared/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_band_card.dart';
import '../../../../../shared/widgets/app_chip_group.dart';
import '../../../../../shared/widgets/app_member_header.dart';
import '../../../../../shared/widgets/app_tag.dart';
import 'gallery_item.dart';

/// 모음 화면의 공통 영역: Figma `공통` 섹션의 BandCard · MemberHeader · Chipwarp.
class CommonGallerySection extends StatefulWidget {
  const CommonGallerySection({super.key});

  @override
  State<CommonGallerySection> createState() => _CommonGallerySectionState();
}

class _CommonGallerySectionState extends State<CommonGallerySection> {
  Set<int> _genres = {0, 1};
  int _period = 2;

  void _toggleGenre(int index) => setState(() {
    _genres = _genres.contains(index)
        ? _genres.difference({index})
        : {..._genres, index};
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GalleryItem(
          code: 'AppBandCard',
          figma: 'BandCard (티켓 판매 상태 = True)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              const GalleryCaption('태그 = 티켓 판매 중(Fill) · 주최 · D-day, 시간·장소 있음'),
              AppBandCard(
                title: '소음공장 합동공연',
                date: '10.12(월)',
                time: '19:00',
                place: '서울 마포구',
                tags: const [
                  (label: '티켓 판매 중', style: AppTagStyle.filled),
                  (label: '주최', style: AppTagStyle.neutral),
                  (label: 'D - 20', style: AppTagStyle.neutral),
                ],
                onTap: () {},
              ),
              const GalleryCaption(
                '태그 = 티켓 전(Outline) · D-day, 시간 없음, 장소 미정 안내',
              ),
              AppBandCard(
                title: '소음공장 합동공연',
                date: '10.12(월)',
                place: '장소가 확정되면 열 수 있어요',
                tags: const [
                  (label: '티켓 전', style: AppTagStyle.outlined),
                  (label: 'D - 20', style: AppTagStyle.neutral),
                ],
                onTap: () {},
              ),
            ],
          ),
        ),
        const GalleryItem(
          code: 'AppMemberHeader',
          figma: 'MemberHeader',
          child: AppMemberHeader(name: '김민지', tag: '키보드'),
        ),
        GalleryItem(
          code: 'AppChipGroup',
          figma: 'Chipwarp (화면에서는 위에 제목을 둔다)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              const GalleryCaption('제목 없음 · 여러 개 고르기'),
              AppChipGroup(
                labels: const ['록', '인디', '메탈', '펑크', '팝', '재즈', '기타'],
                selectedIndexes: _genres,
                onTap: _toggleGenre,
              ),
              const GalleryCaption('제목 있음 · 하나만 고르기'),
              AppChipGroup(
                title: '원하는 팀의 연주 기간',
                labels: const ['무관', '1년 미만', '1~3년', '3년 이상'],
                selectedIndexes: {_period},
                onTap: (i) => setState(() => _period = i),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
