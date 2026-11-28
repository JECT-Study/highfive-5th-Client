import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_button.dart';
import '../app_notice.dart';
import '../qr/qr_list_card.dart';

/// [ShowConfirmPopup]을 띄우고, 확인을 누르면 true, 취소·바깥을 누르면 false를 돌려준다.
/// 결과가 남는 명령(수정·삭제)은 true일 때 화면이 ViewModel 메서드를 부른다.
Future<bool> showShowConfirmPopup(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? message,
  List<QrListCardRow> details = const [],
  String? warning,
  String? notice,
  String? cancelLabel,
  bool alert = false,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: context.colors.materialDimmer,
    builder: (_) => ShowConfirmPopup(
      title: title,
      message: message,
      details: details,
      warning: warning,
      notice: notice,
      alert: alert,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
    ),
  );
  return result ?? false;
}

/// Figma `popup` (공연 수정 · 수정 중단 · 삭제 · 삭제 불가). 공연 정보를 바꾸거나 지우기 전에 묻는 창.
///
/// 범용 `AppDialog`보다 내용이 많다: 바뀌는 값 목록([details]), 빨간 주의 문구([warning]),
/// 회색 안내 띠([notice]), 못 하는 이유를 알리는 느낌표 원([alert]).
/// [cancelLabel]이 없으면 확인 버튼 하나만 보인다 (삭제 불가).
class ShowConfirmPopup extends StatelessWidget {
  const ShowConfirmPopup({
    super.key,
    required this.title,
    required this.confirmLabel,
    this.message,
    this.details = const [],
    this.warning,
    this.notice,
    this.cancelLabel,
    this.alert = false,
    this.destructive = false,
  });

  final String title;
  final String? message;

  /// 바뀌는 값 (예: 공연 날짜 · 10.12(월) → 10.19(월)).
  final List<QrListCardRow> details;

  /// 목록 아래 빨간 글자 (예: 티켓 신청 페이지에는 반영되지 않아요.).
  final String? warning;

  /// 버튼 위 회색 안내 띠.
  final String? notice;
  final String confirmLabel;
  final String? cancelLabel;

  /// 제목 위에 빨간 느낌표 원을 보인다.
  final bool alert;

  /// 확인 버튼을 danger(빨간 바탕)로 보인다.
  final bool destructive;

  static const _width = 320.0; // Figma: popup 폭
  static const _alertSize = 44.0; // Figma: 느낌표 원 지름

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final message = this.message;
    final warning = this.warning;
    final notice = this.notice;
    final cancelLabel = this.cancelLabel;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x5,
        vertical: AppSpacing.x6,
      ),
      backgroundColor: colors.backgroundNormal,
      surfaceTintColor: colors.backgroundNormal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: SizedBox(
        width: _width,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x4,
            children: [
              if (alert)
                Center(
                  child: Container(
                    width: _alertSize,
                    height: _alertSize,
                    alignment: Alignment.center,
                    // Figma: #FDECEC 바탕 → 가장 가까운 의미 색 background.warning.
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.backgroundWarning,
                    ),
                    child: Text(
                      '!',
                      style: textStyles.head.copyWith(
                        color: colors.statusDestructive,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.x1),
                child: Column(
                  spacing: AppSpacing.x2_5,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: textStyles.title1Bold.copyWith(
                        color: colors.gray800,
                      ),
                    ),
                    if (message != null)
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        // Figma: #858586 → 가장 가까운 의미 색 label.alternative.
                        style: textStyles.body1Regular.copyWith(
                          color: colors.labelAlternative,
                        ),
                      ),
                  ],
                ),
              ),
              if (details.isNotEmpty) QrListCard(rows: details),
              if (warning != null)
                Text(
                  warning,
                  style: textStyles.caption1Regular.copyWith(
                    color: colors.statusDestructive,
                  ),
                ),
              if (notice != null) AppNotice(message: notice),
              Row(
                spacing: AppSpacing.x2,
                children: [
                  if (cancelLabel != null)
                    Expanded(
                      child: AppButton(
                        label: cancelLabel,
                        variant: AppButtonVariant.weak,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                  Expanded(
                    child: AppButton(
                      label: confirmLabel,
                      variant: destructive
                          ? AppButtonVariant.danger
                          : AppButtonVariant.fill,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
