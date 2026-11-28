import 'package:flutter/widgets.dart';

import '../features/performances/models/host_band.dart';
import '../features/performances/presentation/views/concert_creation_view.dart';
import '../features/performances/presentation/widgets/host_band_picker_sheet.dart';

/// `/shows/new`의 공용 진입점. 밴드가 없으면 선택부터, 있으면 생성 폼부터 연다.
/// 화면을 여는 기능은 `AppRoutes.showNew`만 push하면 되어 app 내부를 import하지 않는다.
class ConcertCreationEntry extends StatefulWidget {
  const ConcertCreationEntry({
    super.key,
    this.hostBand,
    required this.onClose,
    required this.onCreated,
  });

  final HostBand? hostBand;
  final VoidCallback onClose;
  final ValueChanged<int> onCreated;

  @override
  State<ConcertCreationEntry> createState() => _ConcertCreationEntryState();
}

class _ConcertCreationEntryState extends State<ConcertCreationEntry> {
  late HostBand? _band = widget.hostBand;

  @override
  void initState() {
    super.initState();
    if (_band == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pickBand());
    }
  }

  Future<void> _pickBand() async {
    if (!mounted) return;
    final band = await showHostBandPickerSheet(
      Navigator.of(context, rootNavigator: true).context,
    );
    if (!mounted) return;
    if (band == null) {
      widget.onClose();
    } else {
      setState(() => _band = band);
    }
  }

  @override
  Widget build(BuildContext context) => switch (_band) {
    final band? => ConcertCreationView(
      hostBand: band,
      onClose: widget.onClose,
      onCreated: widget.onCreated,
    ),
    null => const SizedBox.expand(),
  };
}
