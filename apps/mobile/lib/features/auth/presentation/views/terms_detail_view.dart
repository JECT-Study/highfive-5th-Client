import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../view_models/terms_view_model.dart';

/// 약관 상세 (Figma `1965:11556`). 약관 동의 시트의 "보기"로 시트 위에 쌓인다.
/// 본문은 서버가 준 `contentUrl` 페이지를 WebView로 보여 준다.
/// 뒤로 가면 시트로 돌아오고, 시트 아래 화면이 남아 있어 고른 체크도 그대로다.
class TermsDetailView extends ConsumerStatefulWidget {
  const TermsDetailView({super.key, required this.termId});

  final int termId;

  @override
  ConsumerState<TermsDetailView> createState() => _TermsDetailViewState();
}

class _TermsDetailViewState extends ConsumerState<TermsDetailView> {
  WebViewController? _controller;

  /// 페이지를 다 받기 전까지 가운데에 로딩을 보인다.
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // 목록은 시트가 이미 받아 두었다. 같은 ViewModel에서 이 약관을 찾는다.
    final term = ref
        .read(termsViewModelProvider)
        .value
        ?.terms
        .where((term) => term.id == widget.termId)
        .firstOrNull;
    final url = term?.contentUrl;
    if (url == null) return;
    _controller = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final term = ref
        .watch(termsViewModelProvider)
        .value
        ?.terms
        .where((term) => term.id == widget.termId)
        .firstOrNull;
    final controller = _controller;

    return Scaffold(
      backgroundColor: colors.backgroundNormal,
      appBar: AppTopBar(
        title: term?.title,
        leading: AppIconButton(
          icon: const AppIcon(AppIcons.arrowBack),
          tooltip: '뒤로',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            if (controller != null) WebViewWidget(controller: controller),
            if (controller != null && _loading)
              Center(
                child: CircularProgressIndicator(color: colors.labelAssistive),
              ),
          ],
        ),
      ),
    );
  }
}
