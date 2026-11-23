import 'package:flutter/material.dart';

import '../../../../../shared/widgets/qr/qr_detail_row.dart';
import '../../../../../shared/widgets/qr/qr_list_card.dart';
import 'gallery_item.dart';

/// 컴포넌트 모음의 `shared/widgets/qr/`: 정보 카드, 예매자 목록 한 줄.
class QrGallerySection extends StatelessWidget {
  const QrGallerySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GalleryItem(
          code: 'QrListCard',
          figma: 'QRList (Property 1 = Default)',
          child: QrListCard(
            rows: [
              (label: '티켓 가격', value: '1장당 15,000원'),
              (label: '입금 계좌', value: '국민 12345-123-12345'),
              (label: '예금주', value: '조하은'),
              (label: '신청 마감', value: '오늘 19:00'),
            ],
          ),
        ),
        GalleryItem(
          code: 'QrDetailRow',
          figma: 'DetailList (Property 1 = Default)',
          child: QrDetailRow(
            name: '김민수',
            phone: '010-****-1234',
            detail: '2매 | 소음공장',
            tagLabel: '남은 2명',
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
