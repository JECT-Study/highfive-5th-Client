import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/app_dropdown.dart';
import '../../../../shared/widgets/app_form_section.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_list_row.dart';
import '../../../../shared/widgets/app_notice.dart';
import '../../../../shared/widgets/app_progress_bar.dart';
import '../../../../shared/widgets/app_selection_controls.dart';
import '../../../../shared/widgets/app_stepper.dart';
import '../../../../shared/widgets/app_tab_list.dart';
import '../../../../shared/widgets/app_tag.dart';
import '../../../../shared/widgets/app_text_area.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import 'sections/common_gallery_section.dart';
import 'sections/gallery_item.dart';
import 'sections/home_gallery_section.dart';
import 'sections/list_gallery_section.dart';
import 'sections/message_gallery_section.dart';
import 'sections/onboarding_gallery_section.dart';
import 'sections/qr_gallery_section.dart';
import 'sections/show_gallery_section.dart';
import 'sections/show_schedule_ticket_gallery_section.dart';

/// dev 빌드 전용 공통 컴포넌트 모음. 컴포넌트마다 코드 이름과 Figma 컴포넌트 이름을 같이 보여준다.
/// 앱 어디에서도 링크하지 않고, dev에서 왼쪽 위 DEV 띠를 길게 누르면 열린다.
class WidgetGalleryView extends StatefulWidget {
  const WidgetGalleryView({
    super.key,
    this.initialFolder,
    this.onConcertEditPreview,
  });

  final VoidCallback? onConcertEditPreview;

  /// 처음 보여 줄 폴더 이름(`message`, `show` …, 범용은 `generic`). 없거나 모르는 이름이면 전체.
  /// `/dev/widgets?folder=message`처럼 경로로 넘긴다.
  final String? initialFolder;

  @override
  State<WidgetGalleryView> createState() => _WidgetGalleryViewState();
}

/// 모음 화면의 폴더. `shared/widgets/` 아래 폴더와 같고, 순서대로 보여준다.
enum _GalleryFolder {
  generic('범용', 'shared/widgets/', '공통 · Button · Icon'),
  message('message', 'shared/widgets/message/', '메시지'),
  show('show', 'shared/widgets/show/', '공연페이지'),
  qr('qr', 'shared/widgets/qr/', 'QR'),
  home('home', 'shared/widgets/home/', '홈'),
  onboarding('onboarding', 'shared/widgets/onboarding/', '온보딩'),
  list('list', 'shared/widgets/list/', '목록');

  const _GalleryFolder(this.label, this.path, this.figmaSection);

  final String label;
  final String path;
  final String figmaSection;
}

class _WidgetGalleryViewState extends State<WidgetGalleryView> {
  /// 고른 폴더. null이면 전체.
  late _GalleryFolder? _folder = _GalleryFolder.values
      .where((folder) => folder.name == widget.initialFolder)
      .firstOrNull;
  bool _checked = true;
  int _radio = 0;
  bool _toggle = true;
  int _chip = 0;
  int _tab = 0;
  int _count = 2;
  int _bottomTab = 0;
  bool _loading = false;

  Future<void> _fakeRequest() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: '컴포넌트 모음',
        leading: Navigator.of(context).canPop()
            ? AppIconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                tooltip: '뒤로',
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x4,
              vertical: AppSpacing.x2,
            ),
            child: Row(
              spacing: AppSpacing.x2,
              children: [
                AppChip(
                  label: '전체',
                  selected: _folder == null,
                  onTap: () => setState(() => _folder = null),
                ),
                for (final folder in _GalleryFolder.values)
                  AppChip(
                    label: folder.label,
                    selected: _folder == folder,
                    onTap: () => setState(() => _folder = folder),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              // 폴더를 바꾸면 맨 위부터 다시 보여준다.
              key: ValueKey(_folder),
              padding: const EdgeInsets.all(AppSpacing.x4),
              children: [
                if (widget.onConcertEditPreview != null)
                  AppButton(
                    label: '공연 정보 수정 미리보기',
                    onPressed: widget.onConcertEditPreview,
                  ),
                for (final folder in _GalleryFolder.values)
                  if (_folder == null || _folder == folder) ...[
                    GalleryFolderHeader(
                      folder: folder.path,
                      figmaSection: folder.figmaSection,
                    ),
                    ..._sections(context, folder),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _sections(BuildContext context, _GalleryFolder folder) =>
      switch (folder) {
        _GalleryFolder.generic => _genericItems(context),
        _GalleryFolder.message => const [MessageGallerySection()],
        _GalleryFolder.show => const [
          ShowGallerySection(),
          ShowScheduleTicketGallerySection(),
        ],
        _GalleryFolder.qr => const [QrGallerySection()],
        _GalleryFolder.home => const [HomeGallerySection()],
        _GalleryFolder.onboarding => const [OnboardingGallerySection()],
        _GalleryFolder.list => const [ListGallerySection()],
      };

  /// 범용 위젯(`shared/widgets/app_*.dart`) 예시.
  List<Widget> _genericItems(BuildContext context) => [
    GalleryItem(
      code: 'AppButton',
      figma: 'Btn',
      web: 'Button',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.x3,
        children: [
          const GalleryCaption('Color = Fill · Weak · Danger (Property = XL)'),
          AppButton(label: '공고 올리기', onPressed: () {}),
          AppButton(
            label: '이전',
            variant: AppButtonVariant.weak,
            onPressed: () {},
          ),
          AppButton(
            label: '삭제하기',
            variant: AppButtonVariant.danger,
            onPressed: () {},
          ),
          const GalleryCaption('Staus = Loaing (누르면 2초) · Disabled'),
          AppButton(
            label: '눌러서 로딩 보기',
            loading: _loading,
            onPressed: _fakeRequest,
          ),
          const AppButton(label: '비활성', onPressed: null),
          const AppButton(
            label: '비활성',
            variant: AppButtonVariant.weak,
            onPressed: null,
          ),
          const GalleryCaption('Property = XS'),
          Row(
            spacing: AppSpacing.x2,
            children: [
              Expanded(
                child: AppButton(
                  label: '초기화',
                  size: AppButtonSize.medium,
                  variant: AppButtonVariant.weak,
                  onPressed: () {},
                ),
              ),
              Expanded(
                flex: 2,
                child: AppButton(
                  label: '공고 8개 보기',
                  size: AppButtonSize.medium,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const GalleryCaption('Property = Mini'),
          Wrap(
            spacing: AppSpacing.x2,
            runSpacing: AppSpacing.x2,
            children: [
              AppButton(
                label: '초대하기',
                size: AppButtonSize.small,
                onPressed: () {},
              ),
              AppButton(
                label: '거절하기',
                size: AppButtonSize.small,
                variant: AppButtonVariant.weak,
                onPressed: () {},
              ),
              AppButton(
                label: '삭제',
                size: AppButtonSize.small,
                variant: AppButtonVariant.danger,
                onPressed: () {},
              ),
            ],
          ),
          const GalleryCaption('Property = Floating'),
          Wrap(
            spacing: AppSpacing.x2,
            runSpacing: AppSpacing.x2,
            children: [
              AppButton(
                label: '글쓰기',
                size: AppButtonSize.floating,
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
              AppButton(
                label: '글쓰기',
                size: AppButtonSize.floating,
                variant: AppButtonVariant.weak,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {},
              ),
            ],
          ),
          const GalleryCaption('PrefixIcon 있음 (없으면 자리도 없다)'),
          AppButton(
            label: '카카오톡으로 계속하기',
            icon: const Icon(Icons.chat_bubble),
            onPressed: () {},
          ),
          AppButton(
            label: '공유하기',
            variant: AppButtonVariant.weak,
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
    ),
    GalleryItem(
      code: 'AppIconButton',
      figma: 'IconButton',
      child: Row(
        children: [
          AppIconButton(
            icon: const AppIcon(AppIcons.search),
            tooltip: '검색',
            onPressed: () {},
          ),
          AppIconButton(
            icon: const Icon(Icons.close),
            tooltip: '닫기',
            onPressed: () {},
          ),
          AppIconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: '더보기',
            onPressed: () {},
          ),
          const AppIconButton(
            icon: Icon(Icons.share_outlined),
            tooltip: '공유 (비활성)',
            onPressed: null,
          ),
        ],
      ),
    ),
    const GalleryItem(
      code: 'AppTextField',
      figma: 'Input',
      web: 'TextField',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.x3,
        children: [
          GalleryCaption('Property = Weak → 입력하면 Fill'),
          AppTextField(hintText: '이름을 입력해 주세요.'),
          GalleryCaption('Property = 2Fill (검색 아이콘) · 단위 = 원'),
          AppTextField(hintText: '검색', prefix: AppIcon(AppIcons.search)),
          AppTextField(hintText: '대관비', suffix: Text('원')),
          GalleryCaption('Property = Error · Disabled = True'),
          AppTextField(hintText: '오류 상태', invalid: true),
          AppTextField(hintText: '비활성', enabled: false),
        ],
      ),
    ),
    const GalleryItem(
      code: 'AppTextArea',
      figma: 'TextArea',
      web: 'TextArea',
      child: AppTextArea(hintText: '공연 소개를 적어 주세요.', maxLength: 200),
    ),
    GalleryItem(
      code: 'AppDropdown',
      figma: 'Dropdown',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.x3,
        children: [
          AppDropdown(hintText: '지역 선택', onTap: () {}),
          AppDropdown(value: '서울 마포구', onTap: () {}),
        ],
      ),
    ),
    GalleryItem(
      code: 'AppFormSection',
      figma: 'FormSection',
      web: 'FormSection',
      child: AppFormSection(
        title: '닉네임',
        required: true,
        hint: '2~10자로 설정해주세요.',
        children: [
          const AppTextField(hintText: '이름을 입력해 주세요.'),
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: '중복 확인',
              size: AppButtonSize.small,
              variant: AppButtonVariant.weak,
              onPressed: () {},
            ),
          ),
        ],
      ),
    ),
    GalleryItem(
      code: 'AppStepper',
      figma: 'InputCount (− 값 + 상자)',
      child: Row(
        children: [
          Expanded(
            child: Text('모집 팀 수', style: context.textStyles.body1Medium),
          ),
          AppStepper(
            valueLabel: '$_count팀',
            onDecrement: _count > 1 ? () => setState(() => _count--) : null,
            onIncrement: _count < 5 ? () => setState(() => _count++) : null,
          ),
        ],
      ),
    ),
    GalleryItem(
      code: 'AppChip',
      figma: 'Chip · SocialLinkChip',
      web: 'Chip',
      child: Wrap(
        spacing: AppSpacing.x2,
        runSpacing: AppSpacing.x2,
        children: [
          for (final (i, label) in ['1년 미만', '1~3년', '3년 이상'].indexed)
            AppChip(
              label: label,
              selected: _chip == i,
              onTap: () => setState(() => _chip = i),
            ),
        ],
      ),
    ),
    GalleryItem(
      code: 'AppFilterChip',
      figma: 'Filter (State = Rest · Active)',
      child: Wrap(
        spacing: AppSpacing.x2,
        children: [
          AppFilterChip(label: '장르', onTap: () {}),
          AppFilterChip(label: '서울', selected: true, onTap: () {}),
        ],
      ),
    ),
    const GalleryItem(
      code: 'AppTag',
      figma:
          'TagSquare (Size = XS · S · XL, Property = Default · Fill · Outline)',
      web: 'Tag',
      child: Wrap(
        spacing: AppSpacing.x2,
        runSpacing: AppSpacing.x2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppTag(label: '준비 중'),
          AppTag(label: '준비 중', size: AppTagSize.medium),
          AppTag(label: '모집 중', size: AppTagSize.large),
          AppTag(label: '마감', style: AppTagStyle.filled),
          AppTag(
            label: '합류',
            style: AppTagStyle.outlined,
            size: AppTagSize.large,
          ),
        ],
      ),
    ),
    const GalleryItem(
      code: 'AppRoundTag',
      figma: 'TagRound (Size = XL · L · M)',
      web: 'RoundTag',
      child: Wrap(
        spacing: AppSpacing.x2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppRoundTag(label: '보낸 문의'),
          AppRoundTag(label: '록', size: AppRoundTagSize.medium),
          AppRoundTag(label: '태그', size: AppRoundTagSize.small),
        ],
      ),
    ),
    GalleryItem(
      code: 'AppCheckbox',
      figma: 'Checkbox',
      web: 'Checkbox',
      child: Row(
        children: [
          AppCheckbox(
            checked: _checked,
            semanticLabel: '체크박스',
            onChanged: (v) => setState(() => _checked = v),
          ),
          const AppCheckbox(checked: false, onChanged: null),
        ],
      ),
    ),
    GalleryItem(
      code: 'AppRadio',
      figma: 'Radio Button',
      web: 'Radio',
      child: Row(
        children: [
          for (var i = 0; i < 2; i++)
            AppRadio(
              selected: _radio == i,
              semanticLabel: '라디오 ${i + 1}',
              onTap: () => setState(() => _radio = i),
            ),
        ],
      ),
    ),
    GalleryItem(
      code: 'AppToggle',
      figma: 'Toggle',
      child: Align(
        alignment: Alignment.centerLeft,
        child: AppToggle(
          checked: _toggle,
          semanticLabel: '토글',
          onChanged: (v) => setState(() => _toggle = v),
        ),
      ),
    ),
    const GalleryItem(
      code: 'AppNotice',
      figma: 'Notice (Default · Warning)',
      web: 'Notice',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.x3,
        children: [
          AppNotice(
            message: '입금 확인은 계좌 주인만 할 수 있어요.',
            icon: Icon(Icons.info_outline),
          ),
          AppNotice(message: '신청 마감까지 1일 남았어요', type: AppNoticeType.warning),
        ],
      ),
    ),
    GalleryItem(
      code: 'AppDialog · showAppDialog',
      figma: 'Dialog',
      web: 'Dialog',
      child: AppButton(
        label: '다이얼로그 열기',
        variant: AppButtonVariant.weak,
        onPressed: () => showAppDialog(
          context,
          title: '공고를 삭제할까요?',
          message: '삭제하면 되돌릴 수 없어요.',
          confirmLabel: '삭제',
          cancelLabel: '취소',
          destructive: true,
        ),
      ),
    ),
    GalleryItem(
      code: 'AppBottomSheet · AppModalHeader',
      figma: 'BottomSheet · ModalHeader',
      child: AppButton(
        label: '바텀시트 열기',
        variant: AppButtonVariant.weak,
        onPressed: () => showAppBottomSheet<void>(
          context,
          builder: (sheetContext) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x4,
            children: [
              const AppModalHeader(
                title: '지역을 선택해 주세요.',
                subtitle: '여러 개를 고를 수 있어요.',
              ),
              AppButton(
                label: '확인',
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        ),
      ),
    ),
    GalleryItem(
      code: 'AppBottomNavBar',
      figma: 'NavEX (하단 탭)',
      child: AppBottomNavBar(
        items: const [
          (icon: AppIcons.home, label: '홈'),
          (icon: AppIcons.search, label: '팀 모집'),
          (icon: AppIcons.message, label: '메시지'),
          (icon: AppIcons.my, label: '마이페이지'),
        ],
        currentIndex: _bottomTab,
        onTap: (i) => setState(() => _bottomTab = i),
      ),
    ),
    GalleryItem(
      code: 'AppTabList',
      figma: 'TabList (화면 안 탭)',
      child: AppTabList(
        labels: const ['정보', '피드', '일정', '티켓 관리'],
        selectedIndex: _tab,
        onSelected: (i) => setState(() => _tab = i),
      ),
    ),
    GalleryItem(
      code: 'AppTopBar',
      figma: 'Top (Property 1 = Default)',
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.lineNeutral),
        ),
        child: AppTopBar(
          title: 'Title',
          leading: AppIconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            tooltip: '뒤로 (예시)',
            onPressed: () {},
          ),
          trailing: AppIconButton(
            icon: const AppIcon(AppIcons.search),
            tooltip: '검색 (예시)',
            onPressed: () {},
          ),
        ),
      ),
    ),
    GalleryItem(
      code: 'AppListRow',
      figma: 'ListRow',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppListRow(
            title: '알림 설정',
            leading: const Icon(Icons.notifications_none),
            trailing: AppToggle(
              checked: _toggle,
              onChanged: (v) => setState(() => _toggle = v),
            ),
          ),
          AppListRow(
            title: '계정 관리',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    ),
    const GalleryItem(
      code: 'AppBadge',
      figma: 'Badge (숫자 동그라미 부분)',
      child: Wrap(
        spacing: AppSpacing.x2,
        children: [
          AppBadge(count: 1),
          AppBadge(count: 12),
          AppBadge(count: 120),
        ],
      ),
    ),
    const GalleryItem(
      code: 'AppSectionDivider',
      figma: 'Divider (구역 구분 띠)',
      web: 'SectionDivider',
      child: AppSectionDivider(),
    ),
    const GalleryItem(
      code: 'AppStepProgress',
      figma: 'ProgressBar (단계 막대)',
      child: AppStepProgress(
        title: '팀 모집',
        trailingLabel: '1/3단계',
        current: 1,
        total: 3,
      ),
    ),
    GalleryItem(
      code: 'AppIcon',
      figma: 'Icon (IconList24 등)',
      child: Wrap(
        spacing: AppSpacing.x4,
        runSpacing: AppSpacing.x3,
        children: [
          for (final icon in AppIcons.values)
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.x1,
              children: [AppIcon(icon), GalleryCaption(icon.name)],
            ),
        ],
      ),
    ),
    const CommonGallerySection(),
  ];
}
