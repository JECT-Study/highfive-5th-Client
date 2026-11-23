import 'package:flutter/material.dart';

import '../../../../../shared/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_icon.dart';
import '../../../../../shared/widgets/list/notification_row.dart';
import '../../../../../shared/widgets/list/show_list_item.dart';
import 'gallery_item.dart';

/// 모음 화면의 목록 영역: Figma `목록` 섹션의 List · Notification.
class ListGallerySection extends StatefulWidget {
  const ListGallerySection({super.key});

  @override
  State<ListGallerySection> createState() => _ListGallerySectionState();
}

class _ListGallerySectionState extends State<ListGallerySection> {
  bool _bookmarked = false;
  bool _push = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GalleryItem(
          code: 'ShowListItem',
          figma: 'List (IconBookmark bookmark = false · true)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              const GalleryCaption(
                'show · showDDay = true, 찜 아이콘을 누르면 bookmark가 바뀐다',
              ),
              ShowListItem(
                title: '오합지졸2',
                statusTags: const ['마감', 'D-10'],
                details: const ['서울 마포구', '장소 미정', '연주 1~3년'],
                tags: const ['록', '팝'],
                bookmarked: _bookmarked,
                bookmarkSemanticLabel: '찜하기',
                onBookmarkChanged: (v) => setState(() => _bookmarked = v),
                onTap: () {},
              ),
              const GalleryCaption('show = false · bookmark = true (찜 버튼 없음)'),
              ShowListItem(
                title: '오합지졸2',
                statusTags: const ['D-10'],
                details: const ['서울 마포구', '장소 미정', '연주 1~3년'],
                tags: const ['록', '팝'],
                bookmarked: true,
                onTap: () {},
              ),
            ],
          ),
        ),
        GalleryItem(
          code: 'NotificationRow',
          figma: 'Notification (Property 1 = Default · New)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              const GalleryCaption('Property 1 = Default'),
              NotificationRow(
                icon: AppIcons.message,
                title: '새 문의',
                message: '오프비트가 소음공장 합동공연 공고에 문의했어요.',
                time: '방금',
                onTap: () {},
              ),
              const GalleryCaption('Property 1 = New'),
              NotificationRow(
                icon: AppIcons.message,
                title: '새 문의',
                message: '오프비트가 소음공장 합동공연 공고에 문의했어요.',
                time: '방금',
                unread: true,
                onTap: () {},
              ),
            ],
          ),
        ),
        GalleryItem(
          code: 'NotificationSettingRow',
          figma: 'Notification (Property 1 = toggle · text · next)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              const GalleryCaption('Property 1 = toggle'),
              NotificationSettingRow.toggle(
                title: '푸시 알림 받기',
                checked: _push,
                onChanged: (v) => setState(() => _push = v),
              ),
              const GalleryCaption('Property 1 = text'),
              const NotificationSettingRow.text(
                title: '푸시 알림 받기',
                value: '카카오톡',
              ),
              const GalleryCaption('Property 1 = next'),
              NotificationSettingRow.next(title: '푸시 알림 받기', onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }
}
